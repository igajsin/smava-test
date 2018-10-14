provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
}

output "web_eip" {
  value = "${aws_eip.ip.public_ip}"
}

output "web_name" {
  value = "${aws_elb.web.dns_name}"
}
