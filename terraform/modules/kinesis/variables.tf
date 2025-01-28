variable "environment" {
    description = "Environment name for resource tagging"
    type = string
}

variable "vpc_id" {
    description = "ID of the VPC"
    type = string
}

variable "private_subnet_ids" {
    description = "List of private subnet IDs"
    type = list(string)
}

variable "endpoint_security_group_id" {
    description = "Security group ID for VPC endpoints"
    type = string
}

variable "shard_count" {
    description = "Number of shards for the Kinesis stream"
    type = number
    default = 20
}

variable "retention_period" {
    description = "Data retention period in hours"
    type = number
    default = 24
}
