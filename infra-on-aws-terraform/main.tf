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

resource "aws_internet_gateway" "mw_subnet1_igw" {
   #depends_on = ["${aws_vpc.mw_vpc}"]
   vpc_id = "${aws_vpc.mw_vpc.id}"
    tags {
        Name = "MediaWiki Internet Gateway for Subnet1"
    }
}

resource "aws_subnet" "mw_subnet1" {
  vpc_id = "${aws_vpc.mw_vpc.id}"
  cidr_block = "${var.aws_cidr_subnet1}"
  tags {
    Name = "MediaWikiSubnet1"
  }
}
resource "aws_subnet" "mw_subnet2" {
  vpc_id = "${aws_vpc.mw_vpc.id}"
  cidr_block = "${var.aws_cidr_subnet2}"
  tags {
    Name = "MediaWikiSubnet2"
  }
}

resource "aws_security_group" "mw_sg" {
  name = "mw_sg"
  #depends_on = ["${aws_vpc.mw_vpc}"]
  vpc_id = "${aws_vpc.mw_vpc.id}"
  ingress {
    from_port = 80
    to_port  = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3306
    to_port  = 3306
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = "0"
    to_port  = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

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



# Launch the instance
resource "aws_instance" "webserver" {
  #depends_on = ["${aws_security_group.mw_sg}"]
  count         = 2
  ami           = "${var.aws_ami}"
  instance_type = "${var.aws_instance_type}"
  key_name  = "${aws_key_pair.generated_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.mw_sg.id}"]
  subnet_id     = "${aws_subnet.mw_subnet1.id}" 
  tags {
    Name = "${lookup(var.aws_tags,"webserver")}"
    group = "webservers"
  }
}


resource "aws_instance" "dbserver" {
  #depends_on = ["${aws_security_group.mw_sg}"]
  ami           = "${var.aws_ami}"
  instance_type = "${var.aws_instance_type}"
  key_name  = "${aws_key_pair.generated_key.key_name}" 
  vpc_security_group_ids = ["${aws_security_group.mw_sg.id}"]
  subnet_id     = "${aws_subnet.mw_subnet2.id}"

  tags {
    Name = "${lookup(var.aws_tags,"dbserver")}"
    group = "dbserver"
  }
}


resource "aws_elb" "mw_elb" {
  #depends_on = ["${aws_instance.webserver}"]
  name = "MediaWikiELB"
  subnets         = ["${aws_subnet.mw_subnet1.id}", "${aws_subnet.mw_subnet2.id}"]
  security_groups = ["${aws_security_group.mw_sg.id}"]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}
