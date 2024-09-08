provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

# Create a security group for the EC2 instance
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
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
}

# Create an EC2 instance for Django
resource "aws_instance" "django_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (use an appropriate one)
  instance_type = "t2.micro"               # Free tier eligible

  key_name = "for-presentation"

  security_groups = [aws_security_group.allow_ssh_http.name]

  user_data = <<-EOF
              #!/bin/bash
              # Update and install required packages
              yum update -y
              yum install python3 git -y
              
              # Install and upgrade pip
              python3 -m ensurepip --upgrade

              # Install virtualenv to isolate dependencies
              pip3 install virtualenv

              # Create a virtual environment
              virtualenv /home/ec2-user/venv

              # Activate the virtual environment
              source /home/ec2-user/venv/bin/activate

              # Install Django and other dependencies
              pip install django gunicorn

              # Clone the Django app from your GitHub repository or copy the app files directly
              cd /home/ec2-user/
              git clone https://github.com/abrar-farhad-nirjhar/for_presentation_af369.git

              # Navigate to the Django project
              cd for_presentation_af369/core/

              # Install the required Python packages
              pip install -r requirements.txt

              # Run Django migrations
              python manage.py migrate

              # Start Gunicorn server to serve the Django app
              gunicorn --bind 0.0.0.0:80 core.wsgi:application
              EOF

  tags = {
    Name = "DjangoAppServer"
  }
}

# Output the public IP of the EC2 instance
output "ec2_public_ip" {
  value = aws_instance.django_server.public_ip
}
