terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.0.0"
}

# Variable
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "github_personal_access_token" {}
variable "aws_default_region" {
    default = "ap-northeast-1"
}
variable "aws_account_id" {}
variable "image_repo_name" {}
variable "image_tag" {}
variable "dockerhub_user" {}
variable "dockerhub_pass" {}
variable "fabric-ca_repo_url" {}
variable "db_user" {}
variable "db_password" {}
variable "db_name" {}

# Provider
provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.aws_default_region
  default_tags {
    tags = {
      Managed = "terraform"
    }
  }
}
