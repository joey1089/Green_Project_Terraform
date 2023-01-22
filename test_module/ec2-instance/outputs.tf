# --- ec2-instance/outputs.tf ---

output "Type_of_Instance" {
  value = aws_instance.web.instance_type
}

output "ami_id" {
  value = aws_instance.web.ami
}