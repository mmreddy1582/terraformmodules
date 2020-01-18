resource "aws_vpc" "vpcmain"{
        cidr_block           = var.vpc_cidr_address
        enable_dns_hostnames = true 
        tags                 = merge(var.tags, map("Name", format("%s", var.name)))
}
resource "aws_internet_gateway" "vpcmain_igw" {
        vpc_id               = aws_vpc.vpcmain.id
        tags                 = merge(var.tags, map("Name", format("VPC main internet gateway")))
}
resource "aws_eip" "nat_eip" {
        count                = var.usage_nat ? length(var.availability_zones) : 0
        vpc                  = true 
        tags                 = merge(var.tags, map("Name", format("NAT EIP")))

}
resource "aws_subnet" "private" {
        vpc_id               = aws_vpc.vpcmain.id
        cidr_block           = var.private_subnets[count.index]
        availability_zone    = element(var.availability_zones, count.index) 
        count                = length(var.private_subnets)  
        tags                 = merge(var.tags, map("Name", format("%s-private-%s", var.env, element(var.availability_zones, count.index))), map("Tier", "Private"))
}
resource "aws_subnet" "public" {
        vpc_id               = aws_vpc.vpcmain.id 
        cidr_block           = var.public_subnets[count.index]
        availability_zone    = element(var.availability_zones, count.index)
        count                = length(var.public_subnets)
        tags                 = merge(var.tags, map("Name", format("%s-public-%s", var.env, element(var.availability_zones, count.index))), map("Tier", "public"))
}
resource "aws_route_table" "private_RT" {
        vpc_id               = aws_vpc.vpcmain.id
        count                = length(var.availability_zones)
        tags                 = merge(var.tags, map("Name", format("%s-rt-private-%s", var.env, element(var.availability_zones, count.index))))
}
resource "aws_route_table" "public_RT" {
        vpc_id               = aws_vpc.vpcmain.id 
        tags                 = merge(var.tags, map("Name", format("%s-rt-public", var.env)))
}
resource "aws_route" "public_gateway_route" {
        count                  = var.create_route ? 1 : 0
        route_table_id         = aws_route_table.public_RT.id
        destination_cidr_block = "0.0.0.0/0"
        gateway_id             =  aws_internet_gateway.vpcmain_igw.id       
}
resource "aws_route_table_association" "public" {
        count                  = var.create_route ? length(var.public_subnets) : 0
        subnet_id              = element(aws_subnet.public.*.id, count.index)
        route_table_id         = aws_route_table.public_RT.id 
}
resource "aws_nat_gateway" "natgw" {
       count                   = var.usage_nat ? length(var.availability_zones) : 0
       allocation_id           = element(aws_eip.nat_eip.*.id, count.index)
       subnet_id               = element(aws_subnet.public.*.id, count.index)
       depends_on              = [aws_internet_gateway.vpcmain_igw]
       lifecycle {
           ignore_changes = [allocation_id]
       }
       
}
resource "aws_route" "natgw_route" {
      count                   = var.usage_nat ? length(var.availability_zones) : 0
      route_table_id          = element(aws_route_table.private_RT.*.id, count.index)
      destination_cidr_block  = "0.0.0.0/0"
      depends_on              = [aws_route_table.private_RT]
      nat_gateway_id          = element(aws_nat_gateway.natgw.*.id, count.index)
}