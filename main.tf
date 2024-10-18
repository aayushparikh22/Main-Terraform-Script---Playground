provider "aws" {
  region = "us-east-1"  # Update with your desired region
}

data "aws_security_group" "allow_all" {
  # Use the existing security group ID
  id = "sg-0c9a4317cad342b92"
}

resource "aws_instance" "free_tier_instance" {
  ami                    = "ami-0dba2cb6798deb6d8"  # Ubuntu 20.04 LTS
  instance_type         = "t2.micro"
  vpc_security_group_ids = [data.aws_security_group.allow_all.id]  # Use data source here

  key_name              = "mypermakpus"  # Replace with your key pair name

  tags = {
    Name = "My-Playground"
  }
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
Security Group: ${data.aws_security_group.allow_all.name}


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

