resource "aws_instance" "nginx" {
   ami	= var.instance_ami
   instance_type = var.type
   associate_public_ip_address = true
   subnet_id = element(tolist(data.aws_subnet_ids.selected.ids), 0)
   security_groups = [aws_security_group.sg_nginx.id]
   key_name = "nginx"
   user_data = <<EOF
		#!/bin/bash
                sudo yum update -y
		sudo yum install -y nginx squid
		sudo service nginx start
		sudo service squid start
		sudo chkconfig nginx on
		sudo chkconfig squid on
		echo "<h1>Hello Nginx - DevOps Tests</h1>" | sudo tee /var/www/html/index.html
                sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
                sudo start amazon-ssm-agent
   EOF
   tags = {
      "Name" = "Nginx"
      "Hostname" = "nginx"
   }
}

resource "aws_instance" "apache" {
   ami	= var.instance_ami
   instance_type = var.type
   associate_public_ip_address = false
   subnet_id = element(tolist(data.aws_subnet_ids.selected.ids), 0)
   security_groups = [aws_security_group.sg_apache.id]
   iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
   key_name = "apache"
   user_data = <<EOF
		#!/bin/bash
                sudo echo export http_proxy="${aws_instance.nginx.private_ip}:3128" >> /etc/environment 
                sudo echo export https_proxy="${aws_instance.nginx.private_ip}:3128" >> /etc/environment
                sudo source /etc/environment
                sudo yum update -y
		sudo yum install -y httpd
		sudo service httpd start
		sudo chkconfig httpd on
                sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
                sudo start amazon-ssm-agent
		echo "<h1>Hello Apache - DevOps Tests</h1>" | sudo tee /var/www/html/index.html
                unset http_proxy https_proxy
   EOF
   tags = {
      "Name" = "Apache"
      "Hostname" = "apache"
   }


}
