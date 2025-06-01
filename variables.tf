variable "name_prefix" {
    type = string
}

variable "iam_role_name" {
    type = string
}

variable "prometheus_workspace_id" {
    type = string
}

variable "app_domain" {
    type = string
}

variable "certificate_arn" {
    type = string
}

variable "db_subnet_group_name" {
    type = string
}

variable "ssm_parameter_prefix" {
    type = string
    default = "/lambda/grafana"
}

variable "ssm_key_arn" {
    type = string
}

variable "grafana_database_name" {
    type = string
}

variable "grafana_database_user" {
    type = string
}

variable "subnet_ids" {
    type = list(string)
}

variable "vpc_id" {
    type = string
}
