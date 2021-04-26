

provider "aws" {
  region = module.environment.aws_region
}

terraform {
  backend "s3" {
    region  = "us-east-1"
    bucket  = "diegocarr-terraform2"
    key     = "environments/providers/aws/prd/applications/nginx-sample-stack/main.tf"
    encrypt = true
  }
}

# module "s3_bucket" {
#   source = "terraform-aws-modules/s3-bucket/aws"
#   bucket = local.s3_buckets[0]
#   acl    = "private"
#   block_public_acls = true
#   block_public_policy = true
#   ignore_public_acls = true
#   restrict_public_buckets = true
#   versioning = {
#     enabled = true
#   }
#   server_side_encryption_configuration = {
#     rule = {
#       apply_server_side_encryption_by_default = {
#         sse_algorithm     = "AES256"
#         kms_master_key_id = null
#       }
#     }
#   }
#   tags = {
#   }
# }


# resource "local_file" "out_tfvars" {
#   filename = "${path.root}/../../${var.environment}/deploy.auto.tfvars"
#   content = <<-EOF
# s3_bucket = "${local.s3_buckets[1]}"
# aws_region = "${var.aws_region}"
# customer_name= "${var.customer_name}"
# assumerole = "${var.assumerole}"
# environment = “${var.environment}”
#   EOF
# }

//Import the constants
module "environment" {
  source = "../../"
}

module "aws_security_group_lb" {
  source  = "../../../../../../modules/providers/aws/security_group/create_sg"
  sg_name = var.sg_name
  vpc_id  = data.terraform_remote_state.vpc.outputs.vpc_id
}

module "sg_rules_https" {
  source            = "../../../../../../modules/providers/aws/security_group/create_sg_rule"
  port              = 80
  protocol          = "TCP"
  ips_sg_list       = var.ips_sg_list
  security_group_id = module.aws_security_group_lb.id
}

module "load_balancer" {
  source           = "../../../../../../modules/providers/aws/elb"
  elb_name         = var.elb_name
  subnets_ids      = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups  = module.aws_security_group_lb.id
  application_port = 80
}

module "aws_launch_configuration" {
  source          = "../../../../../../modules/providers/aws/launch_config"
  lc_name         = var.lc_name
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  path_user_data  = "./user_data.sh"
  security_groups = module.security_group.id
  iam_role        = var.role_name
  key_name        = var.key_pair
}

module "aws_autoscaling_group" {
  source            = "../../../../../../modules/providers/aws/asg"
  asg_name          = var.asg_name
  associate_elb     = "ELB"
  load_balancer     = [module.load_balancer.elb_name]
  health_check_type = "ELB"
  lc_name           = module.aws_launch_configuration.lc_name
  subnets_id        = data.terraform_remote_state.vpc.outputs.private_subnets
  tag_name          = var.asg_name
  tag_team          = var.team
  }


module "security_group" {
  source  = "../../../../../../modules/providers/aws/security_group/create_sg"
  sg_name = "poc-sg"
  vpc_id  = data.terraform_remote_state.vpc.outputs.vpc_id
}

module "add_sg_rule" {
  source            = "../../../../../../modules/providers/aws/security_group/create_sg_rule"
  port              = var.ec2_port
  ips_sg_list       = ["0.0.0.0/0"]
  security_group_id = module.security_group.id
}
