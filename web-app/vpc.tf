terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "web-app-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = merge(
    var.additional_tags,
    {
    Name = "web-app-vpc"
  })
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.web-app-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = merge(
    var.additional_tags,
    {
    Name = "private-subnet-1"
  })
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id     = aws_vpc.web-app-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = merge(
    var.additional_tags,
    {
    Name = "private-subnet-2"
  })
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.web-app-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = merge(
    var.additional_tags,
    {
    Name = "public-subnet-1"
  })
}

resource "aws_internet_gateway" "web-app-ig" {
  vpc_id = aws_vpc.web-app-vpc.id

  tags = merge(
    var.additional_tags,
    {
    Name = "web-app-ig"
  })
}


resource "aws_security_group" "sg-web-instances" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.web-app-vpc.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.web-app-vpc.cidr_block]
    # ipv6_cidr_blocks = [aws_vpc.web-app-vpc.ipv6_cidr_block]
  }
  ingress {
    description      = "ssh from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.web-app-vpc.cidr_block]
    # ipv6_cidr_blocks = [aws_vpc.web-app-vpc.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_security_group" "sg-load-balancer" {
  name        = "allow_http_ig"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.web-app-vpc.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.web-app-vpc.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.web-app-vpc.cidr_block]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http_ig"
  }
}

# resource "aws_lb_target_group" "web-app-lb-target-group" {
#   name     = "web-app-lb-target-group"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main.id
#   health_check {
    
#   }
# }