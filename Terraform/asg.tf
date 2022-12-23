####
#ASG
####
module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "wajid-asg"

  min_size                  = 1
  max_size                  = 6
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  target_group_arns         = module.alb.target_group_arns

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 500
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  # Launch template
  launch_template_name        = "wajid-asg"
  launch_template_description = "Launch template example"
  update_default_version      = true

  image_id                  = "ami-0b63551bfe4b8d987"
  instance_type             = "t3a.small"
  key_name                  = "wajid2"
  ebs_optimized             = true
  enable_monitoring         = true
  iam_instance_profile_name = "role-wajid"
  security_groups           = [aws_security_group.asg-nodejs-sg-wajid.id]

  tags = {
    Environment = "dev"
    Project     = "test"
  }
}

# Scaling Policy
resource "aws_autoscaling_policy" "asg-policy" {
  count                     = 1
  name                      = "asg-cpu-policy"
  autoscaling_group_name    = module.asg.autoscaling_group_name
  estimated_instance_warmup = 60
  policy_type               = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

#ASG security group
resource "aws_security_group" "asg-nodejs-sg-wajid" {
  name        = "asg-nodejs-sg-wajid"
  description = "Allow traffic for NodeJs server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "asg-nodejs-sg-wajid"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "asg-nodejs-sg-wajid"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "asg-sg-wajid"
  }
}
