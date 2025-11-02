resource "aws_security_group" "ec2_sg" {
  name        = "two-tier-sg"
  description = "Allow SSH and port 8080 acsess"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Port 8080 access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "two-tier-sg"
  }
}

resource "aws_instance" "example" {
  ami = var.ami_value
  instance_type = var.instance_type
  subnet_id = var.subnet_id_value

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -ex

    # Update and install dependencies
    apt-get update -y
    apt-get install -y git apt-transport-https ca-certificates curl gnupg lsb-release

    # Install Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io

    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Create dev user and enable password login
    useradd -m -s /bin/bash dev || true
    echo "dev:two-tier" | chpasswd
    usermod -aG sudo dev
    usermod -aG docker dev

    # Remove any extra SSH configuration snippets
    rm -f /etc/ssh/sshd_config.d/*

    # Enable SSH password authentication
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config || true
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config || true
    systemctl restart ssh

    # clone repo as dev and set ownership
    su - dev -c "cd /home/dev && git clone https://github.com/dathan-08/two-tier.git || (cd /home/dev/two-tier && git pull)"
    chown -R dev:dev /home/dev/two-tier

    # run docker-compose as dev user (in background)
    su - dev -c "cd /home/dev/two-tier && /usr/local/bin/docker-compose up -d --build || true"

    # ensure containers restart on reboot (optional: create a small systemd service)
    cat > /etc/systemd/system/two-tier-restart.service <<EOL
    [Unit]
    Description=Ensure two-tier docker compose is up
    After=docker.service

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    ExecStart=/bin/bash -lc 'su - dev -c "cd /home/dev/two-tier && /usr/local/bin/docker-compose up -d --build"'

    [Install]
    WantedBy=multi-user.target
    EOL

    systemctl daemon-reload
    systemctl enable two-tier-restart.service

    # Start Docker
    systemctl enable docker
    systemctl start docker
  EOF

  tags = {
    Name = "two-tier-instance"
  }
}



