provider "aws" {
   region = "us-east-1"
}

module "modules" {
   source = "./modules"
}
#
#module "sg" {
#   source = "./sg"
#}
