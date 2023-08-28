terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
  access_key = "AKIATVGY6G6PDO4OWIUQ"
  secret_key = "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"
}