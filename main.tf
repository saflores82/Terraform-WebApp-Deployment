provider "aws" { 
region = "us-east-1" # Cambia esto a tu región preferida 
}

//SNS
resource "aws_sns_topic" "ajì" {
name = "especias-topic"
}

resource "aws_sns_topic_subscription" "ajì" {
topic_arn = aws_sns_topic.ajì.arn
protocol  = "email"
endpoint  = var.subscription_email
}

variable "subscription_email" {
description = "Email for SNS subscription"
type = string
}

//crea EC2

resource "aws_instance" "jijaju" {
  ami           = "ami-01b799c439fd5516a"  # AMI de Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "vockey"  # Cambia esto al nombre de tu par de claves SSH
  iam_instance_profile = "LabInstanceProfile"
 
  
  tags = {
    Name = "jijaju"
  }
 
  # Define el Security Group para permitir tráfico HTTP y SSH
  vpc_security_group_ids = [aws_security_group.web_sg.id]
 
  provisioner "file" {
  source      = "install_apache.sh"
  destination = "/tmp/install_apache.sh"
  }
 
  provisioner "file" {
  source      = "install_php.sh"
  destination = "/tmp/install_php.sh"
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_apache.sh",
      "sudo /tmp/install_apache.sh"
    ]
  }
 
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_php.sh",
      "sudo /tmp/install_php.sh"
    ]
  }
 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("ssh.pem")  # Ruta a tu clave privada
    host        = self.public_ip
  }
}

// SECURTIY GROUPS

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH traffic"
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
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