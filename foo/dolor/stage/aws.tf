data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "main" {
  tags = { Name = "Main VPC" }
}

data "aws_subnet" "nonprod_public_1a" {
  vpc_id            = data.aws_vpc.main.id
  availability_zone = "us-east-1a"
  tags = {
    env  = "nonprod"
    type = "public"
  }
}

data "aws_security_group" "egress_any_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  tags = {
    type     = "egress"
    protocol = "any"
    network  = "public"
  }
}

data "aws_security_group" "ingress_ssh_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  tags = {
    type     = "ingress"
    protocol = "ssh"
    network  = "public"
  }
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "spacelift-test-prod"
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "aws_instance" "instances" {
  count                       = 1
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnet.nonprod_public_1a.id
  vpc_security_group_ids = [
    data.aws_security_group.egress_any_public.id,
    data.aws_security_group.ingress_ssh_public.id,
  ]
  tags = {
    Name = "${local.identifier}-${count.index}"
  }
}
