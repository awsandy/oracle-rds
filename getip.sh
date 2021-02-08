rsp=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Oracle,Values=19c" | jq -r .Reservations[].Instances[].PublicDnsName)
echo "Server 19c:  $rsp"
rsp=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Oracle,Values=Client" | jq -r .Reservations[].Instances[].PublicDnsName)
echo "Client:  $rsp"
rsp=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Oracle,Values=19c" | jq -r .Reservations[].Instances[].PublicDnsName)
echo "Server 10g:  $rsp"
