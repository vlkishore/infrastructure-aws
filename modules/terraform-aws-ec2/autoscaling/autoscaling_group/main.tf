resource "aws_autoscaling_group" "asg" {

  name                  = "${var.name}-asg"
  desired_capacity      = var.desired_capacity
  max_size              = var.max_size
  min_size              = var.min_size
  vpc_zone_identifier   = var.subnet_ids
  target_group_arns     = var.tg_arn != null ? var.tg_arn : null
  wait_for_elb_capacity = var.wait_for_elb_capacity ? var.desired_capacity : null

  launch_template {
    id      = var.lt_id
    version = var.lt_version != null ? var.lt_version : "$Latest"
  }

  dynamic "instance_refresh" {
    for_each = var.enable_instance_refresh ? [1] : []
    content {
      strategy = "Rolling"
      triggers = ["tag"]
      preferences {
        min_healthy_percentage = var.healthy_percent
      }
    }
  }

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "${var.name}-asg"
        "propagate_at_launch" = true
      },
    ],
    local.asg_tags
  )
}

# # scale out - day
# resource "aws_autoscaling_schedule" "asg_scale_out" {
#   count                 = var.asg_scale_out_cron != null ? 1 : 0
#   scheduled_action_name = "scale-out-during-business-hours"
#   min_size              = var.min_size
#   max_size              = var.max_size
#   desired_capacity      = var.desired_capacity
#   recurrence            = var.asg_scale_out_cron
  
#   autoscaling_group_name = aws_autoscaling_group.asg.name
# }

# # scale in - night
# resource "aws_autoscaling_schedule" "asg_scale_in" {
#   count                 = var.asg_scale_in_cron != null ? 1 : 0
#   scheduled_action_name = "scale-in-at-night"
#   min_size              = 0
#   max_size              = 0
#   desired_capacity      = 0
#   recurrence            = var.asg_scale_in_cron
 
#   autoscaling_group_name = aws_autoscaling_group.asg.name
# }

resource "aws_autoscaling_policy" "asg_scaling_policy" {
  # count                  = var.asg_scaling_cpu_utilization != null ? 1 : 0
  name                   = "${var.name}-asg-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name        
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "85.0"
  }
}