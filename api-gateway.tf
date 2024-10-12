# API Gateway WebSocket API
resource "aws_apigatewayv2_api" "websocket_api" {
    name = "HealthAlertWebSocketAPI"
    protocol_type = "WEBSOCKET"
    route_selection_expression = "$request.body.action"
}

# WebSocket Routes 
resource "aws_apigatewayv2_route" "connect_route" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    route_key = "$connect"
}

resource "aws_apigatewayv2_route" "disconnect_route" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    route_key = "$disconnect"
}

resource "aws_apigatewayv2_route" "alert_route" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    route_key = "$alert"
}

# Create Integration to allow API Gateway to invoke Lambda function to send alerts
resource "aws_apigatewayv2_integration" "lambda_integration" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    integration_type = "AWS_PROXY"
    connection_type = "INTERNET"
    integration_uri = aws_lambda_function.edge_healthcare_lambda.arn
    integration_method = "POST"
}

# Attach Integration to Routes
resource "aws_apigatewayv2_route_response" "connect_route_response" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    route_id = aws_apigatewayv2_route.connect_route.id
    route_response_key = aws_apigatewayv2_route.connect_route.route_key
}

resource "aws_apigatewayv2_route_response" "disconnect_route_response" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    route_id = aws_apigatewayv2_route.disconnect_route.id
    route_response_key = aws_apigatewayv2_route.disconnect_route.route_key
}

resource "aws_apigatewayv2_route_response" "alert_route_response" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    route_id = aws_apigatewayv2_route.alert_route.id
    route_response_key = aws_apigatewayv2_route.alert_route.route_key
}

# Deploy WebSocket API
resource "aws_apigatewayv2_stage" "dev_stage" {
    api_id = aws_apigatewayv2_api.websocket_api.id
    name = "dev"
    description = "Development Stage for WebSocket API"
    auto_deploy = true
}

# API Gateway VPC Interface Endpoint
resource "aws_vpc_endpoint" "api_endpoint" {
  vpc_id = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.eu-west-2.execute-api"  
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.endpoint_sg.id]  
}