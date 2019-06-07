#--------------------------------------------------------------
#
# Beanstalk with Classic Load Balancer
#
#--------------------------------------------------------------

#--------------------------------------------------------------
# EC2 IAM
#--------------------------------------------------------------
data "aws_iam_policy_document" "ec2_iam" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "ec2_iam" {
  name               = "${var.name}-ec2"
  assume_role_policy = data.aws_iam_policy_document.ec2_iam.json
}

resource "aws_iam_instance_profile" "ec2_iam" {
  name = "${var.name}-ec2"
  role = aws_iam_role.ec2_iam.name
}

resource "aws_iam_role_policy_attachment" "ec2_iam" {
  count = length(var.ec2_policies)

  role       = aws_iam_role.ec2_iam.name
  policy_arn = var.ec2_policies[count.index]
}

#--------------------------------------------------------------
# Beanstalk Service IAM
#--------------------------------------------------------------
data "aws_iam_policy_document" "beanstalk_iam" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = [
        "elasticbeanstalk.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "beanstalk_iam" {
  name               = "${var.name}-ebs-service"
  assume_role_policy = data.aws_iam_policy_document.beanstalk_iam.json
}

resource "aws_iam_role_policy_attachment" "beanstalk_iam" {
  count      = length(var.beanstalk_policies)

  role       = aws_iam_role.beanstalk_iam.name
  policy_arn = var.beanstalk_policies[count.index]
}

#--------------------------------------------------------------
# Beanstalk
#--------------------------------------------------------------
data "aws_elastic_beanstalk_solution_stack" "default" {
  most_recent = true

  name_regex = "^64bit Amazon Linux (.*) ${var.solution_stack}(.*)$"
}

