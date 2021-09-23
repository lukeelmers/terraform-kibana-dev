# Deploy a Kibana dev instance to Google Cloud

## Instructions:
* In the cloud console, [create a project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project)
if you don't have one yet.
* Create a [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) for Terraform.
  * You can create your own service account for this, or just use the [Compute Engine default service account](https://cloud.google.com/compute/docs/access/service-accounts#default_service_account).
* Download the key in JSON format, and save it inside this directory as `credentials.json`. (Path from repo root: `/gcp/credentials.json`).
* Copy `terraform.tfvars.example` as `terraform.tfvars` and modify any variables as desired.
  * Update `gcp_project` with your project's ID.
  * Also make sure the `kibana_repo_url`, `kibana_branch_url`, and public/private key paths are correct.
* Run `terraform init` inside the `gcp` directory.
* Run `terraform apply` to deploy Kibana (this will take a few minutes).
* The Kibana url and command to ssh into the instance will be provided as outputs.
* Wait 5-10 minutes, then open Kibana in your browser.
  * If the browser is hanging waiting for Kibana to load, it means the server is still building everything.
  Wait a few minutes, and then try again.
* To check Kibana logs, ssh into the instance and `tail -f /var/kibana/kibana.log`.
* Remember to `terraform destroy` when you are done.

## kbn-dev.sh - your friendly deployment bash script helper

Included in this folder is [kbn-dev.sh](./kbn-dev.sh), it's a time saver to quickly deploy PRs from Github.
A list of current deployments you've created can be found in the file `deployments.txt`. Once you destroy a deployment, 
it's also removed from the list.

### Basic Usage

Deploy a PR in

`./kbn-dev.sh deploy pr {numberOfPR}`

Update the instance of a PR

`./kbn-dev.sh update pr {numberOfPR}`

SSH into the instance of a PR

`./kbn-dev.sh ssh pr {numberOfPR}`

Destroy a PR

`./kbn-dev.sh destroy pr {numberOfPR}`

Show deployments

`./kbn-dev.sh`

### Special Usage

You can deploy a Kibana & EUI PR mashup with

`./kbn-dev.sh deploy pr {nrOfPR} --eui={nrOfEuiPR}`

Same works with Elastic Charts

`./kbn-dev.sh deploy pr {nrOfPR} --elastic-charts={elasticChartsPR}`

You can also start ingesting data by

`./kbn-dev.sh deploy pr {nrOfPR} --makelogs={nrOfRecordsToCreate}`

By default GCP instances are prefixed with `kbn-dev-v1` you can change this by e.g.

`export KBN_GCP_PREFIX=kibana-for-my-cat`

If for whatever reason you need a custom GCP name ignoring the prefix, you also can do this by

`./kbn-dev.sh deploy pr {nrOfPR} --gcp_name={kibana-for-my-horse}`

Note that you need to use `--gcp_name` for all other operations


#### What's more ...

... it also works with branches and tags
`./kbn-dev-gcp.sh deploy branch {nameOfBranch}`
`./kbn-dev-gcp.sh deploy tag {nameOfTag}`


