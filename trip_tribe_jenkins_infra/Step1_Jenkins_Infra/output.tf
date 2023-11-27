output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets_id" {
  value = module.vpc.public_subnets_id
}

output "private_subnets_id" {
  value = module.vpc.private_subnets_id
}

output "default_sg_id" {
  value = module.vpc.default_sg_id
}


output "public_route_table" {
  value = module.vpc.public_route_table
}

output "aws_ssm_parameter" {
  value = aws_ssm_parameter.jenkins_passwd.name
}

