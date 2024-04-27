resource "aws_acm_certificate" "this" {
  provider          = aws.us-east-1
  domain_name       = "reizt.dev"
  validation_method = "DNS"
  subject_alternative_names = [
    "*.reizt.dev",
  ]

  tags = {
    Name = "${local.app}-this"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "this" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_acm_certificate.this.domain_validation_options : record.resource_record_name]
}
