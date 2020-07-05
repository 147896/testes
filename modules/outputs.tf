output "alb" {
   value = aws_alb.lb.dns_name 
}

output "ssmRole" {
   value = aws_iam_role.role.name
}
