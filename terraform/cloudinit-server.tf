locals {
  cloud_config_config2 = <<-END
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


data "cloudinit_config" "server" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"
    content      = local.cloud_config_config2
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "example.sh"
    content      = <<-EOF
    #!/bin/bash -xe
    cd /root
    echo "starting cloud init" >> /tmp/me.txt
    gunzip install_chronicle.py.gz 
    chmod 755 /root/install_chronicle.py
    #/root/install_chronicle.py >> /tmp/me.txt
    echo "git clone" >> /tmp/myinstall.log
    yum install -y git
    mkdir /software
    cd /software
    echo "git clone start" >> /tmp/me.txt
    git clone https://github.com/awsandy/oracle-rds.git
    cd oracle-rds
    chmod 755 *.sh
    echo "install" >> /tmp/myinstall.log
    echo "start install-19c-server1" >> /tmp/me.txt
    ./install-19c-server1.sh >> /tmp/myinstall.log
    #./install-19c-server2.sh >> /tmp/myinstall.log
    echo "user data done" >> /tmp/myinstall.log
    echo "done cloudinit" >> /tmp/me.txt
    EOF
  }
}