# Google PROFILE
provider "google" {
  credentials = "${file(var.credentials)}"
  project    = "${var.project}"
  region     = "${var.google_region}"
}

# VPC module
module "vpc"{
  source = "./modules/vpc"
  # name = "csye6225-aws-networking"
  project = "${var.project}"
  availability_zone1 = "${var.availability_zone1}"
  availability_zone2 = "${var.availability_zone2}"
  availability_zone3 = "${var.availability_zone3}"
  google_region = "${var.google_region}"
  subnet1_cidr_block = "${var.subnet1_cidr_block}"
  subnet2_cidr_block = "${var.subnet2_cidr_block}"
  subnet3_cidr_block = "${var.subnet3_cidr_block}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
  vpc_name = "${var.vpc_name}"
}

# Applicaiton module
module "app"{
  source = "./modules/application"
  # name = "csye6225-aws-application"
  project = "${var.project}"
  google_region = "${var.google_region}"
  domain_name = "${var.domain_name}"
  ami_id = "${var.ami_id}"
  key_name = "${var.key_name}"
  public_key_path = "${var.public_key_path}"
  certificate_arn = "${var.certificate_arn}"

  network = module.vpc.google_compute_network
  subnet_id1 = module.vpc.public_subnets_id1
  subnet_id2 = module.vpc.public_subnets_id2
  subnet_id3 = module.vpc.public_subnets_id3
  availability_zone1 = "${var.availability_zone1}"
  tomcat_log_dir = "${var.tomcat_log_dir}"
  lambda_function_path = "${var.lambda_function_path}"
  route53_zone_id = "${var.route53_zone_id}"
}
