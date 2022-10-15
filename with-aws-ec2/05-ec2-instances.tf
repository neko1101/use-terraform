# https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
module "with_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-instance"

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.user1.key_name
  monitoring             = true
  availability_zone      = element(module.vpc.azs, 0)
  subnet_id              = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids = [module.security_group.security_group_id]
  enable_volume_tags     = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

##
# NOTE: AWS new account only allow 1 ec2 deployment, verify your account or contact AWS support.
# Uncomment modules below only if your account is verified, else it will fail.
##

# module "with_multi_ec2" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "~> 3.0"

#   for_each = toset(["one", "two", "three"])

#   name = "multi-instance-${each.key}"

#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = "t2.micro"
#   key_name               = aws_key_pair.user1.key_name
#   monitoring             = true
#   vpc_security_group_ids = [module.security_group.security_group_id]
#   availability_zone      = element(module.vpc.azs, 0)
#   subnet_id              = element(module.vpc.private_subnets, 0)

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }

# module "with_spot_ec2" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "~> 3.0"

#   name = "spot-instance"

#   create_spot_instance = true
#   spot_price           = "0.60"
#   spot_type            = "persistent"

#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = "t2.micro"
#   key_name               = aws_key_pair.user1.key_name
#   monitoring             = true
#   vpc_security_group_ids = [module.security_group.security_group_id]
#   availability_zone      = element(module.vpc.azs, 0)
#   subnet_id              = element(module.vpc.private_subnets, 0)

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }