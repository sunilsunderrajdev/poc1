resource "aws_api_gateway_rest_api" "poc_rest_api" {
    name        = "poc-rest-api"
    description = "Proxy to handle requests to our API"
}

resource "aws_api_gateway_resource" "updatestatus_resource" {
    rest_api_id = aws_api_gateway_rest_api.poc_rest_api.id
    parent_id   = aws_api_gateway_rest_api.poc_rest_api.root_resource_id
    path_part   = "updatestatus"
}

resource "aws_api_gateway_method" "updatestatus_method" {
    rest_api_id     = aws_api_gateway_rest_api.poc_rest_api.id
    resource_id     = aws_api_gateway_resource.updatestatus_resource.id
    http_method     = "POST"
    authorization   = "NONE"
}

resource "aws_api_gateway_integration" "poc_rest_api_integration" {
    rest_api_id = aws_api_gateway_rest_api.poc_rest_api.id
    resource_id = aws_api_gateway_resource.updatestatus_resource.id
    http_method = aws_api_gateway_method.updatestatus_method.http_method

    integration_http_method = "POST"
    type                    = "AWS"
    credentials             = aws_iam_role.apiSQS.arn
    uri                     = "arn:aws:sqs:${var.region}:${var.account}:sqs.path/${aws_sqs_queue.userstatus_sqs.name}"

    request_parameters = {
        "integration.request.path.proxy" = "method.request.path.proxy"
        "intergration.request.header.Content-Type" = "'application/json'"
    }
}

resource "aws_api_gateway_deployment" "poc_rest_api_deployment" {
    depends_on  = aws_api_gateway_integration.poc_rest_api_integration
    rest_api_id = aws_api_gateway_rest_api.poc_rest_api
    stage_name  = var.env_code
}
