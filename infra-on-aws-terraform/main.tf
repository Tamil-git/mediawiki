#Cloud Provider Access

provider "aws" {
 # access_key = "${var.access_key}"
 # secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Setting up VPC
resource "aws_vpc" "mw_vpc" {
  cidr_block = "${var.aws_cidr_vpc}"
  tags {
    Name = "MediaWikiVPC"
  }
}

resource "aws_subnet" "mw_subnet" {
  vpc_id = "${aws_vpc.mw_vpc.id}"
  cidr_block = "${var.aws_cidr_subnet}"
  tags {
    Name = "MediaWikiSubnet"
  }
}

resource "tls_private_key" "mw_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.keyname}"
  public_key = "${tls_private_key.mw_key.public_key_openssh}"
}



#Launch the instance
resource "aws_instance" "webserver" {
  count         = 2
  ami           = "${var.aws_ami}"
  instance_type = "${var.aws_instance_type}"
  key_name  = "${aws_key_pair.generated_key.key_name}"
  vpc_security_group_ids = ["${aws_vpc.mw_vpc.id}"]
  subnet_id     = "${aws_subnet.mw_subnet.id}" 
  tags {
    Name = "${lookup(var.aws_tags,"webserver")}"
    group = "webservers"
  }
}


resource "aws_instance" "dbserver" {
  ami           = "${var.aws_ami}"
  instance_type = "${var.aws_instance_type}"
#  key_name  = "${aws_key_pair.generated_key.key_name}" 
  vpc_security_group_ids = ["${aws_vpc.mw_vpc.id}"]
  subnet_id     = "${aws_subnet.mw_subnet.id}"

  tags {
    Name = "${lookup(var.aws_tags,"dbserver")}"
    group = "dbserver"
  }
}

