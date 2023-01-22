# --- security_group/outputs.tf ---

output "web_sg" {
  value = aws_security_group.allow_http
}