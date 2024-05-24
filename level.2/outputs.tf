output "apigateway_url" {
    value = aws_api_gateway_deployment.poc_rest_api_deployment.invoke_url
}
