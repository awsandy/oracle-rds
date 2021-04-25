terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.26"
    }
  }
}

provider "aws" {
  region                  = "eu-west-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}
