resource "aws_api_gateway_rest_api" "poc_rest_api" {
    name        = "poc-rest-api"
    description = "Proxy to handle requests to our API and send to SQS"
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

    type                    = "AWS"
    integration_http_method = "POST"
    passthrough_behavior    = "NEVER"
    credentials             = aws_iam_role.apigtw_role.arn
    uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${aws_sqs_queue.userstatus_sqs.name}"

    request_parameters = {
        "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
    }

    request_templates = {
        "application/json" = "Action=SendMessage&MessageBody=$input.body"
    }

    # Request Template for passing Method, Body, QueryParameters and PathParams to SQS messages
    #request_templates = {
    #    "application/json" = <<EOF
#Action=SendMessage&MessageBody={
    #"method": "$context.httpMethod",
    #"body-json" : $input.json('$'),
    #"pathParams": {
    #    #foreach($param in $input.params().path.keySet())
    #    "$param": "$util.escapeJavaScript($input.params().path.get($param))" #if($foreach.hasNext),#end
    #    #end
    #}
#}"
#EOF
#        }

        depends_on = [
            aws_iam_role_policy_attachment.apigtw_role_policy
        ]
}

resource "aws_api_gateway_method_response" "http200" {
    rest_api_id = aws_api_gateway_rest_api.poc_rest_api.id
    resource_id = aws_api_gateway_resource.updatestatus_resource.id
    http_method = aws_api_gateway_method.updatestatus_method.http_method
    status_code = 200
}

resource "aws_api_gateway_integration_response" "http200" {
    rest_api_id       = aws_api_gateway_rest_api.poc_rest_api.id
    resource_id       = aws_api_gateway_resource.updatestatus_resource.id
    http_method       = aws_api_gateway_method.updatestatus_method.http_method
    status_code       = aws_api_gateway_method_response.http200.status_code
    selection_pattern = "^2[0-9][0-9]"     // regex pattern for any 200 message that comes back from SQS

    depends_on = [
        aws_api_gateway_integration.poc_rest_api_integration
    ]
}

#resource "aws_api_gateway_method_settings" "YOUR_settings" {
#    rest_api_id = aws_api_gateway_rest_api.poc_rest_api.id
#    stage_name  = var.env_code
#    method_path = "*/*"
#    settings {
#        logging_level = "INFO"
#        data_trace_enabled = true
#        metrics_enabled = true
#    }
#}

resource "aws_api_gateway_deployment" "poc_rest_api_deployment" {
    rest_api_id = aws_api_gateway_rest_api.poc_rest_api.id
    stage_name  = var.env_code

    depends_on = [
        aws_api_gateway_integration.poc_rest_api_integration,
    ]

    # Redeploy when there are new updates
    triggers = {
    #    redeployment = sha1(join(",", tolist(
    #    jsonencode(aws_api_gateway_integration.poc_rest_api_integration),
    #    )))
        redeployment = sha1(jsonencode(aws_api_gateway_rest_api.poc_rest_api.body))
    }

    lifecycle {
        create_before_destroy = true
    }
}
