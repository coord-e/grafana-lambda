data "aws_prometheus_workspace" "prometheus" {
  workspace_id = var.prometheus_workspace_id
}
