#!/bin/bash
# This is a bash script to deploy a kibana PR to gcp
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ACTION=$1
TYPE=$2
VALUE=$3

REPO_URL=${REPO_URL:-"https://github.com/elastic/kibana"}
#this is the id for the gcp instance, it has to be unique
GCP_NAME="kbn-dev-v1-${TYPE}-${VALUE}"
#this is workspace id for terraform, it has to be unique
WORKSPACE_NAME="${TYPE}-${VALUE}"
#file for adding and removing deployments
DEPLOYMENTS_FILE="${SCRIPT_DIR}/deployments.txt"

log_file="${SCRIPT_DIR}/kbn_dev.log"

for i in "$@"; do
  case $i in
    -e=*|--eui=*)
      EUI="${i#*=}"
      shift
      ;;
    -g=*|--gcp_name=*)
      GCP_NAME="${i#*=}"
      shift
      ;;
    -m=*|--makelogs=*)
      MAKELOGS="${i#*=}"
      shift
      ;;
    *)
      # unknown option
      ;;
  esac
done

if [[ $TYPE && $TYPE == "pr" ]]; then
  content=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/elastic/kibana/pulls/${VALUE})
  REPO_URL=$( jq -r  '.head.repo.html_url' <<< "${content}" )
  BRANCH=$( jq -r  '.head.ref' <<< "${content}" )
elif [[  $TYPE && $TYPE == "tag" ]]; then
  BRANCH="tags/${VALUE} -b tags-${VALUE}"
  GCP_NAME="kbn-dev-v1-${TYPE}-${VALUE//./-}"
elif [[  $TYPE && $TYPE == "BRANCH" ]]; then
  BRANCH="${VALUE}"
  GCP_NAME="kbn-dev-v1-${TYPE}-${VALUE//./-}"
elif [[  $TYPE  ]]; then
  echo "The TYPE '${TYPE}' you've entered should be one of: pr, tag, branch"
  exit;
fi


log(){
  echo "$1"
  echo "$(date +'[%F %T %Z]') - ${WORKSPACE_NAME} $1 " >> $log_file
}

removeDeployment() {
  sed -e "/^${WORKSPACE_NAME}/d" "$DEPLOYMENTS_FILE" >"$DEPLOYMENTS_FILE.new"
  mv -- "$DEPLOYMENTS_FILE.new" "$DEPLOYMENTS_FILE"
}

