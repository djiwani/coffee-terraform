resource "aws_sns_topic" "coffee_orders" {
  name = "coffee-orders-topic"

  tags = {
    Project = "fourallthedogs"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.coffee_orders.arn
  protocol  = "email"
  endpoint  = "djiwani05@gmail.com"
}