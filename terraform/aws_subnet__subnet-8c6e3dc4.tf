# File generated by aws2tf see https://github.com/aws-samples/aws2tf
# aws_subnet.subnet-8c6e3dc4:
resource "aws_subnet" "subnet-8c6e3dc4" {
  assign_ipv6_address_on_creation = false
  availability_zone               = "eu-west-1c"
  cidr_block                      = "172.31.16.0/20"
  map_public_ip_on_launch         = true
  tags = {
    "Name" = "pub-default3"
  }
  vpc_id = aws_vpc.vpc-d16a7cb7.id

  timeouts {}
}