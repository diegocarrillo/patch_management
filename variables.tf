variable "build_environment" {
  type    = string
  default = "dev"
  description = "Build environment"
}

variable "sns_topic_name" {
  type    = string
  default = "aws-topic-patch"
  description = "SNS topic name"
}
