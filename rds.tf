variable "rds_password" {
  description = "RDS で使うパスワード"
  type        = string
}

resource "aws_db_instance" "kdg_database" {
  # DB の名前
  identifier = "aoiorio-kdg-database"

  # RDS で使う DBの種類とバージョン
  engine               = "postgres"
  engine_version       = "17.4"
  parameter_group_name = "default.postgres17"

  # DB のインスタンスの種類(CPU, メモリ, disk size)
  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  # 追加の費用が掛かることを防止するため snapshot と Performance Insights は無効にする
  skip_final_snapshot          = false
  copy_tags_to_snapshot        = false
  storage_encrypted            = false
  performance_insights_enabled = false

  # 可用性関連の設定
  # 無料枠で収めるため今回は可用性の低い設定を許容する
  multi_az = false

  # DB への接続に必要な情報
  username = "postgres"
  password = var.rds_password
  port     = 5432
  #   5432 へのアクセスを許可するような security group を作成して指定する
  vpc_security_group_ids = [aws_security_group.rds_enable.id]
  publicly_accessible = true

  # セキュリティ関連
  ca_cert_identifier = "rds-ca-rsa4096-g1"
}