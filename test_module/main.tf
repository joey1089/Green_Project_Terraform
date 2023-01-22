# --- root/main.tf ---

module "my_ec2" {
  source = "./ec2-instance"

}

module "my_security_group" {
  source = "./security_group"
}