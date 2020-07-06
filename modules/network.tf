data "aws_vpc" "default" {
   default = true
}

data "aws_subnet_ids" "selected" {
   vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "selected" {
   count = length(data.aws_subnet_ids.selected.ids)
   id = element(tolist(data.aws_subnet_ids.selected.ids), count.index)
}
