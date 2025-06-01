resource "aws_cloudwatch_log_group" "lambda_grafana" {
  name              = "/aws/lambda/${var.name_prefix}-grafana"
  retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "apigatewayv2_grafana_production" {
  name              = "/apigatewayv2/${var.name_prefix}-grafana/production"
  retention_in_days = 365
}
