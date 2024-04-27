variable "role_name" { type = string }
variable "policy_name" { type = string }
variable "assume_role_policy" { type = string }
variable "policy" { type = string }

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy
}

resource "aws_iam_policy" "this" {
  name   = var.policy_name
  policy = var.policy
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

output "role_arn" {
  value = aws_iam_role.this.arn
}
