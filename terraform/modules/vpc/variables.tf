variable "vpc_cidr" {
    description = "CIDR block for VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
    description = "Public Subnet CIDR values"
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
    description = "Private Subnet CIDR values"
    type = list(string)
    default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
    description = "Availability zones"
    type = list(string)
    default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "environment" {
    description = "Environment name for tagging"
    type = string
    default = "dev"
}
