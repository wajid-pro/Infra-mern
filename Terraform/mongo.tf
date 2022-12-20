module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["one", "two", "three"])

  name = "wajidmongo-${each.key}"

  ami                    = "ami-0530ca8899fac469f"
  instance_type          = "t3a.small"
  key_name               = "wajid2"
  vpc_security_group_ids = [resource.aws_security_group.mongo-sg-wajid.id]
  monitoring             = true
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev2"
  }
}

  #Mongo EC2 Security group
resource "aws_security_group" "mongo-sg-wajid" {
  name        = "mongo-sg-wajid"
  description = "MongoDB Sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "mongo-sg-wajid"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "mongo-sg-wajid"
    from_port   = 22
    to_port     = 22
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
    Name = "mongo-sg-wajid"
  }
}
