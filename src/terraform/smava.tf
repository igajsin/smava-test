provider "aws" {
  #  access_key = "${var.access_key}"
  #  secret_key = "${var.secret_key}"
  region = "${var.region}"

  shared_credentials_file = "${var.shared_credentials_file}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "smava" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "smava" {
  vpc_id = "${aws_vpc.smava.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.smava.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.smava.id}"
}

# Create a subnet to launch the web server into
resource "aws_subnet" "web" {
  vpc_id                  = "${aws_vpc.smava.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "smava_test_elb"
  description = "Used for the smava test"
  vpc_id      = "${aws_vpc.smava.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "sg_ssh_http" {
  name        = "sg_ssh_http"
  description = "Used to access by ssh and http"
  vpc_id      = "${aws_vpc.smava.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "a-web-elb"

  subnets         = ["${aws_subnet.web.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.web.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-9fc39c74"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg_ssh_http.id}"]

  #TODO: maybe create a dedicate subnet for a front-tier
  # now it uses LoadBalancer's one.
  subnet_id = "${aws_subnet.web.id}"

  tags = {
    tier = "front"
    name = "web"
  }

  connection {
    user = "ec2-user" # The default username for our AMI
    type = "ssh"
  }

  provisioner "local-exec" {
    command = "./mk-inventory.sh web ${aws_instance.web.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo sudo yum install nginx -y",
      "sudo /etc/init.d/nginx start",
    ]
  }
}

resource "aws_instance" "backend" {
  ami                    = "ami-9fc39c74"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg_ssh_http.id}", "${aws_security_group.backend.id}"]

  #TODO: maybe create a dedicate subnet for a front-tier
  # now it uses LoadBalancer's one.
  subnet_id = "${aws_subnet.web.id}"

  tags = {
    tier = "back"
    name = "hw"
  }

  connection {
    user = "ec2-user" # The default username for our AMI
    type = "ssh"
  }

  provisioner "local-exec" {
    command = "./mk-inventory.sh back ${aws_instance.backend.public_ip}"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.web.id}"
}

# A security group to access
# the instances over SSH, HTTP and ICMP
resource "aws_security_group" "backend" {
  name        = "backend_sg"
  description = "Used in the terraform for the backend tier"
  vpc_id      = "${aws_vpc.smava.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ip" {
  value = "${aws_eip.ip.public_ip}"
}

output "web" {
  value = "${aws_elb.web.dns_name}"
}
