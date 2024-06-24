resource "aws_key_pair" "key-pair" {
  key_name   = var.aws_key_pair_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOx6aFMyXGnBAJkxnW6O8qmtTwrreWMSgz5o1esm3Fgcr0+zrGdZ93zhfQ41cDo4F/09VzL3CFD+v9KdhzrzU92htJhQjx0dXAIhHfYW+/coRFrTa+rLWCOaNSCkemTST3ayyRx1/f+7t39s7Nw8qqBLlu6NO/LaUqpbE6POaLHpACM+vhilUVPMDFh5XmxJqF55xYkpzCYQ3J4bv4KeadgT9CwPo5ffBzNFpFEA1uAO3c7rYOehl8EbANFQFEMnS9hnXsO+VSfH1sTQC3ImbsMfPZEHpLrlpqMbyz7kQZfNdiqBloK53tKJ12CIgL6ZtuaOXtagSgX03k4QdAdHJVgOV7PC6vnhUS+EHw+W6qkCrPOxtzUfCLkZretoMdd21LRJuu+4vpJuZj5QZNK+JHRgSbDd1cisIJy0WTVbdkm0jh6tPJq3h9bFOnawDf6jgqhhL3ju7na04Cdrh03schkjXDSxwoqq7NPr1QDQ0/XEl4CjDg83wiT6UxThoUxQROexpo4m8p7Ba+kU2DOLAn9glnGz7ckpbA8eCmx5eNdAckdiPbflzmDnRy+5IOSLU557J1yuuZRU8NvHPcEOQI4cpdAVZzic+3/YyjtiGgW9/T5GqlghuMuaiHWBZydM/B3Bx30fsP3jC9HDoPRuL0VZjPE9M5ymVOLlfdicUuLw== chandhudev0@gmail.com"
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
