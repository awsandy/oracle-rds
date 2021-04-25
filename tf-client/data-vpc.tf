data "aws_vpc" "vpc-default" {
  default = true
}


data "aws_subnet_ids" "example" {
  vpc_id = data.aws_vpc.vpc-default.id
}

data "aws_subnet" "example" {
  for_each = data.aws_subnet_ids.example.ids
  id       = each.value
}

data "aws_subnet" "orasub" {

vpc_id = data.aws_vpc.vpc-default.id
  filter {
    name   = "tag:Name"
    values = ["pub-default1"]
  }
}