# --- root/outputs.tf ---

output "InstanceType" {
  value = module.my_ec2.Type_of_Instance
  #syntax- module.module_name.argument
  # module_name is the declared name of the module not the folder name
}

output "AMI_Id" {
  value = module.my_ec2.ami_id
}

output "web_security_grp_id" {
  value = module.security_group_web.web_sg
}