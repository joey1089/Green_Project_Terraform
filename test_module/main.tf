# --- root/main.tf ---

module "my_ec2" {
  source = "./ec2-instance"
  security_group = module.security_group_web.web_sg
}



module "security_group_web" {
  source = "./security_group"
  
}