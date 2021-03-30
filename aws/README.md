# Deploy a Kibana dev instance to AWS

## Instructions:
* In the AWS console, create a [access key id & secret](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys)
for Terraform.
* Add your access key ID & secret to a [shared credentials file](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/create-shared-credentials-file.html).
  * Save the credentials to `~/.aws/credentials` (without a file extension).
* Copy `terraform.tfvars.example` as `terraform.tfvars` and modify any variables as desired.
  * In particular, make sure the `kibana_repo_url`, `kibana_branch_url`, and public/private key paths are correct.
* Run `terraform init` inside the `aws` directory.
* Run `terraform apply` to deploy Kibana (this will take a few minutes).
* The Kibana url and command to ssh into the instance will be provided as outputs.
* Wait 5-10 minutes, then open Kibana in your browser.
  * If the browser is hanging waiting for Kibana to load, it means the server is still building everything.
  Wait a few minutes, and then try again.
* To check Kibana logs, ssh into the instance and `tail -f ~/kibana/kibana.log`.
* Remember to `terraform destroy` when you are done.
