# --- Things that already exist (read-only lookups) ---

data "aws_caller_identity" "current" {}

# The default network of the region
data "aws_vpc" "default" {
  default = true
}

# The SSH key we imported by hand in Stage 2. Terraform only references it, so destroy won't delete it.
data "aws_key_pair" "learning" {
  key_name = "aws-learning"
}

# Latest Amazon Linux 2023 image (x86), published by AWS as a public parameter
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# --- Firewall ---

resource "aws_security_group" "api" {
  name        = "api-lab-tf-sg"
  description = "SSH from my IP, HTTP from anywhere"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.api.id
  description       = "SSH from my IP only"
  cidr_ipv4         = var.my_ip_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.api.id
  description       = "Public HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Terraform removes AWS's default "allow all outbound" rule, so we add it back
# (the instance needs outbound access to install Docker and clone the repo)
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.api.id
  description       = "All outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# --- The server ---

resource "aws_instance" "api" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = "t3.micro"
  key_name                    = data.aws_key_pair.learning.key_name
  vpc_security_group_ids      = [aws_security_group.api.id]
  associate_public_ip_address = true

  # No surprise CPU charges (the same "Standard" setting you chose in the console)
  credit_specification {
    cpu_credits = "standard"
  }

  # Require the newer, safer metadata service (IMDSv2)
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  # Runs once as root at first boot. The replace() turns Windows line endings into
  # Linux ones, which would otherwise break the script.
  user_data                   = replace(file("${path.module}/user_data.sh"), "\r\n", "\n")
  user_data_replace_on_change = true

  tags = {
    Name = "aws-devops-api-tf"
  }
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "public_ip" {
  value = aws_instance.api.public_ip
}

output "api_url" {
  value = "http://${aws_instance.api.public_ip}"
}

output "ssh_command" {
  value = "ssh -i $HOME\\.ssh\\aws-learning ec2-user@${aws_instance.api.public_ip}"
}