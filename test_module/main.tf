# --- root/main.tf ---

module "my_ec2" {
  source = "./ec2-instance"
}



module "security_group_web" {
  source = "./security_group"
}