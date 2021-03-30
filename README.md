# terraform-kibana-dev

Deploy any branch from a Kibana repository to AWS, Azure, or GCP for testing in development.

_This is intended for development purposes only; it will not run Kibana in a production environment._

## Overview

The config in each directory performs the same basic steps in each cloud environment:
* Creates a single VM running Ubuntu 18.04 (LTS)
* Clones the Kibana repo and checks out the branch indicated in `variables.tf` or `terraform.tfvars`
* Starts an Elasticsearch dev server in the background via `yarn es snapshot`
* Runs Kibana in dev mode on the default port indicated in `kibana.dev.yml` (5601), unless configured to do so differently
* Creates a firewall to allow inbound traffic on Kibana's port and allow SSH access to the instance via the public key provided in `variables.tf` or `terraform.tfvars`
* Writes logs to `~/kibana/kibana.log`

## Usage

Refer to the provider-specific READMEs in each directory for usage instructions.

## Requirements
* Terraform `0.14.0` or higher
* Linux or macOS (I haven't tested this on Windows)
* Accounts with each cloud provider you wish to use
* Cloud provider service credentials (see each README for details)

## Reminders

**Don't use for production deployments.**

This does not create a production environment. It runs Elasticsearch as a single-node cluster on the same instance as
Kibana, and no data is persisted between restarts.

**Be patient.**

Running `terraform apply` takes awhile as it needs to not only provision the instances, but also run `kbn bootstrap`, which
can take several minutes.

While you should be able to SSH into the instance as soon as `apply` has completed, you won't be able to see Kibana in the 
browser right away. This is because the Kibana server is kicked off in the background, and needs to build all of the plugins
and run optimizer to bundle the client-side code before serving traffic. This process typically takes 5-10 minutes to finish
after `apply` has completed.

**The code is free, but running the VMs isn't.**

Kibana needs more power than each cloud provider's free tier can offer, so this will cost a small amount of money to run.
Don't forget to `terraform destroy` when you are done testing. I tried my best to pick the cheapest suitable instances I
could find in each `us-west` region, but you can also configure instance sizes & regions via `terraform.tfvars` should you
wish to do so. With the default settings, costs are in the range of $0.10-$0.30 USD per hour at the time of this writing.
