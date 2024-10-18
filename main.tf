provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

# Create Security Group with all traffic allowed
resource "aws_security_group" "allow_all" {
  name        = "allow_all_traffic_${random_id.id.hex}"  # Make it unique
  description = "Security group that allows all inbound and outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generate a random ID to append to the security group name
resource "random_id" "id" {
  byte_length = 4
}


# Create an EC2 instance (free tier eligible)
resource "aws_instance" "free_tier_instance" {
  ami = "ami-0dba2cb6798deb6d8"  # Ubuntu 20.04 LTS (us-east-1)
  instance_type = "t2.micro"

  # Attach the security group
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  tags = {
    Name = "My-Playground"
  }

  # Key pair for SSH (optional)
  key_name = "mypermakpus"  # Replace with your key pair if needed
}

# Output instance details to a notepad file
resource "local_file" "instance_info" {
  filename = "${path.module}/instance_details.txt"
  content  = <<EOL
Instance Details:
-----------------
Instance ID: ${aws_instance.free_tier_instance.id}
Instance Type: ${aws_instance.free_tier_instance.instance_type}
Public IP: ${aws_instance.free_tier_instance.public_ip}
Private IP: ${aws_instance.free_tier_instance.private_ip}
Key Pair: ${aws_instance.free_tier_instance.key_name}
Security Group: ${aws_security_group.allow_all.name}


AWS CLI Commands:
To stop the instance:
aws ec2 stop-instances --instance-ids ${aws_instance.free_tier_instance.id}

To terminate the instance:
aws ec2 terminate-instances --instance-ids ${aws_instance.free_tier_instance.id}

To check the instance status:
aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId,State.Name]" --output table

EOL
}

# Outputs for Terraform console
output "instance_public_ip" {
  value = aws_instance.free_tier_instance.public_ip
}

output "instance_private_ip" {
  value = aws_instance.free_tier_instance.private_ip
}

output "instance_key_pair" {
  value = aws_instance.free_tier_instance.key_name
}

