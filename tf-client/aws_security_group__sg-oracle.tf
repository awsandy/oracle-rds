# File generated by aws2tf see https://github.com/aws-samples/aws2tf
# aws_security_group.sg-086bfef57ba61eb11:
resource "aws_security_group" "sg-oracle" {
  description = "Oracle-sg"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "81.96.210.11/32",
        "54.239.6.177/32",
      ]
      description      = ""
      from_port        = 1521
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 1521
    },
    {
      cidr_blocks = [
        "81.96.210.11/32",
        "54.239.6.177/32",
      ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks = [
        "81.96.210.11/32",
        "54.239.6.177/32",
      ]
      description      = ""
      from_port        = 3389
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 3389
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    },
  ]
  name   = "Oracle-sg"
  tags   = {}
  vpc_id = data.aws_vpc.vpc-default.id

  timeouts {}
}