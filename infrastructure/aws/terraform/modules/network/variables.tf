variable "project" { 
	description = "The project of GCP"
}

variable "region" { 
	description = "The region of GCP"
}

variable "vpc_name" { 
	description = "The name of vpc"
}

variable "subnet1_cidr_block" {
  description = "The CIDR block for the 1st Subnet (x.x.x.x/x)"
}

variable "subnet2_cidr_block" {
  description = "The CIDR block for the 2nd Subnet (x.x.x.x/x)"
}