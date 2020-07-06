resource "aws_alb" "lb" {
   name = "ALB"
   security_groups = [aws_security_group.sg_alb.id]
   subnets = [tolist(data.aws_subnet_ids.selected.ids)[0], tolist(data.aws_subnet_ids.selected.ids)[1]]

   tags = {
      Name = "ALB"
   }
}

resource "aws_lb_target_group" "tg" {
   name = "ALB-TG"
   port = 80
   protocol = "HTTP"
   vpc_id = data.aws_vpc.default.id
}

resource "aws_lb_listener" "lbl" {
   load_balancer_arn = aws_alb.lb.arn
   port = 80
   protocol = "HTTP"

   default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.tg.arn
   }
}

resource "aws_lb_listener_rule" "tg" {
   listener_arn = aws_lb_listener.lbl.arn
   priority = 5
   action {
      type = "forward"
      target_group_arn = aws_lb_target_group.tg.arn
   }
   condition {
      path_pattern {
         values = ["/apache*"]
      }
   }
}

resource "aws_lb_target_group_attachment" "tg_nginx" {
   target_group_arn = aws_lb_target_group.tg.arn
   target_id = aws_instance.nginx.id
   port = 80
}
