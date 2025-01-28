variable "environment" {
    description = "Environment name for resource tagging"
    type = string
}

variable "vpc_id" {
    description = "ID of the VPC"
    type = string
}

variable "private_route_table_ids" {
    description = "List of private route table IDs"
    type = list(string)
}

variable "data_files_path" {
    description = "Path to the directory containing data files"
    type = string
    default = "./data"
}