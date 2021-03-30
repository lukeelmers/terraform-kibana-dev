# Deploy a Kibana dev instance to Azure

## Instructions:
* In the cloud portal, [create a service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
for Terraform.
  * Copy the subscription ID if you already have one (or otherwise create a new subscription).
  * Copy the client & tenant IDs.
  * For authentication, create an [application/client secret](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#option-2-create-a-new-application-secret)
  and copy the secret.
* Copy `terraform.tfvars.example` as `terraform.tfvars` and modify any variables as desired.
  * The subscription, client, & tenant id/secret are all required.
  * Also make sure the `kibana_repo_url`, `kibana_branch_url`, and public/private key paths are correct.
* Run `terraform init` inside the `azure` directory.
* Run `terraform apply` to deploy Kibana (this will take a few minutes).
* The Kibana url and command to ssh into the instance will be provided as outputs.
* Wait 5-10 minutes, then open Kibana in your browser.
  * If the browser is hanging waiting for Kibana to load, it means the server is still building everything.
  Wait a few minutes, and then try again.
* To check Kibana logs, ssh into the instance and `tail -f ~/kibana/kibana.log`.
* Remember to `terraform destroy` when you are done.