resource "aws_elastic_beanstalk_environment" "beanstalk_environment" {
  name        = var.name
  application = var.application
  description = var.description

  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.default.name

  wait_for_ready_timeout = var.wait_for_ready_timeout

  tier          = var.tier
  version_label = var.version_label

  lifecycle {
    ignore_changes = [
      tags]
  }

  #===================== Software =====================#

  setting {
    namespace = "aws:elasticbeanstalk:hostmanager"
    name      = "LogPublicationControl"
    value     = var.enable_log_publication_control
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = var.enable_stream_logs
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = var.logs_retention_in_days
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = var.logs_delete_on_terminate
  }

  dynamic "setting" {
    for_each = "${var.env_vars}"

    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = setting.key
      value     = setting.value
    }
  }

  #===================== Instances =====================#

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "MonitoringInterval"
    value     = var.monitoring_interval
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = var.root_volume_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = var.root_volume_size
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = join(",", var.security_groups)
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SSHSourceRestriction"
    value     = "tcp,22,22,${var.ssh_source_restriction}"
  }

  #===================== Capacity =====================#

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = var.environment_type
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.autoscale_min
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.autoscale_max
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Availability Zones"
    value     = var.availability_zones
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "BreachDuration"
    value     = var.autoscale_breach_duration
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Period"
    value     = var.autoscale_period
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "EvaluationPeriods"
    value     = var.evaluation_periods
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = var.autoscale_measure_name
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Statistic"
    value     = var.autoscale_statistic
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = var.autoscale_unit
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold"
    value     = var.autoscale_lower_bound
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerBreachScaleIncrement"
    value     = var.autoscale_lower_increment
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = var.autoscale_upper_bound
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperBreachScaleIncrement"
    value     = var.autoscale_upper_increment
  }

  #===================== Load balancer =====================#

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = var.lb_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = var.healthcheck_url
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "ListenerProtocol"
    value     = var.clb_ssl_listener_protocol
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "InstancePort"
    value     = var.clb_ssl_listener_instance_port
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "PolicyNames"
    value     = var.clb_ssl_listener_policynames
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "SSLCertificateId"
    value     = var.clb_ssl_listener_certificate_arn
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "ListenerEnabled"
    value     = var.clb_ssl_listener_enabled
  }

  setting {
    namespace = "aws:elb:healthcheck"
    name      = "HealthyThreshold"
    value     = var.clb_healthy_threshold
  }

  setting {
    namespace = "aws:elb:healthcheck"
    name      = "Interval"
    value     = var.clb_interval
  }

  setting {
    namespace = "aws:elb:healthcheck"
    name      = "Timeout"
    value     = var.clb_timeout
  }

  setting {
    namespace = "aws:elb:healthcheck"
    name      = "UnhealthyThreshold"
    value     = var.clb_unhealthy_theshold
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "CrossZone"
    value     = var.clb_cross_zone
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = var.clb_security_groups
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = var.clb_managed_security_groups
  }

  setting {
    namespace = "aws:elb:policies"
    name      = "ConnectionDrainingEnabled"
    value     = var.clb_connection_draining_enabled
  }

  setting {
    namespace = "aws:elb:policies"
    name      = "ConnectionDrainingTimeout"
    value     = var.clb_connection_draining_timeout
  }

  setting {
    namespace = "aws:elb:policies"
    name      = "ConnectionSettingIdleTimeout"
    value     = var.clb_connection_setting_idle_timeout
  }

  setting {
    namespace = "aws:elb:policies"
    name      = "LoadBalancerPorts"
    value     = var.clb_loadbalancer_ports
  }

  setting {
    namespace = "aws:elb:policies"
    name      = "Stickiness Cookie Expiration"
    value     = var.clb_stickiness_cookie_expiration
  }

  setting {
    namespace = "aws:elb:policies"
    name      = "Stickiness Policy"
    value     = var.clb_stickiness_policy
  }

  #===================== Rolling updates and deployments =====================#

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = var.deployment_policy
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = var.batch_size_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = var.batch_size
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = var.rolling_update_enabled
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = var.rolling_update_type
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MinInstancesInService"
    value     = var.updating_min_in_service
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MaxBatchSize"
    value     = var.updating_max_batch
  }

  #===================== Security =====================#

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = var.beanstalk_iam == "" ? aws_iam_role.beanstalk_iam.name : var.beanstalk_iam
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.keypair
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = var.eb2_iam_name == "" ? aws_iam_instance_profile.ec2_iam.name : var.eb2_iam_name
  }

  #===================== Monitoring =====================#

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "ConfigDocument"
    value     = var.config_document
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = var.enhanced_reporting_enabled
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "HealthStreamingEnabled"
    value     = var.health_streaming_enabled
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "DeleteOnTerminate"
    value     = var.health_streaming_delete_on_terminate
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "RetentionInDays"
    value     = var.health_streaming_retention_in_days
  }

  //  setting {
  //    namespace = "aws:elasticbeanstalk:environment:process:default"
  //    name      = "HealthCheckPath"
  //    value     = "${var.healthcheck_url}"
  //  }

  #===================== Managed Updates =====================#

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = var.enable_managed_actions
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = var.preferred_start_time
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "UpdateLevel"
    value     = var.update_level
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "InstanceRefreshEnabled"
    value     = var.instance_refresh_enabled
  }

  #===================== Notifications =====================#

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Endpoint"
    value     = var.notification_endpoint
  }

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Protocol"
    value     = var.notification_protocol
  }

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Topic ARN"
    value     = var.notification_topic_arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Topic Name"
    value     = var.notification_topic_name
  }

  #===================== Network =====================#

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = var.environment_type == "LoadBalanced" ? var.elb_scheme : ""
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", var.public_subnets)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = var.associate_public_ip_address
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.private_subnets)
  }

  #===================== Database =====================#

  #===================== Tags =====================#

  tags = var.tags
}

#--------------------------------------------------------------
# Beanstalk DNS
#--------------------------------------------------------------
data "aws_elastic_beanstalk_hosted_zone" "current" {
}

resource "aws_route53_record" "beanstalk" {
  count = var.zone_id == "" ? 0 : length(var.zone_records)

  name    = var.zone_records[count.index]
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_elastic_beanstalk_environment.beanstalk_environment.cname
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = true
  }
}

