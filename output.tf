#--------------------------------------------------------------
#
# Beanstalk Environment Output
#
#--------------------------------------------------------------

output "id" {
  description = "ID of the Elastic Beanstalk environment."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.id
}

output "name" {
  description = "Name of the Elastic Beanstalk Environment."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.name
}

output "description" {
  description = "Description of the Elastic Beanstalk Environment."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.description
}

output "tier" {
  description = "The environment tier specified."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.tier
}

output "application" {
  description = "The Elastic Beanstalk Application specified for this environment."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.application
}

output "all_settings" {
  description = "List of all option settings configured in the Environment. These are a combination of default settings and their overrides from setting in the configuration."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.all_settings
}

output "cname" {
  description = "Fully qualified DNS name for the Environment."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.cname
}

output "autoscaling_groups" {
  description = "The autoscaling groups used by this environment."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.autoscaling_groups
}

output "instances" {
  description = "Instances used by this environment."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.instances
}

output "launch_configurations" {
  description = "Launch configurations in use by this environment."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.launch_configurations
}

output "load_balancers" {
  description = "Elastic load balancers in use by this environment."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.load_balancers
}

output "queues" {
  description = "SQS queues in use by this environment."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.queues
}

output "triggers" {
  description = "Autoscaling triggers in use by this environment."
  value       = aws_elastic_beanstalk_environment.beanstalk_environment.triggers
}

