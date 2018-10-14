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

resource "aws_eip" "ip" {
  instance = "${aws_instance.web.id}"

  provisioner "local-exec" {
    command = "sed -e s/'web.*'/'web ansible_host=${aws_eip.ip.public_ip} ansible_user=ec2-user backend_ip=${aws_instance.backend.private_ip}'/ -i ../playbooks/inventory"
  }
}
