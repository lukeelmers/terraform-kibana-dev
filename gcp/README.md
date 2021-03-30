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
* To check Kibana logs, ssh into the instance and `tail -f ~/kibana/kibana.log`.
* Remember to `terraform destroy` when you are done.
