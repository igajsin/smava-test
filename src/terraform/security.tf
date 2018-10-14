# A security group for the public web services
resource "aws_security_group" "smava_sg_web" {
  name        = "smava_sg_web"
  description = "Used for the smava test"
  vpc_id      = "${aws_vpc.smava.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
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

# the SG for access instances over SSH
resource "aws_security_group" "smava_sg_ssh" {
  name        = "smava_sg_ssh"
  description = "Used to access by ssh and http"
  vpc_id      = "${aws_vpc.smava.id}"

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

# the SG for access to the backend app
resource "aws_security_group" "smava_sg_back" {
  name        = "smava_sg_back"
  description = "Used to access by ssh and http"
  vpc_id      = "${aws_vpc.smava.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
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
