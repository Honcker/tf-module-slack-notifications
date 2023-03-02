variable "slack_channel" {
  description = "Slack channel, eg '#cloudwatchalarms'"
}

variable "webhook_url" {
  description = "Slack webhook URL, eg 'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX'"
}

variable "username" {
  description = "Bot username, eg 'webhookbot'"
}

variable "tag" {
  description = "resources tag, eg 'sns-slack'"
}

variable "region" {
  description = "AWS region, eg 'us-west-2'"
}
