variable "project" { 
    description = "The GCP project id"
}

variable "region" {
    description = "The GCP region"
}

variable "subnet" {
    description = "The subnetwork for compute engine instances"
}

variable "network" {
    description = "The network for cloud applications except database"
}

variable "dbnetwork" {
    description = "The network for cloud database"
}

variable "service_account_prefix" {
    description = "The email prefix of the administrator service account (characters before '@')"
}