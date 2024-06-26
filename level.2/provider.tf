terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.0.0"
        }
        random = {
            source = "hashicorp/random"
        }
    }

    backend "s3" {
        bucket          = "terraform-remote-state-730335548094"
        key             = "level2.tfstate"
        region          = "us-east-1"
        dynamodb_table  = "tf-remote-state"
    }
}

provider "aws" {
    region = var.region
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}
