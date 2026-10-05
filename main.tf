provider "aws" {
    region = "ap-south-1"  
}


resource "aws_security_group" "app_sg" {
    name        = "app-sg"
    description = "Allow SSH and application traffic"

    ingress {
        description = "SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Application access"
        from_port   = 3000
        to_port     = 3000
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

resource "aws_instance" "ansible_with_terraform" {
    ami                    = "ami-01a00762f46d584a1"
    instance_type          = "t3.micro"
    key_name               = "# add your-key"
    vpc_security_group_ids = [aws_security_group.app_sg.id]

    tags = {
        Name = "ansible_with_terraform"
    }

    provisioner "local-exec" {
        command = <<EOT
            sed -i "2c\\${aws_instance.ansible_with_terraform.public_ip}" inventory.ini
            ansible-playbook -i inventory.ini playbook.yml
        EOT
    }
}
