#Provider

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}



provider "aws" {
  region = "us-east-1"
}


#Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}


#Internet Gateway

resource "aws_internet_gateway" "Terraform_IGW" {
  # internet_gateway_id = aws_internet_gateway.Terraform_IGW.id
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Terraform IGW"
  }
}



#Route Table

resource "aws_route_table" "Terraform_RT" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Terraform_IGW.id
  }

  tags = {
    Name = "Terraform Route Table"
  }

}

# Three Subnets
resource "aws_subnet" "Subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "Subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main"
  }
}


resource "aws_subnet" "Subnet_3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main"
  }
}


#Route Table

resource "aws_route_table" "Terraform_RT_Table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Terraform_IGW.id
  }

  tags = {
    Name = "Terraform Route Table"
  }
}




#Route Table Association

resource "aws_route_table_association" "Public_RT_Association_1" {
  subnet_id      = aws_subnet.Subnet_1.id
  route_table_id = aws_route_table.Terraform_RT_Table.id
}

resource "aws_route_table_association" "Public_RT_Association_2" {
  subnet_id      = aws_subnet.Subnet_2.id
  route_table_id = aws_route_table.Terraform_RT_Table.id
}
resource "aws_route_table_association" "Public_RT_Association_3" {
  subnet_id      = aws_subnet.Subnet_3.id
  route_table_id = aws_route_table.Terraform_RT_Table.id
}



resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from My_IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "HTTP from Web"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_http"

  }
}

resource "aws_instance" "EC2_1" {
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.Subnet_1.id
  security_groups             = [aws_security_group.allow_http.id]
  key_name                    = "terraform_key_pair"
  associate_public_ip_address = true


  user_data = <<-EOF
     #!/bin/bash
yum -y update
yum -y install httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Week-20-Project-Deploying an Apache Web Server using Terraform. This is Web-Server-1</h1>" > /var/www/html/index.html
EOF
  tags = {
    Name = "Web-Server-1"
  }
}


resource "aws_instance" "EC2_2" {
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.Subnet_2.id
  security_groups             = [aws_security_group.allow_http.id]
  key_name                    = "terraform_key_pair"
  associate_public_ip_address = true

  user_data = <<-EOF
     #!/bin/bash
yum -y update
yum -y install httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Week-20-Project-Deploying an Apache Web Server using Terraform. This is Web-Server-2</h1>" > /var/www/html/index.html
EOF
  tags = {
    Name = "Web-Server-2"
  }
}


resource "aws_instance" "EC2_3" {
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.Subnet_3.id
  security_groups             = [aws_security_group.allow_http.id]
  key_name                    = "terraform_key_pair"
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
yum -y update
yum -y install httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Week-20-Project-Deploying an Apache Web Server using Terraform. This is Web-Server-3</h1>" > /var/www/html/index.html
EOF
  tags = {
    Name = "Web-Server-3"
  }
}





