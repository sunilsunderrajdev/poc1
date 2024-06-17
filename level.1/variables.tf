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

variable "intra_subnets" {
    type        = list(string)
    description = "VPC Intranet Subnets"
}

variable "env_code" {
    type = string
}
