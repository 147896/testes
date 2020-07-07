provider "aws" {
   region = "us-west-1"
}

module "modules" {
   source = "./modules"
}
