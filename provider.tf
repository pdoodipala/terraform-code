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
  access_key = "AKIATVGY6G6PJRUUEPP5"
  secret_key = "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"
}