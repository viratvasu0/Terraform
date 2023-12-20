provider "aws" {
  region = "us-east-1"  # Primary AWS region
}

# Create VPCs in primary and secondary regions
resource "aws_vpc" "primary_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "secondary_vpc" {
  provider = aws.useast2  # Secondary region
  cidr_block = "10.1.0.0/16"
}

# Create subnets in the primary region
resource "aws_subnet" "primary_public_subnet" {
  vpc_id                  = aws_vpc.primary_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "primary_private_subnet" {
  vpc_id      = aws_vpc.primary_vpc.id
  cidr_block  = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Create subnets in secondary region
resource "aws_subnet" "secondary_public_subnet" {
  provider                = aws.useast2  # Secondary region
  vpc_id                  = aws_vpc.secondary_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "secondary_private_subnet" {
  provider    = aws.useast2  # Secondary region
  vpc_id      = aws_vpc.secondary_vpc.id
  cidr_block  = "10.1.2.0/24"
  availability_zone = "us-east-2b"
}

# VPC peering connection between primary and secondary VPCs
resource "aws_vpc_peering_connection" "vpc_peering" {
  provider          = aws.useast2  # Secondary region
  vpc_id            = aws_vpc.secondary_vpc.id
  peer_vpc_id       = aws_vpc.primary_vpc.id
  auto_accept       = true
}

# VPN connection between primary and secondary regions
resource "aws_vpn_gateway" "primary_vpn_gateway" {
  vpc_id = aws_vpc.primary_vpc.id
}

resource "aws_customer_gateway" "secondary_customer_gateway" {
  bgp_asn    = 65000
  ip_address = "x.x.x.x"  # Replace with your secondary region public IP
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "vpn_connection" {
  customer_gateway_id = aws_customer_gateway.secondary_customer_gateway.id
  vpn_gateway_id      = aws_vpn_gateway.primary_vpn_gateway.id
  type                = "ipsec.1"
}

# Other resources like EC2 instances, load balancers, Route 53 configurations, etc., would also be added as needed.

# Note: This is a high-level structure. The specific configurations for each resource like VPN connections, VPC peering, etc., require detailed settings and dependencies to function properly in a real-world scenario.


variable "region1" {
  description = "First AWS region"
  default     = "us-west-1"
}

variable "region2" {
  description = "Second AWS region"
  default     = "us-east-1"
}

# Define other variables for VPC CIDRs, subnet configurations, VPN details, etc.

VPCs and Subnets in each region
# VPC in region 1
resource "aws_vpc" "vpc_region1" {
  cidr_block = "10.0.0.0/16"
  # Other VPC configurations
}

# Subnets in region 1
resource "aws_subnet" "subnet_region1_public" {
  # Subnet configurations for region 1 public subnet
}

resource "aws_subnet" "subnet_region1_private" {
  # Subnet configurations for region 1 private subnet
}

# Repeat the above for region 2 with corresponding CIDRs and configurations
VPC Peering
# Peering connection from region 1 to region 2
resource "aws_vpc_peering_connection" "peering_region1_to_region2" {
  # Peering connection configurations
}

# Peering connection from region 2 to region 1
resource "aws_vpc_peering_connection" "peering_region2_to_region1" {
  # Peering connection configurations
}
VPN Connection between regions:
# VPN connection from region 1 to region 2
resource "aws_vpn_connection" "vpn_region1_to_region2" {
  # VPN connection configurations
}

# VPN connection from region 2 to region 1
resource "aws_vpn_connection" "vpn_region2_to_region1" {
  # VPN connection configurations
}
Multi-tier Application in each region:
# Multi-tier application in region 1
# Define EC2 instances, load balancers, RDS, security groups, etc.

# Multi-tier application in region 2
# Define EC2 instances, load balancers, RDS, security groups, etc.
Outputs
output "vpc_region1_id" {
  value = aws_vpc.vpc_region1.id
}

output "vpc_region2_id" {
  value = aws_vpc.vpc_region2.id
}

# Define other outputs as needed for resources IDs, endpoint URLs, etc.
# Define variables
variable "aws_region_primary" {
  description = "Primary AWS region"
  default     = "us-west-2"
}

variable "aws_region_secondary" {
  description = "Secondary AWS region"
  default     = "us-east-1"
}

# Define VPCs
resource "aws_vpc" "primary_vpc" {
  cidr_block = "10.0.0.0/16"
  region     = var.aws_region_primary
}

resource "aws_vpc" "secondary_vpc" {
  cidr_block = "10.1.0.0/16"
  region     = var.aws_region_secondary
}

# Define subnets
resource "aws_subnet" "primary_subnet" {
  vpc_id            = aws_vpc.primary_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region_primary}a"
}

resource "aws_subnet" "secondary_subnet" {
  vpc_id            = aws_vpc.secondary_vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "${var.aws_region_secondary}a"
}

# Define VPC peering
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id        = aws_vpc.primary_vpc.id
  peer_vpc_id   = aws_vpc.secondary_vpc.id
  auto_accept   = true
}

# Define VPN connections
resource "aws_vpn_connection" "vpn_connection" {
  customer_gateway_id    = aws_customer_gateway.primary_gateway.id
  vpn_gateway_id         = aws_vpn_gateway.secondary_gateway.id
  type                   = "ipsec.1"
  static_routes_only     = true
  vpc_peering_connection = aws_vpc_peering_connection.vpc_peering.id
}

# Define multi-tier application resources
resource "aws_instance" "web_server" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.primary_subnet.id
}

resource "aws_instance" "database_server" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.secondary_subnet.id
}

# Define output variables
output "primary_vpc_id" {
  value       = aws_vpc.primary_vpc.id
  description = "ID of the primary VPC"
}

output "secondary_vpc_id" {
  value       = aws_vpc.secondary_vpc.id
  description = "ID of the secondary VPC"
}

output "primary_subnet_id" {
  value       = aws_subnet.primary_subnet.id
  description = "ID of the primary subnet"
}

output "secondary_subnet_id" {
  value       = aws_subnet.secondary_subnet.id
  description = "ID of the secondary subnet"
}
