resource "aws_lb" "ctf_ssh" {
  name               = "ctf-ssh"
  load_balancer_type = "network"
  subnets            = ["subnet-3fb16045"]
}

resource "aws_lb_target_group" "ctf" {
  name        = "ctf"
  port        = 22
  protocol    = "TCP"
  vpc_id      = "vpc-b2e76cda"
  target_type = "ip"
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ctf_ssh.arn
  port              = "22"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ctf.arn
  }
}
