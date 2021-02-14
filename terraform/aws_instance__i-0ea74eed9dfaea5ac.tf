
# aws_instance.i-0ea74eed9dfaea5ac:
resource "aws_instance" "i-0ea74eed9dfaea5ac" {
ami = "ami-020e14de09d1866b4"
associate_public_ip_address = true
availability_zone = "eu-west-1c"
disable_api_termination = false
ebs_optimized = false
get_password_data = false
hibernation = false
iam_instance_profile = "terrafrom_ec2_profile"
instance_type = "m5a.xlarge"
ipv6_address_count = 0
ipv6_addresses = []
key_name = "terraform-andyt"
monitoring = true
secondary_private_ips = []
security_groups = [
"Oracle-sg",
]
source_dest_check = true
subnet_id = aws_subnet.subnet-8c6e3dc4.id
tags = {
"Name" = "RH7-Oracle-19c"
"Oracle" = "19c"
}
tenancy = "default"
lifecycle {
   ignore_changes = [user_data,user_data_base64]
}
user_data_base64 = "IyEvYmluL2Jhc2gKc2V0ICt4CmRhdGUgPj4gL3RtcC9teWluc3RhbGwubG9nCmVjaG8gImdpdCIgPj4gL3RtcC9teWluc3RhbGwubG9nCnl1bSBpbnN0YWxsIC15IGdpdApta2RpciAvc29mdHdhcmUKY2QgL3NvZnR3YXJlCmdpdCBjbG9uZSBodHRwczovL2dpdGh1Yi5jb20vYXdzYW5keS9vcmFjbGUtcmRzLmdpdApjZCBvcmFjbGUtcmRzCmNobW9kIDc1NSAqLnNoCmVjaG8gImluc3RhbGwiID4+IC90bXAvbXlpbnN0YWxsLmxvZwouL2luc3RhbGwtMTljLXNlcnZlci5zaCA+PiAvdG1wL215aW5zdGFsbC5sb2cKZWNobyAiZG9uZSIgPj4gL3RtcC9teWluc3RhbGwubG9nCg=="
vpc_security_group_ids = [
aws_security_group.sg-086bfef57ba61eb11.id,
]

ebs_block_device {
delete_on_termination = true
device_name = "/dev/sdb"
encrypted = true
iops = 3000
#kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
tags = {
"Oracle" = "19c"
}
throughput = 125
volume_size = 32
volume_type = "gp3"
}
ebs_block_device {
delete_on_termination = true
device_name = "/dev/sdc"
encrypted = true
iops = 3000
#kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
tags = {
"Oracle" = "19c"
}
throughput = 125
volume_size = 32
volume_type = "gp3"
}

enclave_options {
enabled = false
}

metadata_options {
http_endpoint = "enabled"
http_put_response_hop_limit = 1
http_tokens = "optional"
}

root_block_device {
delete_on_termination = true
encrypted = true
iops = 3000
#kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
tags = {
"Oracle" = "19c"
}
throughput = 125
volume_size = 32
volume_type = "gp3"
}

timeouts {}
}
