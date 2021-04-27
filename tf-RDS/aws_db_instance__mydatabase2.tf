# File generated by aws2tf see https://github.com/aws-samples/aws2tf
# aws_db_instance.mydatabase:
#
# Multi az Creation time ~ 21 minutes
# Destroy 7m 30s
#
resource "aws_db_instance" "rds-multiaz2" {
  allocated_storage          = 128
  auto_minor_version_upgrade = false
  backup_retention_period    = 3
  backup_window              = "22:43-23:13"
  ca_cert_identifier         = "rds-ca-2019"
  character_set_name         = "AL32UTF8"
  copy_tags_to_snapshot      = true
  #db_subnet_group_name = "default"
  delete_automated_backups = true
  deletion_protection      = false
  enabled_cloudwatch_logs_exports = [
    "alert",
    "audit",
  ]
  engine                              = "oracle-ee"
  engine_version                      = "19.0.0.0.ru-2021-01.rur-2021-01.r2"
  iam_database_authentication_enabled = false
  identifier                          = "dwp-demo-ha2-az2"
  instance_class                      = "db.m5.2xlarge"
  storage_type         = "io1"
  iops                                = 3000
  kms_key_id = "arn:aws:kms:eu-west-2:773555691132:key/e8ad345a-745d-4f55-aa2c-ab4c6855fc86"
  license_model         = "bring-your-own-license"
  maintenance_window    = "sun:01:26-sun:01:56"
  max_allocated_storage = 1000
  monitoring_interval   = 60
  monitoring_role_arn   = format("arn:aws:iam::%s:role/rds-dwp-monitoring-role", data.aws_caller_identity.current.account_id)

  multi_az                     = true
  name                         = "ORCL"
  option_group_name            = "default:oracle-ee-19"
  parameter_group_name         = "default.oracle-ee-19"
  performance_insights_enabled = true
  performance_insights_kms_key_id = "arn:aws:kms:eu-west-2:773555691132:key/e8ad345a-745d-4f55-aa2c-ab4c6855fc86"
  performance_insights_retention_period = 7
  port                                  = 1521
  publicly_accessible                   = false

  security_group_names = []
  skip_final_snapshot  = true
  storage_encrypted    = true


  tags                 = {}
  username = local.db_creds.username
  password = local.db_creds.password
  vpc_security_group_ids = [
    data.aws_security_group.sg-ora.id,
  ]

  timeouts {}
}
