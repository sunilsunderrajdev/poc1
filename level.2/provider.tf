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
    #config_path    = "~/.kube/config"
  host                      = module.eks.cluster_endpoint
  cluster_ca_certificate    = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}
