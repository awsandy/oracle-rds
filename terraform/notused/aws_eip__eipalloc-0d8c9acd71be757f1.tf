
# aws_eip.eipalloc-0d8c9acd71be757f1:
resource "aws_eip" "eipalloc-0d8c9acd71be757f1" {
instance = "i-0ea74eed9dfaea5ac"
network_border_group = "eu-west-1"
public_ipv4_pool = "amazon"
tags = {
"Name" = "Oracle-IP"
}
vpc = true

timeouts {}
}
