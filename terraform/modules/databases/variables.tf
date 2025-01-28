variable "environment" {
    description = "Environment name for resource tagging"
    type = string
}

variable "vpc_id" {
    description = "ID of the VPC"
    type = string
}

variable "vpc_cidr" {
    description = "CIDR block of the VPC"
    type = string
}

variable "private_subnet_ids" {
    description = "List of private subnet IDs"
    type = list(string)
}

variable "private_route_table_ids" {
    description = "List of private route table IDs"
    type = list(string)
}

# Aurora specific variables
variable "database_name" {
    description = "Name of the Aurora database"
    type = string
    default = "hftdb"
}

variable "master_username" {
    description = "Master username for the Aurora cluster"
    type = string
    sensitive = true
}

variable "master_password" {
    description = "Master password for the Aurora cluster"
    type = string
    sensitive = true
}

variable "instance_class" {
    description = "Instance class for Aurora instances"
    type = string
    default = "db.r5.large"
}

variable "instance_count" {
    description = "Number of Aurora instances"
    type = number
    default = 2
}
