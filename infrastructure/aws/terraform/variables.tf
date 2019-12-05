variable "credentials" {
  description = "The credentials of GCP"
}

variable "project" {
  description = "The project of GCP"
}

variable "google_region" {
  description = "The google region"
}

variable "vpc_name" {
  description = "The name of the VPC"
}

variable "vpc_cidr_block" {
  description = "The VPC CIDR block (x.x.x.x/x)"
}

variable "subnet_count" {
  default = "3"
}

variable "subnet1_cidr_block" {
  description = "The CIDR block for the 1st Subnet (x.x.x.x/x)"
}

variable "subnet2_cidr_block" {
  description = "The CIDR block for the 2nd Subnet (x.x.x.x/x)"
}

variable "subnet3_cidr_block" {
  description = "The CIDR block for the 3rd Subnet (x.x.x.x/x)"
}

variable "availability_zone1" {
  description = "The availability zone for the 1st Subnet."
}

variable "availability_zone2" {
  description = "The availability zone for the 2nd Subnet."
}

variable "availability_zone3" {
  description = "The availability zone for the 3rd Subnet."
}

variable "domain_name" {
  description = "The domain name"
}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/id_rsa.pub
DESCRIPTION
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "ami_id" {
  description = "The Amazon Machine Image ID for launching the EC2 instance"
}

variable "tomcat_log_dir"{
  description = "The log file's directory" 
}

variable "lambda_function_path" {
  description = "The JAR file path for lambda function as a placeholder"
}

variable "certificate_arn" {
  description = "The arn of ssl certificate for load balancer"
}

variable "web_acl_id" {
  description = "The web acl id"
}

variable "route53_zone_id" {
  description = "The hosted zone id for the domain name in Route53"
}