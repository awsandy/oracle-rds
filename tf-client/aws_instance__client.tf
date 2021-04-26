
# aws_instance.i-03ee18a908b767aaa:
resource "aws_instance" "client" {
  ami                         = data.aws_ssm_parameter.aml2ami.value
  associate_public_ip_address = true
  availability_zone           = "eu-west-2b"
  disable_api_termination     = false
  ebs_optimized               = false
  get_password_data           = false
  hibernation                 = false
  iam_instance_profile        = "oracle-admin"
  instance_type               = "t2.medium"
  ipv6_address_count          = 0
  ipv6_addresses              = []
  key_name                    = "terraform-andyt"
  monitoring                  = true
  secondary_private_ips       = []
  security_groups = [
    aws_security_group.sg-oracle.id,
  ]
  source_dest_check = true

  subnet_id         = data.aws_subnet.orasub.id
  
  tags = {
    "Name"   = "aml2 Ora Client"
    "Oracle" = "Client"
  }
  tenancy = "default"
  lifecycle {
    ignore_changes = [user_data, user_data_base64]
  }
  user_data   = data.cloudinit_config.client.rendered
  #user_data_base64 = "IyEvYmluL2Jhc2gKc2V0ICt4CmRhdGUgPj4gL3RtcC9teWluc3RhbGwubG9nCmVjaG8gImdpdCBjbG9uZSIgPj4gL3RtcC9teWluc3RhbGwubG9nCnl1bSBpbnN0YWxsIC15IGdpdApta2RpciAvc29mdHdhcmUKY2QgL3NvZnR3YXJlCmdpdCBjbG9uZSBodHRwczovL2dpdGh1Yi5jb20vYXdzYW5keS9vcmFjbGUtcmRzLmdpdApjZCBvcmFjbGUtcmRzCmNobW9kIDc1NSAqLnNoCmVjaG8gImluc3RhbGwiID4+IC90bXAvbXlpbnN0YWxsLmxvZwouL2luc3RhbGwtY2xpZW50LnNoID4+IC90bXAvbXlpbnN0YWxsLmxvZwplY2hvICJ1c2VyIGRhdGEgZG9uZSIgPj4gL3RtcC9teWluc3RhbGwubG9n"
  vpc_security_group_ids = [
    aws_security_group.sg-oracle.id,
  ]

  credit_specification {
    cpu_credits = "standard"
  }

  enclave_options {
    enabled = false
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    iops                  = 3000
    #kms_key_id            = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags                  = {}
    throughput            = 125
    volume_size           = 12
    volume_type           = "gp3"
  }

  timeouts {}
}



