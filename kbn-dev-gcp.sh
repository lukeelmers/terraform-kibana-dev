#!/bin/bash
# This is a bash script to deploy a kibana PR to google cloud
action=$1
type=$2
value=$3
repo_url=${repo_url:-"https://github.com/elastic/kibana"}
#this is the id for the gcp instance, it has to be unique
gcp_name="kbn-dev-v1-${type}-${value}"

if [[ $type && $type == "pr" ]];
    then
        content=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/elastic/kibana/pulls/${value})
        repo_url=$( jq -r  '.head.repo.html_url' <<< "${content}" )
        branch=$( jq -r  '.head.ref' <<< "${content}" )
    fi


if [[  $type && $type == "tag" ]];
    then
        branch="tags/${value} -b tags-${value}"
        gcp_name="kbn-dev-v1-${type}-${value//./-}"
    fi

if [[  $type && $type == "branch" ]];
    then
        branch="${value}"
        gcp_name="kbn-dev-v1-${type}-${value//./-}"
    fi


#this is workspace id for terraform, it has to be unique
workspace_id="${type}-${value}"
#file for adding and removing deployments
deployments_file='deployments.txt'

log_file='kbn_gcp.log'

log(){
    echo "$1"
    echo "$(date +'[%F %T %Z]') - ${workspace_id} $1 " >> $log_file
}

case $action in

  deploy)
    terraform -chdir=./gcp workspace new "${workspace_id}"
    log "Deploying instance of ${type} ${value}, ${repo_url}, ${branch}"
    terraform -chdir=./gcp apply \
      -var="gcp_name=${gcp_name}" \
      -var="kibana_repo_url=${repo_url}" \
      -var="kibana_repo_branch=${branch}" \
      -auto-approve
    public_ip=$(terraform -chdir=./gcp output -json | jq  -r '.public_ip.value')
    kibana_url=$(terraform -chdir=./gcp output -json | jq  -r '.kibana_url.value')
    if [[ $kibana_url != 'null' ]];
      then
        echo "${workspace_id},${gcp_name},${repo_url},${branch},${kibana_url}" >> deployments.txt
        log "Success deploying instance (Duration: ${DIFF}s),${kibana_url}"
      fi
    log "Deploying instance was successful"
    log "Checking for UI to be available"
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${public_ip} /tmp/check_ui_online.sh"
    log "UI is available"
    ;;

  status)
    echo "Status of ${type} ${value}, ${repo_url}, ${branch}"
    terraform -chdir=./gcp workspace select "${workspace_id}"
    terraform -chdir=./gcp output
    ;;

  ssh)
    terraform -chdir=./gcp workspace select "${workspace_id}"
    public_ip=$(terraform -chdir=./gcp output -json | jq  -r '.public_ip.value')
    eval "ssh -o StrictHostKeyChecking=no ubuntu@${public_ip}"
    ;;

  update)
    log "Updating instance of ${type} ${value}, ${repo_url}, ${branch}"
    START=$(date +%s)
    terraform -chdir=./gcp workspace select "${workspace_id}"
    terraform_output=$(terraform -chdir=./gcp output -json | jq  -r '.public_ip.value')
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${terraform_output} bash /tmp/update.sh"
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${terraform_output} bash /tmp/bootstrap.sh"
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${terraform_output} bash /tmp/start.sh"
    eval "ssh -q -o StrictHostKeyChecking=no ubuntu@${terraform_output} bash /tmp/check_server_online.sh"
    END=$(date +%s)
    DIFF=$(echo "$END - $START" | bc)
    log "Success updating instance (Duration: ${DIFF}s) of ${type} ${value}, ${repo_url}, ${branch}"
    ;;

  destroy)
    terraform -chdir=./gcp workspace select "${workspace_id}"
    log "Destroying instance of ${type} ${value}, ${repo_url}, ${branch}"
    terraform -chdir=./gcp destroy -auto-approve
    terraform -chdir=./gcp workspace select default
    terraform -chdir=./gcp workspace delete "${workspace_id}"
    sed -i "/^${workspace_id}/d " $deployments_file
    ;;

  *)
    echo "----- Current deployments -----"
    if [[ -f $deployments_file ]]; then
       cat $deployments_file
    fi
    echo "----- Usage -----"
    echo "Use ./kbn-gcp.sh (numberOfPR) (deploy|destroy|update|status|ssh) (branch|tag|pr) (nameOfBranchOrTagOrPR)"
    ;;
esac