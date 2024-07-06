resource "aws_key_pair" "key-pair" {
  key_name   = var.aws_key_pair_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvItQpmdiB+GN+HeJIjMJBZgJaMLppJop5lbij5/2yR/OIeQG3lSa0aQPgwmrg704eka1u+2lJhyJuBWheZGrY8qtj9T/aVbQesSwQ2mmISDufpf90YsH0uSKd/x+tg5+EEfq3f0aIuCPpw2B2XSQbGxfrco+ZyNVxQrgCcAHIRtr0NoJuxEsyOeFxGjc263nVnYQZYc2gznXZ6G8MGknDtfNN3hNIqXCVRniIvq3VL7i0vYL8xZsjSHK4xG+dXx9AP9LOU988vlASVWmNYmWaujkkJshdoxFTT7Ox8Drw45+mYf1M8KMaz//P+7/MYE27TdO517qlQrbh3oSojxT5GllPVKjFGBa4b9KLI0xUTEWCpeY1bCfYiltEXkdiYXN/N1VW+/vd9fP7eCaugbFOuThsTjGk/nFC+oNKOm6yXwvpQarf71oLBzP179OV96tnD+eOHzyGnbDfv2C8a4QGCBqu/qtr+xxzTaqboRwov295oyeD+wiONuU4FbFfTL9W+JuZD9+aQOGaCC+HX6g9XXVV+rXCfSZcT1/pXWhGaVCugl/dS2y8wuB4FhZTRRva4ijp0clviLEFJtO7YguC4xiAWAlxaMudnrfQwy4lNlGY0yqM+Mo8kfvFot+MMiVsjfaRDjDfvZchZ7q9gqMNntUAsG0QKSczC+3zRkGiaQ== eks-jenkins"
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
              yum install -y wget firewalld java-11-openjdk-devel
              
              # Install Jenkins
              wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
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
