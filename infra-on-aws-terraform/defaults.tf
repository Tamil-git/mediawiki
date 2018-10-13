# Access
#variable "access_key" {}
#variable "secret_key" {}

# Basic
variable "region" {
  type = "string"
  default =  "us-west-2"
}

variable "keyname" {
  default = "mediawiki"
}

# AMI RHEL-6.7_HVM-20160219-x86_64-1-Hourly2-GP2 - ami-274ba847
variable "aws_ami" {
  default="ami-274ba847"
}

# VPC and Subnet
variable "aws_cidr_vpc" {
  default = "10.0.0.0/27"
}

variable "aws_cidr_subnet" {
  default = "10.0.0.0/28"
}


variable "aws_tags" {
  type = "map"
  default = {
    "webserver" = "MediaWikiWeb"
    "dbserver" = "MediaWikiDB" 
  }
}

variable "aws_instance_type" {
  default = "t2.micro"
}
