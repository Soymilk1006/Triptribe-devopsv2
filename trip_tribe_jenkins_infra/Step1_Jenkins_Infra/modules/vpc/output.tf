output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets_id" {
  value = [for index, id in aws_subnet.subnets[*].id : id if index % 2 == 0]
}

output "private_subnets_id" {
  value = [for index, id in aws_subnet.subnets[*].id : id if index % 2 == 1]
}

output "default_sg_id" {
  value = aws_security_group.default.id
}

output "security_groups_ids" {
  value = ["${aws_security_group.default.id}"]
}

output "public_route_table" {
  value = aws_route_table.public[*].id
}
