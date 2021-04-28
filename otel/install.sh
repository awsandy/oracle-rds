wget https://aws-otel-collector.s3.amazonaws.com/amazon_linux/amd64/latest/aws-otel-collector.rpm
rpm -Uvh  ./aws-otel-collector.rpm
amazon-linux-extras install docker
usermod -a -G docker ec2-user
service docker start