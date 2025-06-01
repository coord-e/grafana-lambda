resource "aws_rds_cluster" "grafana" {
  cluster_identifier              = "${var.name_prefix}-grafana"
  master_username                 = "root"
  master_password                 = "pasuwa-do"
  backup_retention_period         = 7
  db_cluster_parameter_group_name = "default.aurora-postgresql16"
  db_subnet_group_name            = var.db_subnet_group_name
  engine_mode                     = "provisioned"
  engine                          = "aurora-postgresql"
  engine_version                  = "16.6"
  preferred_backup_window         = "18:00-19:00"
  preferred_maintenance_window    = "sun:20:00-sun:21:00"
  apply_immediately               = true
  copy_tags_to_snapshot           = true
  skip_final_snapshot             = false
  final_snapshot_identifier       = "grafana-final"

  vpc_security_group_ids = [
    aws_security_group.rds_grafana.id
  ]

  serverlessv2_scaling_configuration {
    min_capacity             = 0.0
    max_capacity             = 5.0
    seconds_until_auto_pause = 60 * 60
  }
}

resource "aws_rds_cluster_instance" "grafana_001" {
  cluster_identifier         = aws_rds_cluster.grafana.id
  identifier                 = "${var.name_prefix}-grafana-001"
  instance_class             = "db.serverless"
  db_parameter_group_name    = "default.aurora-postgresql16"
  engine                     = aws_rds_cluster.grafana.engine
  ca_cert_identifier         = "rds-ca-ecc384-g1"
  auto_minor_version_upgrade = true
  apply_immediately          = true
}
