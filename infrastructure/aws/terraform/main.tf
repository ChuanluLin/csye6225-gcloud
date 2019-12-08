provider "google" {
  credentials = "${file("./account.json")}"
  project = var.project
  region = var.region
}

module "network" {
     source = "./modules/network"
     project = var.project
     region = var.region
	 vpc_name = var.vpc_name
	 subnet1_cidr_block = var.subnet1_cidr_block
	 subnet2_cidr_block = var.subnet2_cidr_block
}

module "engine" {
     source = "./modules/engine"
     region = var.region
     project = var.project
     network = module.network.network
     subnetwork = module.network.subnetwork
}

module "function" {
    source = "./modules/function"
    region = var.region
    project = var.project
}

module "database" {
    source = "./modules/database"
    region = var.region
    project = var.project
    network = module.network.network
    dbnetwork = module.network.dbnetwork
}
