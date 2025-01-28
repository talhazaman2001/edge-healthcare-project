# VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name = "${var.environment}-vpc"
        Environment = var.environment
        Terraform = "true"
    }
}

# Public Subnets
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = element(var.public_subnet_cidrs, count.index)
    availability_zone = element(var.azs, count.index)

    map_public_ip_on_launch = true

    tags = {
        Name = "${var.environment}-public-${element(var.azs, count.index)}"
        Environment = var.environment
        Terraform = "true"
        Type = "public"
    }
}

# Private Subnets
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = element(var.private_subnet_cidrs, count.index)
    availability_zone = element(var.azs, count.index)

    tags = {
        Name = "${var.environment}-private-${element(var.azs, count.index)}"
        Environment = var.environment
        Terraform = "true"
        Type = "private"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.environment}-igw"
        Environment = var.environment
        Terraform = "true"
    }
}

# NAT Gateway and EIP
resource "aws_eip" "nat" {
    count = length(var.public_subnet_cidrs)
    domain = "vpc"

    tags = {
        Name = "${var.environment}-nat-eip-${count.index + 1}"
        Environment = var.environment
        Terraform  = "true"
    }
}

resource "aws_nat_gateway" "main" {
    count = length(var.public_subnet_cidrs)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id

    tags = {
        Name = "${var.environment}-nat-${count.index + 1}"
        Environment = var.environment
        Terraform = "true"
    }

    depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "${var.environment}-public-rt"
        Environment = var.environment
        Terraform = "true"
    }
}

resource "aws_route_table" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main[count.index].id
    }

    tags = {
        Name = "${var.environment}-private-rt-${count.index + 1}"
        Environment = var.environment
        Terraform = "true"
    }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidrs)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidrs)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}

# VPC Endpoint Security Group
resource "aws_security_group" "vpc_endpoints" {
    name_prefix = "${var.environment}-vpc-endpoints-"
    vpc_id  = aws_vpc.main.id

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

    tags = {
        Name = "${var.environment}-vpc-endpoints"
        Environment = var.environment
        Terraform = "true"
    }
}
