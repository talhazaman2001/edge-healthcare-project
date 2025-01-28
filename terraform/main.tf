# API Gateway Module
module "api-gateway" {
    source = "./modules/api-gateway"

    environment = var.environment
    lambda_function_arn = module.lambda.function_arns["edge_healthcare"]
    vpc_id = module.vpc.vpc_id
    endpoint_security_group_id = module.vpc.vpc_endpoint_sg_id
    private_subnet_ids = module.vpc.private_subnet_ids
}

# Database Module
module "databases" {
    source = "./modules/databases"

    environment = var.environment
    vpc_id = module.vpc.vpc_id
    vpc_cidr = var.vpc_cidr
    private_route_table_ids = module.vpc.private_route_table_ids
    private_subnet_ids = module.vpc.private_subnet_ids
    
    # Aurora Configuration
    database_name     = "hftdb"
    master_username   = var.db_master_username
    master_password   = var.db_master_password
    instance_class    = "db.r5.large"
    instance_count    = 2
}


# IoT Module
module "iot" {
    source = "./modules/iot"

    environment = var.environment
    iot_core_role_arn = module.iam.iot_core_role_arn
    kinesis_stream_name = module.kinesis.stream_name
}

# Kinesis Module
module "kinesis" {
    source = "./modules/kinesis"

    environment = var.environment
    vpc_id = module.vpc.vpc_id
    endpoint_security_group_id = module.vpc.vpc_endpoint_sg_id
    private_subnet_ids = module.vpc.private_subnet_ids
}

# Lambda Module
module "lambda" {
    source = "./modules/lambda"

    environment = var.environment
    endpoint_security_group_id = module.vpc.vpc_endpoint_sg_id
    private_subnet_ids = module.vpc.private_subnet_ids
    vpc_id = module.vpc.vpc_id
    kinesis_stream_arn = module.kinesis.stream_arn
    lambda_roles = {
        edge_healthcare = module.iam.lambda_execution_role_arn
        greengrass_lstm = module.iam.lambda_execution_role_arn
        sagemaker_training = module.iam.lambda_sagemaker_training_role_arn
        sagemaker_neo = module.iam.lambda_sagemaker_neo_role_arn
        greengrass_creation = module.iam.lambda_greengrass_role_arn
    }

    lambda_source_dir = "${path.root}/lambda"
}

# Monitoring Module
module "monitoring" {
    source = "./modules/monitoring"

    environment = var.environment
    vpc_id = module.vpc.vpc_id
    endpoint_security_group_id = module.vpc.vpc_endpoint_sg_id
    private_subnet_ids = module.vpc.private_subnet_ids
    lambda_function_name = module.lambda.function_names["edge_healthcare"]
    alert_email = var.alert_email 
    log_retention_days = 30
}

# SageMaker IAM Module
module "sagemaker_iam" {
    source = "./modules/sagemaker_iam"

    environment = var.environment
}

# SageMaker Module
module "sagemaker" {
    source = "./modules/sagemaker"

    environment = var.environment
    private_subnet_ids = module.vpc.private_subnet_ids
    endpoint_security_group_id = module.vpc.vpc_endpoint_sg_id
    vpc_id = module.vpc.vpc_id
    model_bucket_name = module.s3.sagemaker_bucket_id
    sagemaker_execution_role_arn = module.sagemaker_iam.sagemaker_execution_role_arn
    sagemaker_bucket_id = module.s3.sagemaker_bucket_id
}

# IAM Module
module "iam" {
    source = "./modules/iam"

    environment = var.environment
    dynamodb_table_arn = module.databases.dynamodb_table_arn
    api_gateway_execution_arn = module.api-gateway.websocket_api_execution_arn
    aurora_cluster_arn = module.databases.aurora_cluster_arn
    iot_bucket_arn = module.s3.iot_bucket_arn
    sagemaker_bucket_arn = module.s3.sagemaker_bucket_arn
    kinesis_stream_arn = module.kinesis.stream_arn
    greengrass_log_group_arn = module.monitoring.greengrass_log_group_arn
    greengrass_log_stream_arn = module.monitoring.greengrass_log_stream_arn
}

# Endpoint Policies Module
module "endpoint_policies" {
    source = "./modules/endpoint_policies"

    environment = var.environment
    sagemaker_endpoint_arn = module.sagemaker.endpoint_arn
    greengrass_role_name  = module.iam.greengrass_role_name
}

# S3 Module
module "s3" {
    source = "./modules/s3"

    environment = var.environment
    vpc_id = module.vpc.vpc_id
    private_route_table_ids = module.vpc.private_route_table_ids
}

# VPC Module
module "vpc" {
    source = "./modules/vpc"

    environment = var.environment
    vpc_cidr = var.vpc_cidr
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    azs = var.azs
}

