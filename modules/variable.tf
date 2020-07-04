variable "aws_region" {
   default = "us-east-1"
}

variable "vpc_id" {
   default = "vpc-0516fb78"
}

variable "instance_ami" {
   default = "ami-0e9089763828757e1"
}

variable "type" {
   default = "t2.micro"
}

variable "assign_eip_address" {
   type = bool
   description = "Assign an Elastic IP address to the instance"
   default = false
}