case $ACTION in

  deploy)
    START=$(date +%s)
    WORKSPACES=$(terraform -chdir="${SCRIPT_DIR}" workspace list)
    if [[ $WORKSPACES == *"${WORKSPACE_NAME}"* ]]; then
      log "Select workspace"
      terraform -chdir="${SCRIPT_DIR}" workspace select "${WORKSPACE_NAME}"
    else
      log "Create workspace"
      terraform -chdir="${SCRIPT_DIR}" workspace new "${WORKSPACE_NAME}"
    fi

    log "🌶️ Deploying instance of ${TYPE} ${VALUE}, ${REPO_URL}, ${BRANCH}"
    terraform -chdir="${SCRIPT_DIR}" apply \
      -var="gcp_name=${GCP_NAME}" \
      -var="kibana_repo_url=${REPO_URL}" \
      -var="kibana_repo_branch=${BRANCH}" \
      -auto-approve
    terraform -chdir="${SCRIPT_DIR}" workspace select "${WORKSPACE_NAME}"
    PUBLIC_IP=$(terraform -chdir="${SCRIPT_DIR}" output -json | jq  -r '.public_ip.value')
    KIBANA_URL=$(terraform -chdir="${SCRIPT_DIR}" output -json | jq  -r '.kibana_url.value')
    if [[ $KIBANA_URL != 'null' ]];
      then
        removeDeployment
        echo "${WORKSPACE_NAME}, ${GCP_NAME}, ${REPO_URL}, ${BRANCH}, ${KIBANA_URL}" >> $DEPLOYMENTS_FILE
        log "🥬 Success deploying instance ${KIBANA_URL}"
        if [[ -n "$EUI" ]];
          then
             log "🍉 Installing EUI"
             eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} /tmp/install_eui.sh ${EUI}"
        fi
        log "🌽 Bootstrapping Kibana"
        eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} /tmp/bootstrap.sh"
        log "🥕 Starting Kibana"
        eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} /tmp/start.sh"
        log "🥑 Checking for Kibana server to be available"
        eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} /tmp/check_server_online.sh"
         if [[ -n "$MAKELOGS" ]];
          then
             log "🍉 Start making logs"
             eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} 'cd ~/kibana && nohup yarn makelogs -c ${MAKELOGS} --url http://elastic:changeme@127.0.0.1:9200 > /dev/null 2>&1 &' "
        fi
        log "🍅 Checking for Kibana UI to be available"
        eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} /tmp/check_ui_online.sh"
        log "🥗 🥯 ☕ - Kibana UI is available (${KIBANA_URL}) "
        END=$(date +%s)
        DIFF=$(echo "$END - $START" | bc)
        log "Whole process took ${DIFF} seconds"
      fi
    terraform -chdir="${SCRIPT_DIR}" workspace select default
    ;;

  status)
    echo "Status of ${TYPE} ${VALUE}, ${REPO_URL}, ${BRANCH}"
    terraform -chdir="${SCRIPT_DIR}" workspace select "${WORKSPACE_NAME}"
    terraform -chdir="${SCRIPT_DIR}" output
    terraform -chdir="${SCRIPT_DIR}" workspace select default
    ;;

  ssh)
    terraform -chdir="${SCRIPT_DIR}" workspace select "${WORKSPACE_NAME}"
    PUBLIC_IP=$(terraform -chdir="${SCRIPT_DIR}" output -json | jq  -r '.public_ip.value')
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP}"
    terraform -chdir="${SCRIPT_DIR}" workspace select default
    ;;

  update)
    log "Updating instance of ${TYPE} ${VALUE}, ${REPO_URL}, ${BRANCH}"
    START=$(date +%s)
    terraform -chdir="${SCRIPT_DIR}" workspace select "${WORKSPACE_NAME}"
    PUBLIC_IP=$(terraform -chdir="${SCRIPT_DIR}" output -json | jq  -r '.public_ip.value')
    [[ -n "$EUI" ]]; eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} /tmp/update_eui.sh ${EUI}"
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} /tmp/update.sh"
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} /tmp/bootstrap.sh"
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} /tmp/start.sh"
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} /tmp/check_server_online.sh"
    END=$(date +%s)
    DIFF=$(echo "$END - $START" | bc)
    log "Success updating instance (Duration: ${DIFF}s) of ${TYPE} ${VALUE}, ${REPO_URL}, ${BRANCH}"
    terraform -chdir="${SCRIPT_DIR}" workspace select default
    ;;

  destroy)
    terraform -chdir="${SCRIPT_DIR}" workspace select "${WORKSPACE_NAME}"
    log "Destroying instance of ${TYPE} ${VALUE}, ${REPO_URL}, ${BRANCH}"
    terraform -chdir="${SCRIPT_DIR}" destroy -auto-approve
    terraform -chdir="${SCRIPT_DIR}" workspace select default
    terraform -chdir="${SCRIPT_DIR}" workspace delete "${WORKSPACE_NAME}"
    removeDeployment
    ;;

  *)
    echo "----- Usage -----"
    echo "Use ./kbn-dev.sh (deploy|destroy|update|status|ssh) (branch|tag|pr) (nameOfBranchOrTagOrPR)"
    echo ""
    echo "----- Current deployments -----"
    if [[ -f $DEPLOYMENTS_FILE ]]; then
       cat $DEPLOYMENTS_FILE
    fi
    ;;
esac