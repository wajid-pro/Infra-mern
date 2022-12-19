module "ec2_instance-vpn" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "pritunl-wajid"

  ami                    = "ami-0530ca8899fac469f"
  instance_type          = "t3a.small"
  key_name               = "wajid2"
  monitoring             = true
  vpc_security_group_ids = [resource.aws_security_group.vpn-sg-wajid.id]
  subnet_id              = module.vpc.public_subnets[0]

  user_data = file("shell-pritunl.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#Pritunl EC2 Security group
resource "aws_security_group" "vpn-sg-wajid" {
  name        = "vpn-sg-wajid"
  description = "Pritunl VPN inbound"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "vpn-sg-wajid"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  ingress {
    description      = "vpn-sg-wajid"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "vpn-sg-wajid"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpn-sg-wajid"
  }
}