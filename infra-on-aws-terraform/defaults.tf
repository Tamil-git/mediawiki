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
  default = "172.28.0.0/16"
}

variable "aws_cidr_subnet1" {
  default = "172.28.0.0/24"
}

variable "aws_cidr_subnet2" {
  default = "172.28.3.0/24"
}

variable "aws_sg" {
  default = "sg_mediawiki"
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
