# Secrets Manager

resource "aws_secretsmanager_secret" "app" {
  count = length(var.secrets)

  name                    = "${local.name_prefix}-${var.secrets[count.index]}"
  recovery_window_in_days = 7

  tags = local.common_tags
}
