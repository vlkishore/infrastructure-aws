resource "aws_lb" "elb" {
  depends_on         = [aws_s3_bucket_policy.s3_policy_attachment]
  name               = local.name
  internal           = var.internal
  load_balancer_type = var.elb_type
  security_groups    = var.elb_type != "network" ? var.security_group_ids : null
  subnets            = var.subnet_ids

  dynamic "access_logs" {
    for_each = var.access_logs != null ? [1] : []
    content {
      bucket  = var.access_logs.bucket
      prefix  = "${var.access_logs.bucket}/${local.name}"
      enabled = var.access_logs.enabled
    }
  }

  tags = merge({
    Name = local.name
    },
  var.tags)
}

data "aws_elb_service_account" "elb_account_id" {}
data "aws_iam_policy_document" "s3_policy" {
  count = var.access_logs != null ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${var.access_logs.bucket}/${local.name}/AWSLogs/${var.aws_account}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.elb_account_id.arn]
    }
  }

}

resource "aws_s3_bucket_policy" "s3_policy_attachment" {
  count  = var.access_logs != null ? 1 : 0
  bucket = var.access_logs.bucket
  policy = data.aws_iam_policy_document.s3_policy[0].json
}

resource "aws_lb_listener" "listner_fwd" {
  for_each          = var.listners_fwd != null ? { for k, v in var.listners_fwd : v.port => v } : {}
  load_balancer_arn = aws_lb.elb.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.protocol == "HTTPS" || each.value.protocol == "TLS" ? each.value.ssl_policy : null
  certificate_arn   = each.value.protocol == "HTTPS" || each.value.protocol == "TLS" ? each.value.ssl_cert_arn : null

  default_action {
    type             = "forward"
    target_group_arn = each.value.tg_arn
  }
}

resource "aws_lb_listener" "listner_redirect" {
  for_each          = var.listners_redirect != null ? { for k, v in var.listners_redirect : v.lsn_port => v } : {}
  load_balancer_arn = aws_lb.elb.arn
  port              = each.value.lsn_port
  protocol          = each.value.lsn_protocol

  default_action {
    type = "redirect"

    redirect {
      port        = each.value.fwd_port
      protocol    = each.value.fwd_protocol
      status_code = each.value.status_code
    }
  }
}

resource "aws_lb_listener" "listners_main" {
  for_each          = var.listners_main != null ? { for k, v in var.listners_main : v.lsn_port => v } : {}
  load_balancer_arn = aws_lb.elb.arn
  port              = each.value.lsn_port
  protocol          = each.value.lsn_protocol
  ssl_policy        = each.value.ssl_policy
  certificate_arn   = each.value.ssl_cert_arn

  # default_action {
  #   type = "fixed-response"

  #   fixed_response {
  #     content_type = "text/plain"
  #     message_body = "Fixed response content"
  #     status_code  = "503"
  #   }
  # }
  default_action {
    type             = "forward"
    target_group_arn = each.value.tg_arn
  }
}
