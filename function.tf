resource "aws_lambda_function" "grafana" {
  function_name = "${var.name_prefix}-grafana"
  role          = aws_iam_role.grafana.arn

  package_type  = "Image"
  image_uri     = "ghcr.io/coord-e/grafana-lambda:12.0.1"
  architectures = ["x86_64"]
  timeout       = 120
  memory_size   = 1024

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.grafana.id]
  }

  environment {
    variables = {
      X_EXPORT_FROM_SSM = var.ssm_parameter_prefix

      GF_DEFAULT_SNAPSHOTS_EXTERNAL_ENABLED = "false"
      GF_SERVER_ROOT_URL                    = "https://${var.app_domain}/"

      GF_DATABASE_TYPE     = "postgres"
      GF_DATABASE_HOST     = "${aws_rds_cluster.grafana.endpoint}:5432"
      GF_DATABASE_SSL_MODE = "require"
      GF_DATABASE_NAME     = var.grafana_database_name
      GF_DATABASE_USER     = var.grafana_database_user

      GF_UNIFIED_ALERTING_ENABLED = "false"

      GF_SECURITY_CSRF_TRUSTED_ORIGINS = var.app_domain

      METRICS_FORWARDER_REMOTE_URL = "${data.aws_prometheus_workspace.prometheus.prometheus_endpoint}/api/v1/remote_write"
      METRICS_FORWARDER_INTERVAL   = "30s"
    }
  }
}

resource "aws_lambda_permission" "grafana_apigatewayv2" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.grafana.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_stage.grafana_production.execution_arn}/$default"
}
