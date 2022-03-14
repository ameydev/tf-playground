data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
#   count = 1
  subnet_id = aws_subnet.public-subnet-1.id
  security_groups = [aws_security_group.sg-web-instances.id, aws_security_group.sg-load-balancer.id]
  associate_public_ip_address = true
  tags = merge(
    var.additional_tags,
    {
    Name = "web-app"
  })

  user_data = <<EOF
  #!/bin/bash
  echo "Changing Hostname"
  apt update
  apt install nginx -y
  echo "hello from echo $(hostname -f)" > /var/www/html/index.html
  EOF

}