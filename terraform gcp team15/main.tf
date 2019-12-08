# GCP PROFILE
provider "google" {
  credentials = "${file("./admin private key.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

module "network" {
     source  = "./modules/network"
     project = "${var.project}"
     region  = "${var.region}"
}

module "application" {
     source    = "./modules/application"
     project   = "${var.project}"
     region    = "${var.region}"
     network   = module.network.network
     subnet    = module.network.subnet
     dbnetwork = module.network.dbnetwork
     service_account_prefix = "${var.service_account_prefix}"
}