output "websocket_api_id" {
    description = "ID of the WebSocket API"
    value = aws_apigatewayv2_api.websocket_api.id
}

output "websocket_api_endpoint" {
    description = "Endpoint URL of the WebSocket API"
    value = aws_apigatewayv2_stage.stage.invoke_url
}

output "websocket_api_execution_arn" {
    description = "Execution ARN of WebSocket API"
    value = aws_apigatewayv2_api.websocket_api.execution_arn
}

output "vpc_endpoint_id" {
    description = "ID of the VPC endpoint"
    value = aws_vpc_endpoint.api_endpoint.id
}

output "vpc_endpoint_dns_names" {
    description = "DNS entries for the VPC endpoint"
    value = aws_vpc_endpoint.api_endpoint.dns_entry
}