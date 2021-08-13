#!/bin/bash
# This is a bash script to deploy a kibana PR to gcp
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

action=$1
type=$2
value=$3
repo_url=${repo_url:-"https://github.com/elastic/kibana"}
#this is the id for the gcp instance, it has to be unique
gcp_name="kbn-dev-v1-${type}-${value}"
#this is workspace id for terraform, it has to be unique
workspace_id="${type}-${value}"
#file for adding and removing deployments
deployments_file="${SCRIPT_DIR}/deployments.txt"

log_file="${SCRIPT_DIR}/kbn_dev.log"

if [[ $type && $type == "pr" ]]; then
  content=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/elastic/kibana/pulls/${value})
  repo_url=$( jq -r  '.head.repo.html_url' <<< "${content}" )
  branch=$( jq -r  '.head.ref' <<< "${content}" )
elif [[  $type && $type == "tag" ]]; then
  branch="tags/${value} -b tags-${value}"
  gcp_name="kbn-dev-v1-${type}-${value//./-}"
elif [[  $type && $type == "branch" ]]; then
  branch="${value}"
  gcp_name="kbn-dev-v1-${type}-${value//./-}"
elif [[  $type  ]]; then
  echo "The type '${type}' you've entered should be one of: pr, tag, branch"
  exit;
fi


log(){
  echo "$1"
  echo "$(date +'[%F %T %Z]') - ${workspace_id} $1 " >> $log_file
}

case $action in

  deploy)
    START=$(date +%s)
    workspaces=$(terraform -chdir="${SCRIPT_DIR}/gcp" workspace list)
    if [[ $workspaces == *"${workspace_id}"* ]]; then
      log "Select workspace"
      terraform -chdir="${SCRIPT_DIR}/gcp" workspace select "${workspace_id}"
    else
      log "Create workspace"
      terraform -chdir="${SCRIPT_DIR}/gcp" workspace new "${workspace_id}"
    fi

    log "Deploying instance of ${type} ${value}, ${repo_url}, ${branch}"
    terraform -chdir="${SCRIPT_DIR}/gcp" apply \
      -var="gcp_name=${gcp_name}" \
      -var="kibana_repo_url=${repo_url}" \
      -var="kibana_repo_branch=${branch}" \
      -auto-approve
    terraform -chdir="${SCRIPT_DIR}/gcp" workspace select "${workspace_id}"
    public_ip=$(terraform -chdir="${SCRIPT_DIR}/gcp" output -json | jq  -r '.public_ip.value')
    kibana_url=$(terraform -chdir="${SCRIPT_DIR}/gcp" output -json | jq  -r '.kibana_url.value')
    if [[ $kibana_url != 'null' ]];
      then
        sed -i "/^${workspace_id}/d " $deployments_file
        echo "${workspace_id}, ${gcp_name}, ${repo_url}, ${branch}, ${kibana_url}" >> $deployments_file
        log "Success deploying instance ${kibana_url}"
        log "Checking for server to be available"
        eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${public_ip} /tmp/check_server_online.sh"
        log "Checking for UI to be available"
        eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${public_ip} /tmp/check_ui_online.sh"
        log "UI is available"
        END=$(date +%s)
        DIFF=$(echo "$END - $START" | bc)
        log "Whole process took ${DIFF} seconds"
      fi
    ;;

  status)
    echo "Status of ${type} ${value}, ${repo_url}, ${branch}"
    terraform -chdir="${SCRIPT_DIR}/gcp" workspace select "${workspace_id}"
    terraform -chdir="${SCRIPT_DIR}/gcp" output
    ;;

  ssh)
    terraform -chdir="${SCRIPT_DIR}/gcp" workspace select "${workspace_id}"
    public_ip=$(terraform -chdir="${SCRIPT_DIR}/gcp" output -json | jq  -r '.public_ip.value')
    eval "ssh -o StrictHostKeyChecking=no ubuntu@${public_ip}"
    ;;

  update)
    log "Updating instance of ${type} ${value}, ${repo_url}, ${branch}"
    START=$(date +%s)
    terraform -chdir="${SCRIPT_DIR}/gcp" workspace select "${workspace_id}"
    terraform_output=$(terraform -chdir="${SCRIPT_DIR}/gcp" output -json | jq  -r '.public_ip.value')
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${terraform_output} bash /tmp/update.sh"
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${terraform_output} bash /tmp/bootstrap.sh"
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${terraform_output} bash /tmp/start.sh"
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${terraform_output} bash /tmp/check_server_online.sh"
    END=$(date +%s)
    DIFF=$(echo "$END - $START" | bc)
    log "Success updating instance (Duration: ${DIFF}s) of ${type} ${value}, ${repo_url}, ${branch}"
    ;;

  destroy)
    terraform -chdir="${SCRIPT_DIR}/gcp" workspace select "${workspace_id}"
    log "Destroying instance of ${type} ${value}, ${repo_url}, ${branch}"
    terraform -chdir="${SCRIPT_DIR}/gcp" destroy -auto-approve
    terraform -chdir="${SCRIPT_DIR}/gcp" workspace select default
    terraform -chdir="${SCRIPT_DIR}/gcp" workspace delete "${workspace_id}"
    sed -i "/^${workspace_id}/d " $deployments_file
    ;;

  *)
    echo "----- Usage -----"
    echo "Use ./kbn-dev-gcp.sh (deploy|destroy|update|status|ssh) (branch|tag|pr) (nameOfBranchOrTagOrPR)"
    echo ""
    echo "----- Current deployments -----"
    if [[ -f $deployments_file ]]; then
       cat $deployments_file
    fi
    ;;
esac