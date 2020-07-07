resource "aws_instance" "nginx" {
   ami	= var.instance_ami
   instance_type = var.type
   associate_public_ip_address = true
   subnet_id = element(tolist(data.aws_subnet_ids.selected.ids), 0)
   security_groups = [aws_security_group.sg_nginx.id]
   iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
   user_data = <<EOF
		#!/bin/bash -xe
                sudo yum update -y
		sudo yum install -y nginx squid
                sudo echo -ne $(aws ec2 describe-instances --filters "Name=tag:Name,Values=Apache" --region "${data.aws_region.current.name}" | grep "\"PrivateIpAddress\"" | awk -F ':' '{print $2}' | sed -E "s/(\")|(,)|\s//g" | tail -1) " apache\n" >> /etc/hosts
		sudo echo "<h1>Hello Nginx - DevOps Tests</h1>" | sudo tee /usr/share/nginx/html/index.html
                sudo sleep 3
               sudo echo "
location /apache {
   proxy_pass  http://apache:80/;
}" | sudo tee -a /etc/nginx/default.d/apache.conf
		sudo service nginx start
		sudo service squid start
		sudo chkconfig nginx on
		sudo chkconfig squid on
                sudo yum install -y https://s3."${data.aws_region.current.name}".amazonaws.com/amazon-ssm-"${data.aws_region.current.name}"/latest/linux_amd64/amazon-ssm-agent.rpm
                sudo yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
                sudo start amazon-ssm-agent
                sudo nohup ssm-session-worker &
                sudo session-manager-plugin
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
   user_data = <<EOF
		#!/bin/bash
                sudo echo export http_proxy="${aws_instance.nginx.private_ip}:3128" >> /etc/environment 
                sudo echo export https_proxy="${aws_instance.nginx.private_ip}:3128" >> /etc/environment
                sudo source /etc/environment
                sudo yum update -y
		sudo yum install -y httpd
		echo "<h1>Hello Apache - DevOps Tests</h1>" | sudo tee /var/www/html/index.html
		sudo service httpd start
		sudo chkconfig httpd on
                sudo yum install -y https://s3."${data.aws_region.current.name}".amazonaws.com/amazon-ssm-"${data.aws_region.current.name}"/latest/linux_amd64/amazon-ssm-agent.rpm
                sudo yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
                sudo start amazon-ssm-agent
                sudo nohup ssm-session-worker &
                sudo session-manager-plugin
   EOF
   tags = {
      "Name" = "Apache"
      "Hostname" = "apache"
   }


}
