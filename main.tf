resource "local_file" "lambda_code" {
  content = templatefile("./code/lambda_function.tpl", {
    webhookurl   = var.webhook_url
    slackchannel = var.slack_channel
    username     = var.username
  })
  filename = "./code/lambda_function.py"
}

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "./code/lambda_function.py"
  output_path = "./code/lambda_function.zip"
  depends_on  = [local_file.lambda_code]
}

resource "aws_iam_role" "iam_lambda" {
  name = "lambda-slack-bot"
  tags = {
    tag-key = var.tag
  }
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "push_slack_message" {
  function_name    = "push-slack-message"
  filename         = "./code/lambda_function.zip"
  role             = aws_iam_role.iam_lambda.arn
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  tags = {
    tag-key = var.tag
  }
}

resource "aws_sns_topic" "cw_alarm_notification" {
  name = "cloudwatch-alarm-notification"
  tags = {
    tag-key = var.tag
  }
}

resource "aws_sns_topic_subscription" "push_slack_message" {
  topic_arn = aws_sns_topic.cw_alarm_notification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.push_slack_message.arn
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.push_slack_message.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.cw_alarm_notification.arn
}
