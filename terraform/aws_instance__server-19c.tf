
# aws_instance.i-0ea74eed9dfaea5ac:
resource "aws_instance" "i-0ea74eed9dfaea5ac" {
  # aws ec2 describe-images --image-ids
  # RHEL 7.9 gp2 /dev/sda
  ami                         = "ami-020e14de09d1866b4"
  associate_public_ip_address = true
  availability_zone           = "eu-west-1b"
  disable_api_termination     = false
  ebs_optimized               = false
  get_password_data           = false
  hibernation                 = false
  iam_instance_profile        = "eksworkshop-admin"
  instance_type               = "m5a.xlarge"
  ipv6_address_count          = 0
  ipv6_addresses              = []
  key_name                    = "terraform-andyt"
  monitoring                  = true
  secondary_private_ips       = []
  security_groups = [
    aws_security_group.sg-oracle.id,
  ]
  source_dest_check = true
  #for_each          = data.aws_subnet_ids.example.ids
  #subnet_id         = each.value
  subnet_id   = data.aws_subnet.orasub.id
  #
  tags = {
    "Name"   = "RH7-Oracle-19c"
    "Oracle" = "19c"
  }
  tenancy = "default"
  lifecycle {
    ignore_changes = [user_data, user_data_base64]
  }
  #user_data_base64 = "IyEvYmluL2Jhc2gKc2V0ICt4CmRhdGUgPj4gL3RtcC9teWluc3RhbGwubG9nCmVjaG8gImdpdCIgPj4gL3RtcC9teWluc3RhbGwubG9nCnl1bSBpbnN0YWxsIC15IGdpdApta2RpciAvc29mdHdhcmUKY2QgL3NvZnR3YXJlCmdpdCBjbG9uZSBodHRwczovL2dpdGh1Yi5jb20vYXdzYW5keS9vcmFjbGUtcmRzLmdpdApjZCBvcmFjbGUtcmRzCmNobW9kIDc1NSAqLnNoCmVjaG8gImluc3RhbGwiID4+IC90bXAvbXlpbnN0YWxsLmxvZwouL2luc3RhbGwtMTljLXNlcnZlci5zaCA+PiAvdG1wL215aW5zdGFsbC5sb2cKZWNobyAiZG9uZSIgPj4gL3RtcC9teWluc3RhbGwubG9nCg=="
  user_data   = data.cloudinit_config.server.rendered

  


  root_block_device {
    delete_on_termination = true
    encrypted             = true

    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "root"
    }
    volume_size = 64
    throughput = 125
    iops = 3000
    volume_type = "gp3"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdb"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "home"
    }
    volume_size = 32
    volume_type = "gp2"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdc"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "sw"
    }
    volume_size = 100
    iops        = 4000
    #throughput  = 500
    volume_type = "io1"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdd"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "ASM data 1"
    }
    volume_size = 5000
    iops        = 5000
    #throughput  = 500
    volume_type = "io1"
  }


  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sde"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "ASM data 2"
    }
    volume_size = 5000
    iops        = 5000
    #throughput  = 500
    volume_type = "io1"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdf"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "ASM fra 1"
    }
    volume_size = 5000
    iops        = 1000
    #throughput  = 250
    volume_type = "io1"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdg"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "ASM redo1 1"
    }
    volume_size = 150
    iops        = 7500
    #throughput  = 500
    volume_type = "io1"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdh"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "ASM redo1 2"
    }
    volume_size = 150
    iops        = 7500
    #throughput  = 500
    volume_type = "io1"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdi"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "ASM redo1 3"
    }
    volume_size = 150
    iops        = 7500
    #throughput  = 500
    volume_type = "io1"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdj"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "ASM redo2 1"
    }
    volume_size = 150
    iops        = 7500
   # throughput  = 500
    volume_type = "io1"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdk"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "ASM redo2 2"
    }
    volume_size = 150
    iops        = 7500
    #throughput  = 500
    volume_type = "io1"
  }


  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdl"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "ASM redo2 3"
    }
    volume_size = 150
    iops        = 7500
   # throughput  = 500
    volume_type = "io1"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdm"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "Dumps"
    }
    volume_size = 1000
    #iops        = 3000
   # throughput  = 250
    volume_type = "gp2"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdn"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "Dumps"
    }
    volume_size = 5000
    iops        = 1000
  #  throughput  = 250
    volume_type = "io1"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdo"
    encrypted             = true
    #kms_key_id = data.aws_kms_key.k_ae5d40dc-33b5-4e72-ad60-a11a4da18809.arn
    tags = {
      "Oracle" = "Dumps"
    }
    volume_size = 100
    iops        = 4000
  #  throughput  = 500
    volume_type = "io1"
  }



  enclave_options {
    enabled = false
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }



  timeouts {}
}
