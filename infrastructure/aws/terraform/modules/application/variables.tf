variable "project" {
  description = "The project of GCP"
}

variable "google_region" {
  description = "The GCP region"
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

variable "network" {
  description = "The network of GCP"
}

variable "subnet_id1" {
  description = "The id of subnet1"
}

variable "subnet_id2" {
  description = "The id of subnet2"
}

variable "subnet_id3" {
  description = "The id of subnet3"
}

variable "availability_zone1" {
  description = "The available zone of subnetwork"
}

variable "tomcat_log_dir" {
  description = "The directory for Tomcat access log created in EC2 instance"
}

variable "lambda_function_path" {
  description = "The JAR file path for lambda function as a placeholder"
}

variable "certificate_arn" {
  description = "The arn of ssl certificate for load balancer"
}

variable "route53_zone_id" {
  description = "The hosted zone id for the domain name in Route53"
}