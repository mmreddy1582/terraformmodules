output "public_subnet_ids" {
      value = aws_subnet.public.*.id
}
output "private_subnet_ids" {
      value = aws_subnet.private.*.id
}
output "vpc_id" {
      value = aws_vpc.vpcmain.id
}
output "private_route_table_ids" {
      value = aws_route_table.private_RT.*.id
}
output "vpc_cidr_address" {
      value = aws_vpc.vpcmain.cidr_block
}