# Route 53 Hosted Zone
# NOTE: After applying, update Bluehost nameservers to match the NS records below
resource "aws_route53_zone" "main" {
  name = "fourallthedogs.com"

  tags = {
    Project = "fourallthedogs"
  }
}

# A record - cafe.fourallthedogs.com -> CloudFront
resource "aws_route53_record" "cafe" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "cafe.fourallthedogs.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "opencourt_delegation" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "opencourt.fourallthedogs.com"
  type    = "NS"
  ttl     = 300
  records = [
	  "ns-1337.awsdns-39.org",
	  "ns-583.awsdns-08.net",
	  "ns-241.awsdns-30.com",
	  "ns-1606.awsdns-08.co.uk"
	]
}