resource "aws_key_pair" "key-pair" {
  key_name   = var.aws_key_pair_name
  public_key = file("~/.ssh/aws_rsa.pub")
}

resource "aws_instance" "ec2" {
  ami               = var.ami
  instance_type     = var.instance_type
  availability_zone = var.az
  subnet_id         = var.public_subnet_ids["us-east-1b"]
  associate_public_ip_address = true
  vpc_security_group_ids = [var.sg]

  key_name = aws_key_pair.key-pair.key_name
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y wget firewalld java-17-openjdk-devel
              
              # Install Jenkins
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              yum install -y jenkins

              # Enable and start services
              systemctl start jenkins
              systemctl enable jenkins
              systemctl start firewalld
              systemctl enable firewalld
              
              # Open necessary ports
              firewall-cmd --permanent --add-port=8080/tcp
              firewall-cmd --reload
              EOF
  tags = {
    Name = "${var.vpc-id}-ec2-instance"
  }
}
