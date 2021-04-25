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
#id="subnet-f835fbb4"
vpc_id = data.aws_vpc.vpc-default.id
availability_zone   = "eu-west-2b"

}