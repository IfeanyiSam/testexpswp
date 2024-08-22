provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "app_vpc" { 
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Internet Gateway
resource "aws_internet_gateway" "app_igw" { 
  vpc_id = aws_vpc.app_vpc.id
}

# Public Subnet 1 (us-east-1a)
resource "aws_subnet" "app_public_subnet_1" { 
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# Public Subnet 2 (us-east-1b)
resource "aws_subnet" "app_public_subnet_2" { 
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# Route Table
resource "aws_route_table" "app_route_table" { 
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
}

# Route Table Associations
resource "aws_route_table_association" "app_public_association_1" {
  subnet_id      = aws_subnet.app_public_subnet_1.id
  route_table_id = aws_route_table.app_route_table.id
}

resource "aws_route_table_association" "app_public_association_2" {
  subnet_id      = aws_subnet.app_public_subnet_2.id
  route_table_id = aws_route_table.app_route_table.id
}

# Security Group for EC2 Instances
resource "aws_security_group" "app_web_sg" {
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair (Auto-generated)
resource "tls_private_key" "app_ssh_key" { 
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "app_key" { 
  key_name   = "app_key" 
  public_key = tls_private_key.app_ssh_key.public_key_openssh
}

# EC2 Instances
resource "aws_instance" "app_instance_1" { 
  ami                    = "ami-0e86e20dae9224db8" 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.app_public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.app_web_sg.id]
  key_name               = aws_key_pair.app_key.key_name
  associate_public_ip_address = true
  tags = { 
    Name = "app_server1" 
  }

  user_data = file("${path.module}/userdata.sh")
}

resource "aws_instance" "app_instance_2" { 
  ami                    = "ami-0e86e20dae9224db8" 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.app_public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.app_web_sg.id]
  key_name               = aws_key_pair.app_key.key_name
  associate_public_ip_address = true
  tags = { 
    Name = "app_server2" 
  }

  user_data = file("${path.module}/userdata.sh")
}

# ALB
resource "aws_lb" "app_lb" { 
  name               = "app-lb" 
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_web_sg.id]
  subnets            = [aws_subnet.app_public_subnet_1.id, aws_subnet.app_public_subnet_2.id]
}

resource "aws_lb_target_group" "app_tg" { 
  name     = "app-target-group" 
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id
  health_check { 
    path                = "/api/greeting" 
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "app_listener" { 
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Attach EC2 instances to the Target Group
resource "aws_lb_target_group_attachment" "app_attachment_1" { 
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_instance_1.id
  port             = 3000
}

resource "aws_lb_target_group_attachment" "app_attachment_2" { 
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_instance_2.id
  port             = 3000
}

# Outputs
output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name 
}

output "ec2_instance_ips" {
  value = [aws_instance.app_instance_1.public_ip, aws_instance.app_instance_2.public_ip] 
}

output "ssh_private_key" {
  value     = tls_private_key.app_ssh_key.private_key_pem 
  sensitive = true 
}
