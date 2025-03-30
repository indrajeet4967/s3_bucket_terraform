terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"    
    profile = "default"
}


resource "aws_vpc" "vpc_main" {
    cidr_block = "10.10.0.0/24"
    instance_tenancy = "default"
    tags = {
    Name = "main"
  }

}

resource "aws_subnet" "main_subnets" {
    vpc_id = aws_vpc.vpc_main.id
    cidr_block = "10.10.0.0/25"
    map_public_ip_on_launch = true  # Enables auto-assigning public IP
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }


}

resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.vpc_main.id

}

resource "aws_internet_gateway_attachment" "main_igw_attachment" {
    internet_gateway_id = aws_internet_gateway.main_igw.id
    vpc_id = aws_vpc.vpc_main.id
 
}
resource "aws_route_table" "main_route" {
     vpc_id =aws_vpc.vpc_main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_igw.id
    }   
  
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.main_subnets.id
  route_table_id = aws_route_table.main_route.id
}

resource "aws_security_group" "my_secuirty_group" {
    vpc_id =  aws_vpc.vpc_main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/25"] # Restrict in production!
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/25"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance-security-group"
  }
}
