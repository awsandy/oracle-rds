# File generated by aws2tf see https://github.com/aws-samples/aws2tf
resource "aws_iam_role_policy_attachment" "rds-monitoring-role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.rds-monitoring-role.id
}