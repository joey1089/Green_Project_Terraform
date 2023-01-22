# --- ec2-instance/variables.tf ---

variable "instance_type" {
  default = "t3.micro"
}

variable "security_group" {
  description = "security_group for the security group module"
}
