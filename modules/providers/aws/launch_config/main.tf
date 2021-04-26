

resource "aws_launch_configuration" "default_lc" {
  name_prefix   = var.lc_name
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data            = data.template_file.user_data.rendered
  security_groups      = ["${var.security_groups}"]
  iam_instance_profile = aws_iam_instance_profile.test_profile.name #var.iam_role
  key_name             = var.key_name

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_volume_size
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.test_role.name
}

resource "aws_iam_role" "test_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy_attachment" "managed-role-attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = data.aws_iam_policy.ssm-service-policy.arn
}

resource "aws_iam_role_policy_attachment" "patch-role-attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = data.aws_iam_policy.ssm-patch-service-policy.arn
}

data "aws_iam_policy" "ssm-service-policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "ssm-patch-service-policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}

data "template_file" "user_data" {
  template = file("${var.path_user_data}")
}
