##########################################
# Terraform - Jenkins on Ubuntu (AWS)
##########################################

provider "aws" {
  region = "us-east-1"
}

##########################################
# 1️⃣  VPC
##########################################
resource "aws_vpc" "trend_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "trend-vpc"
  }
}

##########################################
# 2️⃣  Subnet
##########################################
resource "aws_subnet" "trend_subnet" {
  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "trend-subnet"
  }
}

##########################################
# 3️⃣  Internet Gateway + Route Table
##########################################
resource "aws_internet_gateway" "trend_igw" {
  vpc_id = aws_vpc.trend_vpc.id
  tags = {
    Name = "trend-igw"
  }
}

resource "aws_route_table" "trend_rt" {
  vpc_id = aws_vpc.trend_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.trend_igw.id
  }
  tags = {
    Name = "trend-rt"
  }
}

resource "aws_route_table_association" "trend_rta" {
  subnet_id      = aws_subnet.trend_subnet.id
  route_table_id = aws_route_table.trend_rt.id
}

##########################################
# 4️⃣  Security Group
##########################################
resource "aws_security_group" "trend_sg" {
  name        = "trend-sg"
  description = "Allow SSH and Jenkins access"
  vpc_id      = aws_vpc.trend_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Jenkins"
    from_port   = 8080
    to_port     = 8080
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
    Name = "trend-sg"
  }
}

##########################################
# 5️⃣  IAM Role + Instance Profile
##########################################
resource "aws_iam_role" "trend_ec2_role" {
  name = "trend-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "trend_ec2_profile" {
  name = "trend-ec2-profile"
  role = aws_iam_role.trend_ec2_role.name
}

##########################################
# 6️⃣  EC2 Instance (Ubuntu + Jenkins)
##########################################
resource "aws_instance" "trend_jenkins" {
  ami           = "ami-0fc5d935ebf8bc3bc" # ✅ Ubuntu 22.04 LTS (us-east-1)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.trend_subnet.id
  vpc_security_group_ids = [aws_security_group.trend_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.trend_ec2_profile.name
  key_name      = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt update -y
              apt install -y openjdk-17-jdk wget gnupg2 git curl

              # Add Jenkins repo & key
              wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee \
                /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                https://pkg.jenkins.io/debian-stable binary/ | tee \
                /etc/apt/sources.list.d/jenkins.list > /dev/null

              apt update -y
              apt install -y jenkins

              systemctl enable jenkins
              systemctl start jenkins
              EOF

  tags = {
    Name = "trend-jenkins"
  }
}

##########################################
# 7️⃣  Elastic IP (Optional but Recommended)
##########################################
resource "aws_eip" "trend_eip" {
  instance = aws_instance.trend_jenkins.id
  domain   = "vpc"
  tags = {
    Name = "trend-eip"
  }
}

##########################################
# 8️⃣  Variable for Key Pair
##########################################

