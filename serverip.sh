rsp=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Oracle,Values=19c" | jq -r .Reservations[].Instances[].PrivateIpAddress)
echo "Server:  $rsp"
echo "$rsp oraclelinux" >> /etc/hosts
