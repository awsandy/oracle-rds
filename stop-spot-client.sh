srv=$(aws ec2 describe-spot-instance-requests --filters "Name=state,Values=active" "Name=launch.image-id,Values=ami-0fc970315c2d38f01"| jq -r .SpotInstanceRequests[].SpotInstanceRequestId)
aws ec2 cancel-spot-instance-requests --spot-instance-request-ids $srv
