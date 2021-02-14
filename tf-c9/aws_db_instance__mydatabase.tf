# File generated by aws2tf see https://github.com/aws-samples/aws2tf
# aws_db_instance.nydatabase:

resource "random_password" "password" {
  length = 16
  special = false
  override_special = "!%@"
}


resource "aws_db_instance" "mydatabase" {
  allocated_storage          = 20
  auto_minor_version_upgrade = false
  backup_retention_period    = 7
  backup_window              = "22:43-23:13"
  ca_cert_identifier         = "rds-ca-2019"
  character_set_name         = "AL32UTF8"
  copy_tags_to_snapshot      = true
  #db_subnet_group_name       = "default-vpc-99b56ae0"
  delete_automated_backups   = true
  deletion_protection        = false
  enabled_cloudwatch_logs_exports = [
    "alert",
    "audit",
  ]
  engine                                = "oracle-ee"
  engine_version                        = "18.0.0.0.ru-2020-10.rur-2020-10.r1"
  iam_database_authentication_enabled   = false
  identifier                            = "mydatabase"
  instance_class                        = "db.m5.large"
  iops                                  = 0
  #kms_key_id                            = "arn:aws:kms:eu-west-1:304510202725:key/108bdc0c-386d-42af-96d0-a652390c962d"
  license_model                         = "bring-your-own-license"
  maintenance_window                    = "sun:01:26-sun:01:56"
  max_allocated_storage                 = 1000
  monitoring_interval                   = 60
  monitoring_role_arn                   = format("arn:aws:iam::%s:role/rds-monitoring-role",data.aws_caller_identity.current.account_id)
  multi_az                              = false
  name                                  = "ORCL"
  option_group_name                     = "default:oracle-ee-18"
  parameter_group_name                  = "default.oracle-ee-18"
  performance_insights_enabled          = true
  #performance_insights_kms_key_id       = "arn:aws:kms:eu-west-1:304510202725:key/108bdc0c-386d-42af-96d0-a652390c962d"
  performance_insights_retention_period = 7
  port                                  = 1521
  publicly_accessible                   = true
  security_group_names                  = []
  skip_final_snapshot                   = true
  storage_encrypted                     = true
  storage_type                          = "gp2"
  tags                                  = {}
  username                              = "oraadmin"
  password=random_password.password.result
  vpc_security_group_ids = [
    aws_security_group.sg-086bfef57ba61eb11.id,
  ]

  timeouts {}
}