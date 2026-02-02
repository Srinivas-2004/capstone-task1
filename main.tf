provider "aws" {

  region = var.region

}



resource "aws_vpc" "web_vpc" {

  cidr_block = "10.0.0.0/16"

}



resource "aws_subnet" "web_subnet" {

  vpc_id            = aws_vpc.web_vpc.id

  cidr_block        = "10.0.1.0/24"

  map_public_ip_on_launch = true

}



resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.web_vpc.id

}



resource "aws_route_table" "rt" {

  vpc_id = aws_vpc.web_vpc.id



  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id

  }

}



resource "aws_route_table_association" "rta" {

  subnet_id      = aws_subnet.web_subnet.id

  route_table_id = aws_route_table.rt.id

}



resource "aws_security_group" "web_sg" {

  vpc_id = aws_vpc.web_vpc.id



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



resource "aws_instance" "web_server" {

  ami           = var.ami

  instance_type = "t2.micro"

  subnet_id     = aws_subnet.web_subnet.id

  security_groups = [aws_security_group.web_sg.id]



  user_data = <<-EOF

              #!/bin/bash

              yum update -y

              yum install httpd -y

              systemctl start httpd

              systemctl enable httpd

              echo "<h1>Terraform Web Server Working!</h1>" > /var/www/html/index.html

              EOF

}


