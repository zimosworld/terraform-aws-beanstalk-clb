Terraform module to provision AWS Elastic Beanstalk environment with a classic load balancer.

NOTE: This requires terraform version >= 0.12

## Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|

Coming soon.

## Module Outputs

| Name | Description |
|------|-------------|
|id|ID of the Elastic Beanstalk environment.|
|name|Name of the Elastic Beanstalk Environment.|
|description|Description of the Elastic Beanstalk Environment.|
|tier|The environment tier specified.|
|application|The Elastic Beanstalk Application specified for this environment.|
|all_settings|List of all option settings configured in the Environment. These are a combination of default settings and their overrides from setting in the configuration.|
|cname|Fully qualified DNS name for the Environment.|
|autoscaling_groups|The autoscaling groups used by this environment.|
|instances|Instances used by this environment.|
|launch_configurations|Launch configurations in use by this environment.|
|load_balancers|Elastic load balancers in use by this environment.|
|queues|SQS queues in use by this environment.|
|triggers|Autoscaling triggers in use by this environment.|