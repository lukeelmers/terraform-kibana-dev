variable "kibana_repo_url" {
  default     = "https://github.com/elastic/kibana"
  type        = string
  description = "URL of the Github repo to clone Kibana from. If you are using this to test code in a PR against the elastic/kibana repo, it will be the URL of your Kibana fork."
}

variable "kibana_repo_branch" {
  default     = "master"
  type        = string
  description = "Branch to checkout from the Kibana repo."
}

variable "kibana_server_port" {
  default     = 5601
  type        = number
  description = "Kibana's dev server port (5601 unless you have explicitly changed it in `kibana.dev.yml`)."
}

variable "kibana_server_password" {
  default     = "changeme"
  type        = string
  description = "Password for elastic user."
}

variable "public_key_path" {
  default     = "~/.ssh/id_rsa.pub"
  type        = string
  description = "Path to the public key which will be given ssh access to the created instance."
}

variable "private_key_path" {
  default     = "~/.ssh/id_rsa"
  type        = string
  description = "Path to the private key which will be used to ssh into the created instance to bootstrap Kibana."
}

variable "gcp_credentials_file" {
  type        = string
  description = "Path to the JSON file containing your service account credentials."
}

variable "gcp_project" {
  type        = string
  description = "ID of the GCP project you wish to use."
}

variable "gcp_region" {
  default     = "us-west1"
  type        = string
  description = "GCP Region in which you wish to deploy the Kibana instance. Be sure the configured `gcp_instance_type` is available in this region."
}

variable "gcp_zone" {
  default     = "us-west1-a"
  type        = string
  description = "GCP Zone in which you wish to deploy the Kibana instance. Be sure this zone is part of the configured `gcp_region`."
}

variable "gcp_instance_type" {
  default     = "e2-standard-4"
  type        = string
  description = "GCP instance type you wish to use. A default has been carefully selected here, but in general it is recommended that the specs be similar to what you would have on a machine used for development. Since the bootstrapping process downloads several assets and also runs an Elasticsearch server, it is recommended to have at least ~100GB of disk space on your local volume."
}

variable "gcp_vm_admin_username" {
  default     = "ubuntu"
  type        = string
  description = "Username for authenticating to the provisioned instance."
}

variable "gcp_name" {
  default     = "kbn-dev-vm"
  type        = string
  description = "GCP instance name"
}
