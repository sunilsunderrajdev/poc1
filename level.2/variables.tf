variable "region" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "private_subnets" {
    type        = list(string)
    description = "VPC Private Subnets"
}

variable "public_subnets" {
    type        = list(string)
    description = "VPC Public Subnets"
}

variable "env_code" {
    type = string
}

variable "account" {
    type = string
}

variable "domain_name" {
    type = string
}

variable "eks_namespace" {
  type = string
}
