resource "aws_instance" "web" {
  ami                    = "ami-9fc39c74"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.smava_sg_ssh.id}", "${aws_security_group.smava_sg_web.id}"]

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

  # provisioner "local-exec" {
  #   command = "sed -e s/'web.*'/'web ansible_host=${aws_eip.ip.public_ip} ansible_user=ec2-user backend_ip=${aws_instance.backend.private_ip}'/ -i ../playbooks/inventory"
  # }

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
  vpc_security_group_ids = ["${aws_security_group.smava_sg_ssh.id}", "${aws_security_group.smava_sg_back.id}"]

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
    #command = "./mk-inventory.sh back ${aws_instance.backend.public_ip}"
    command = "sed -e s/'back.*'/'back ansible_host=${aws_instance.backend.public_ip} ansible_user=ec2-user'/ -i ../playbooks/inventory"
  }
}
