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
  description = "Kibana's dev server port (5601 unless you have explicitly changed it)."
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

variable "azure_subscription_id" {
  type = string
}

variable "azure_client_id" {
  type        = string
  description = "Instructions for retrieving this value can be found at https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal"
}

variable "azure_client_secret" {
  type        = string
  description = "Instructions for retrieving this value can be found at https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal"
}

variable "azure_tenant_id" {
  type        = string
  description = "Instructions for retrieving this value can be found at https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal"
}

variable "azure_region" {
  default     = "westus2"
  type        = string
  description = "Azure Region in which you wish to deploy the Kibana instance. Be sure the configured `azure_vm_size` is available in this region."
}

variable "azure_vm_size" {
  default     = "Standard_D4ds_v4"
  type        = string
  description = "Azure VM size you wish to use. A default has been carefully selected here, but in general it is recommended that the specs be similar to what you would have on a machine used for development. Since the bootstrapping process downloads several assets and also runs an Elasticsearch server, it is recommended to have at least ~100GB of disk space on your local volume."
}

variable "azure_vm_admin_username" {
  default     = "azure-user"
  type        = string
  description = "Username for authenticating to the provisioned instance."
}
