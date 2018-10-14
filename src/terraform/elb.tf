resource "aws_elb" "web" {
  name = "a-web-elb"

  subnets         = ["${aws_subnet.web.id}"]
  security_groups = ["${aws_security_group.smava_sg_web.id}"]
  instances       = ["${aws_instance.web.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}
