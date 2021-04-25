locals {
  cloud_config_config1 = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/root/install_chronicle.py.gz"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("install_chronicle.py.gz")
    },
  ]
})}
  END
}


data "cloudinit_config" "client" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"
    content      = local.cloud_config_config1
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "example.sh"
    content      = <<-EOF
    #!/bin/bash -xe
    cd /root
    gunzip install_chronicle.py.gz 
    chmod 755 /root/install_chronicle.py
    /root/install_chronicle.py >> /tmp/me.txt
    echo "myinstall start" >> /tmp/me.txt
    date >> /tmp/myinstall.log
    echo "git clone" >> /tmp/myinstall.log
    yum install -y git
    mkdir /software
    cd /software
    git clone https://github.com/awsandy/oracle-rds.git
    cd oracle-rds
    chmod 755 *.sh
    echo "done git clone" >> /tmp/me.txt
    echo "install" >> /tmp/myinstall.log
    ./install-client.sh >> /tmp/myinstall.log
    echo "user data done" >> /tmp/myinstall.log
    echo "done" >> /tmp/myinstall.log
    echo "done myinstall" >> /tmp/me.txt
    EOF
  }
}