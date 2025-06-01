resource "aws_apigatewayv2_api" "grafana" {
  name          = "${var.name_prefix}-grafana"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "grafana_production" {
  api_id      = aws_apigatewayv2_api.grafana.id
  name        = "production"
  auto_deploy = true

  default_route_settings {
    throttling_rate_limit  = 10
    throttling_burst_limit = 10
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigatewayv2_grafana_production.arn
    format = jsonencode(
      {
        error          = "$context.integrationErrorMessage"
        httpMethod     = "$context.httpMethod"
        ip             = "$context.identity.sourceIp"
        protocol       = "$context.protocol"
        requestId      = "$context.requestId"
        requestTime    = "$context.requestTime"
        responseLength = "$context.responseLength"
        routeKey       = "$context.routeKey"
        status         = "$context.status"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "grafana_lambda" {
  api_id           = aws_apigatewayv2_api.grafana.id
  integration_type = "AWS_PROXY"

  integration_method     = "POST"
  integration_uri        = aws_lambda_function.grafana.invoke_arn
  payload_format_version = "2.0"

  request_parameters = {
    // this removes stage name from the actual request path
    "overwrite:path" = "$request.path"
  }
}

resource "aws_apigatewayv2_route" "grafana_default" {
  api_id    = aws_apigatewayv2_api.grafana.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.grafana_lambda.id}"
}
