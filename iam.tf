resource "aws_iam_role" "grafana" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "CloudWatch"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "cloudwatch:DescribeAlarmsForMetric",
            "cloudwatch:DescribeAlarmHistory",
            "cloudwatch:DescribeAlarms",
            "cloudwatch:ListMetrics",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:GetMetricData",
            "logs:DescribeLogGroups",
            "logs:GetLogGroupFields",
            "logs:StartQuery",
            "logs:GetQueryResults",
            "logs:GetLogEvents",
            "pi:GetResourceMetrics",
          ],
          "Resource" : "*",
        },
      ],
    })
  }

  inline_policy {
    name = "AMP"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "aps:GetLabels",
            "aps:GetMetricMetadata",
            "aps:GetSeries",
            "aps:QueryMetrics",
          ],
          "Resource" : "*",
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "aps:RemoteWrite",
          ],
          "Resource" : data.aws_prometheus_workspace.prometheus.arn,
        },
      ],
    })
  }

  inline_policy {
    name = "SSM"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:GetParameterHistory",
            "ssm:DescribeParameters",
          ],
          "Resource" : [
            "arn:aws:ssm:ap-northeast-1:389602053363:parameter${var.ssm_parameter_prefix}/*",
          ],
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParametersByPath",
          ],
          "Resource" : [
            "arn:aws:ssm:ap-northeast-1:389602053363:parameter${var.ssm_parameter_prefix}",
          ],
        },
      ]
    })
  }

  inline_policy {
    name = "KMS"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "kms:Decrypt",
          ],
          "Resource" : [
            var.ssm_key_arn,
          ],
        },

      ]
    })
  }

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
}
