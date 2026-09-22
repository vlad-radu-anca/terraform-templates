data "aws_availability_zones" "available" {
}

#VPC
resource "aws_vpc" "this" {
  count                = var.vpc_cidr_block != null ? 1 : 0
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-vpc"
  }

}

#Default NACL, want to add multiple NACL Rules, specify @nacl_rules
resource "aws_default_network_acl" "this" {
  count                  = var.vpc_cidr_block != null ? 1 : 0
  default_network_acl_id = aws_vpc.this[0].default_network_acl_id
  dynamic "ingress" {
    for_each = var.nacl_rules
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = var.vpc_cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }
  #By Default All ingress egress are allowed only
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-default_nacl"
  }
}

#Default Security Group
resource "aws_default_security_group" "this" {
  count  = var.vpc_cidr_block != null ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-default_sg"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "this" {
  count  = var.vpc_cidr_block != null ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-igw"
  }
}

#Public Subnet
resource "aws_subnet" "public_subnet" {
  count                   = var.vpc_cidr_block != null ? length(data.aws_availability_zones.available.names) : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = cidrsubnet(aws_vpc.this[0].cidr_block, var.newbits, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-public_subnet"
  }
}

#Private Subnet
resource "aws_subnet" "private_subnet" {
  count             = var.vpc_cidr_block != null ? length(data.aws_availability_zones.available.names) : 0
  vpc_id            = aws_vpc.this[0].id
  cidr_block        = cidrsubnet(aws_vpc.this[0].cidr_block, var.newbits, length(data.aws_availability_zones.available.names) + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-private_subnet"
  }
}

#Elastic IP's for Nat Gateways
resource "aws_eip" "eip_ngw" {
  count      = var.multiple_nats ? length(data.aws_availability_zones.available.names) : 1
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-eip_ngw"
  }
}

#Nat Gateways
resource "aws_nat_gateway" "this" {
  count         = var.vpc_cidr_block != null ? var.multiple_nats ? length(data.aws_availability_zones.available.names) : 1 : 0
  allocation_id = aws_eip.eip_ngw[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  depends_on    = [aws_internet_gateway.this, aws_eip.eip_ngw]

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-ngw"
  }

}

#Public and Main Route Table, Default route is to IGW,
#Want to add more routes, specify @ public_route_rules
resource "aws_route_table" "public_route_table" {
  count  = var.vpc_cidr_block != null ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  dynamic "route" {
    for_each = var.public_route_rules == null ? [] : var.public_route_rules
    content {
      cidr_block                = route.value.cidr_block
      gateway_id                = route.value.gateway_id
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
    }
  }

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-public_route_table"
  }
}

#Private Route Table, Default route is to NGW,
#Want to add more routes, specify @ private_route_rules
resource "aws_route_table" "private_route_table" {
  count  = var.vpc_cidr_block != null ? var.multiple_nats ? length(data.aws_availability_zones.available.names) : 1 : 0
  vpc_id = aws_vpc.this[0].id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.this.*.id, count.index)
  }

  dynamic "route" {
    for_each = var.private_route_rules == null ? [] : var.private_route_rules
    content {
      cidr_block                = route.value.cidr_block
      gateway_id                = route.value.gateway_id
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
    }
  }

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-private_route_table"
  }
}

#Public Route Table association to Main
resource "aws_main_route_table_association" "this" {
  count          = var.vpc_cidr_block != null ? 1 : 0
  vpc_id         = aws_vpc.this[0].id
  route_table_id = aws_route_table.public_route_table[0].id
}

#Private Route Table association to Private Subnets
resource "aws_route_table_association" "this" {
  count          = var.vpc_cidr_block != [] ? length(data.aws_availability_zones.available.names) : 0
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[var.multiple_nats ? count.index : 0].id
}

#Flow logs for VPC/Subnets/ENI
resource "aws_flow_log" "this" {
  count                    = var.create_flow_logs ? 1 : 0
  traffic_type             = var.traffic_type
  iam_role_arn             = var.iam_role_arn
  log_destination_type     = var.log_destination_type
  log_destination          = var.log_destination
  max_aggregation_interval = var.max_aggregation_interval

  eni_id    = var.flow_log_type == "ENI" ? var.eni_id : null
  subnet_id = var.flow_log_type == "Subnet" ? var.subnet_id : null
  vpc_id    = var.flow_log_type == "VPC" ? aws_vpc.this[0].id : null

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-flow_log"
  }
}
