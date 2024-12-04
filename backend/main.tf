terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
    version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.region
}
module "tfm_module_s3" {
    source = "./modules/"

  iam_user_name = var.iam_user_name
  bucket_name = var.bucket_name
  table_name = var.table_name

}

terraform {
  backend "s3" {
    bucket = "aws-tfm-bkt"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table ="aws_tfm_table"
    }
}