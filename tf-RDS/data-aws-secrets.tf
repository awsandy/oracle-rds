data "aws_secretsmanager_secret_version" "creds" {
  # Fill in the name you gave to your secret
  secret_id = "db-config"
}
locals {
  db_config = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

