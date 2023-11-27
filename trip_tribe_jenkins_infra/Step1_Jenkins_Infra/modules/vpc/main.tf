provider "aws" {

  region = var.region
}


data "aws_availability_zones" "available" {}

data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.region}.s3"
}

# Check if the desired number of availability zones is greater than the actual number
locals {
  insufficient_subnets = var.desired_az_count > length(data.aws_availability_zones.available.names)
  desired_az_count     = local.insufficient_subnets ? 0 : var.desired_az_count

}

# Throw an error if the real number of availability zones is not sufficient
resource "null_resource" "insufficient_subnets" {
  count = local.insufficient_subnets ? 1 : 0

  triggers = {
    insufficient_subnets = "Error: The desired number of availability zones (${var.desired_az_count}) is greater than the actual number of availability zones (${length(data.aws_availability_zones.available.names)})."
  }
}

/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

/*==== Subnets ======*/
# Internet gateway for the public subnet
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}


# Create a public and a private subnet in each availability zone
resource "aws_subnet" "subnets" {
  count = local.insufficient_subnets ? 0 : local.desired_az_count * 2

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 1)
  availability_zone       = element(data.aws_availability_zones.available.names, floor(count.index / 2))
  map_public_ip_on_launch = count.index % 2 == 0 # Every even index subnet is public

  tags = {
    Name = "${count.index % 2 == 0 ? "Public" : "Private"} - Subnet-${floor(count.index / 2) + 1}"
  }
}



/* Routing table for public subnet */
resource "aws_route_table" "public" {
  count = local.desired_az_count

  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-public-route-table-${count.index + 1}"
    Environment = "${var.environment}"
  }
}




resource "aws_route" "public_internet_gateway" {
  count = local.desired_az_count

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}


/* Route table associations */
resource "aws_route_table_association" "public" {
  count = local.desired_az_count

  subnet_id      = element(aws_subnet.subnets.*.id, count.index * 2)
  route_table_id = aws_route_table.public[count.index].id
}


# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  count      = local.desired_az_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.ig]
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  count         = local.desired_az_count
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.subnets[count.index * 2 + 1].id
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "nat-${count.index + 1}"
    Environment = "${var.environment}"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  count = local.desired_az_count

  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-private-route-table-${count.index + 1}"
    Environment = "${var.environment}"
  }
}


resource "aws_route" "private_nat_gateway" {
  count = local.desired_az_count

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}



resource "aws_route_table_association" "private" {
  count = local.desired_az_count

  subnet_id      = element(aws_subnet.subnets.*.id, count.index * 2 + 1)
  route_table_id = aws_route_table.private[count.index].id
}

/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Environment = "${var.environment}"
  }
}


/*==== VPC Gateway Endpoint for Amazon S3 ======*/
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = [for i in range(local.desired_az_count) : aws_route_table.private[i].id]
  tags = {
    Name        = "${var.environment}-s3-vpc-endpoint"
    Environment = "${var.environment}"
  }
}
