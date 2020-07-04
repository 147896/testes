data "aws_vpc" "selected" {
   id = var.vpc_id
}

data "aws_subnet_ids" "selected" {
   vpc_id = data.aws_vpc.selected.id
}

data "aws_subnet" "selected" {
   count = length(data.aws_subnet_ids.selected.ids)
   id = element(tolist(data.aws_subnet_ids.selected.ids), count.index)
}
