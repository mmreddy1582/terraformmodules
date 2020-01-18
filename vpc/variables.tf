variable "vpc_cidr_address" {}
variable "name" {}
variable "env" {}
variable "public_subnets" {
    description = "list of public subnets."
    default     = []
}
variable "private_subnets" {
    description = "list of private subnets."
    default     = []
}
variable "availability_zones" {
    description = "List of availability zones in US East Region."
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
variable "tags" {
    default = {}
}
variable "usage_nat" {
    default = true 
}
variable  "create_route" {
    default = true
}
