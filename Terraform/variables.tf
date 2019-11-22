variable "location" {
  default = "South Central US"
  description = "The Azure location where all resources in this example should be created"
}

variable resource_group_name {
    default = "ghost-rg"
    description = "The prefix used for all resources in this example"
}

variable "key_data" {}
