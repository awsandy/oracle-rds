aws ec2 run-instances --launch-template LaunchTemplateId=lt-0db16b0b2b75747ec \
--count 1  | jq .
