variable "environment" {
    description = "Environment name (dev, staging, prod)"
    type        = string
    default     = "dev"
}

variable "region" {
    description = "AWS region"
    type        = string
    default     = "eu-west-2"
}

# VPC Configuration
variable "vpc_cidr" {
    description = "CIDR block for VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "azs" {
    description = "Availability zones"
    type        = list(string)
    default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

# Subnet Configuration
variable "public_subnet_cidrs" {
    description = "CIDR blocks for public subnets"
    type        = list(string)
    default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
    description = "CIDR blocks for private subnets"
    type        = list(string)
    default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

# Aurora
variable "db_master_username" {
    description = "Master username for the Aurora cluster"
    type = string
    sensitive = true
}

variable "db_master_password" {
    description = "Master password for the Aurora cluster"
    type = string
    sensitive = true

    validation {
        condition = length(var.db_master_password) >= 8
        error_message = "The master password must be at least 8 characters long"
    }
}

# Monitoring
variable "alert_email" {
    description = "Email address for monitoring alerts"
    type = string
}