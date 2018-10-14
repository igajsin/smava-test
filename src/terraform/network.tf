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
}

# Create a subnet to lauch the back-end into
resource "aws_subnet" "back" {
  vpc_id                  = "${aws_vpc.smava.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
}

# Elastic IP for the NAT gateway
resource "aws_eip" "nat" {}

# A gateway to provide internet-access to the backend app
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.web.id}"

  tags {
    Name = "gw NAT"
  }

  depends_on = ["aws_internet_gateway.smava"]
}

resource "aws_route_table" "back" {
  vpc_id = "${aws_vpc.smava.id}"
}

resource "aws_route" "back" {
  route_table_id         = "${aws_route_table.back.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

resource "aws_route_table_association" "back2back" {
  subnet_id      = "${aws_subnet.back.id}"
  route_table_id = "${aws_route_table.back.id}"
}
