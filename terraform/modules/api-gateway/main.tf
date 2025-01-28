# WebSocket API
resource "aws_apigatewayv2_api" "websocket_api" {
    name = "${var.environment}-${var.api_name}"
    protocol_type = "WEBSOCKET"
    route_selection_expression = "$request.body.action"

    tags = {
        Environment = var.environment
        Name = "${var.environment}-${var.api_name}"
        Terraform = "true"
    }
}

# WebSocket Routes
resource "aws_apigatewayv2_route" "connect_route" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    route_key = "$connect"
    target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "disconnect_route" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    route_key = "$disconnect"
    target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "alert_route" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    route_key = "alert"
    target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Lambda Integration
resource "aws_apigatewayv2_integration" "lambda_integration" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    integration_type = "AWS_PROXY"
    integration_uri = var.lambda_function_arn
    integration_method = "POST"
    description = "Lambda integration for WebSocket API"
}

# Route Responses
resource "aws_apigatewayv2_route_response" "connect_route_response" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    route_id = aws_apigatewayv2_route.connect_route.id
    route_response_key = "$default"
}

resource "aws_apigatewayv2_route_response" "disconnect_route_response" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    route_id = aws_apigatewayv2_route.disconnect_route.id
    route_response_key = "$default"
}

resource "aws_apigatewayv2_route_response" "alert_route_response" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    route_id = aws_apigatewayv2_route.alert_route.id
    route_response_key = "$default"
}

# API Stage
resource "aws_apigatewayv2_stage" "stage" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    name = var.environment
    description = "${title(var.environment)} Stage for WebSocket API"
    auto_deploy = true

    tags = {
        Environment = var.environment
        Name = "${var.environment}-stage"
        Terraform = "true"
    }
}

# VPC Endpoint
resource "aws_vpc_endpoint" "api_endpoint" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.eu-west-2.execute-api"
    vpc_endpoint_type = "Interface"
    subnet_ids = var.private_subnet_ids
    security_group_ids = [var.endpoint_security_group_id]

    tags = {
        Environment = var.environment
        Name = "${var.environment}-api-endpoint"
        Terraform = "true"
    }
}