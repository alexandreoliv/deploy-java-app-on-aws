provider "aws" {
  region = "us-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "alex-main-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1a"
  tags = {
    Name = "alex-public-subnet"
  }
}

# resource "aws_subnet" "private" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone = "us-west-1a"
#   tags = {
#     Name = "alex-private-subnet"
#   }
# }

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "alex-main-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "alex-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #   ingress {
  #     from_port   = 80
  #     to_port     = 80
  #     protocol    = "tcp"
  #     cidr_blocks = ["0.0.0.0/0"]
  #   }

  #   ingress {
  #     from_port   = 443
  #     to_port     = 443
  #     protocol    = "tcp"
  #     cidr_blocks = ["0.0.0/0"]
  #   }

  ingress {
    from_port   = 9000
    to_port     = 9000
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
    Name = "alex-public-sg"
  }
}

# resource "aws_security_group" "private_sg" {
#   name        = "private-sg"
#   description = "Allow internal communication and SSH from public instance"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [aws_instance.public_instance.private_ip]
#   }

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = [aws_vpc.main.cidr_block]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "alex-private-sg"
#   }
# }

resource "aws_instance" "public_instance" {
  ami           = "ami-0657605d763ac72a8" # Ubuntu AMI on us-west-1
  # instance_type = "t2.micro"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [
    aws_security_group.public_sg.id
  ]
  associate_public_ip_address = true
  key_name                    = "alex-kp"

  tags = {
    Name = "alex-public-instance"
  }
}

# resource "aws_instance" "private_instance" {
#   ami           = "ami-0657605d763ac72a8" # Ubuntu AMI on us-west-1
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.private.id
#   security_groups = [
#     aws_security_group.private_sg.name
#   ]
#   key_name = "alex-kp"

#   tags = {
#     Name = "alex-private-instance"
#   }
# }

# resource "aws_eip" "nat" {
#   vpc = true
# }

# resource "aws_nat_gateway" "nat" {
#   #   allocation_id = aws_eip.nat.id
#   subnet_id = aws_subnet.public.id
#   tags = {
#     Name = "alex-nat-gateway"
#   }
# }

# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public.id
#   tags = {
#     Name = "nat-gateway"
#   }
# }

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }

#   tags = {
#     Name = "alex-private-rt"
#   }
# }

# resource "aws_route_table_association" "private" {
#   subnet_id      = aws_subnet.private.id
#   route_table_id = aws_route_table.private.id
# }


output "public_instance_ip" {
  value = aws_instance.public_instance.public_ip
}

# output "private_instance_private_ip" {
#   value = aws_instance.private_instance.private_ip
# }
