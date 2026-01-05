terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project = "590r"
      Name    = var.project_name
    }
  }
}

# Data source for default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source for account ID
data "aws_caller_identity" "current" {}

# Security Group
resource "aws_security_group" "byu_590r_sg" {
  name        = "byu-590r-sg"
  description = "Security group for BYU 590R application"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name    = "byu-590r-sg"
    Project = "590r"
  }
}

# Security Group Rules
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.byu_590r_sg.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.byu_590r_sg.id
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.byu_590r_sg.id
}

resource "aws_security_group_rule" "backend_api" {
  type              = "ingress"
  from_port         = 4444
  to_port           = 4444
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.byu_590r_sg.id
}

# Elastic IP
resource "aws_eip" "byu_590r_eip" {
  domain = "vpc"

  tags = {
    Name    = var.project_name
    Project = "590r"
  }
}

# EC2 Instance
resource "aws_instance" "byu_590r_server" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.byu_590r_sg.id]
  user_data              = base64encode(local.setup_script)

  tags = {
    Name = "${var.project_name}-server"
  }

  # Wait for instance to be running before associating EIP
  depends_on = [aws_eip.byu_590r_eip]
}

# Associate Elastic IP with instance
resource "aws_eip_association" "byu_590r_eip_assoc" {
  instance_id   = aws_instance.byu_590r_server.id
  allocation_id = aws_eip.byu_590r_eip.id
}

# S3 Dev Bucket
resource "aws_s3_bucket" "dev" {
  bucket = "${var.project_name}-dev-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  tags = {
    Name        = "byu-590r-dev"
    Project     = "byu-590r"
    Environment = "development"
  }
}

resource "aws_s3_bucket_public_access_block" "dev" {
  bucket = aws_s3_bucket.dev.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# S3 Prod Bucket
resource "aws_s3_bucket" "prod" {
  bucket = "${var.project_name}-prod-${formatdate("YYYYMMDDhhmmss", timestamp())}-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "byu-590r-prod"
    Project     = "byu-590r"
    Environment = "production"
  }
}

resource "aws_s3_bucket_public_access_block" "prod" {
  bucket = aws_s3_bucket.prod.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Random ID for bucket suffix
resource "random_id" "bucket_suffix" {
  byte_length = 2
}

# EC2 Setup Script (user_data)
locals {
  setup_script = <<-EOF
#!/bin/bash
set -e

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PHP 8.3 and extensions
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.3 php8.3-mysql php8.3-xml php8.3-mbstring php8.3-curl php8.3-zip php8.3-gd php8.3-cli php8.3-common libapache2-mod-php8.3

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Install MySQL
sudo apt install -y mysql-server
sudo systemctl enable mysql
sudo systemctl start mysql

# Install Apache
sudo apt install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2

# Install Git
sudo apt install -y git

# Create application directories
sudo mkdir -p /var/www/html/app
sudo mkdir -p /var/www/html/api
sudo chown -R ubuntu:ubuntu /var/www/html/app
sudo chown -R ubuntu:ubuntu /var/www/html/api

# Create database and user
sudo mysql -u root << 'MYSQL_EOF'
CREATE DATABASE IF NOT EXISTS byu_590r_app;
CREATE USER IF NOT EXISTS 'byu_user'@'localhost' IDENTIFIED BY 'trees243';
GRANT ALL PRIVILEGES ON byu_590r_app.* TO 'byu_user'@'localhost';
FLUSH PRIVILEGES;
MYSQL_EOF

# Configure Apache Virtual Hosts

# Enable Apache modules
sudo a2enmod rewrite
sudo a2enmod headers

# Create virtual hosts with port-based routing
sudo tee /etc/apache2/sites-available/byu-590r-backend.conf > /dev/null << 'APACHE_BACKEND_EOF'
<VirtualHost *:4444>
    ServerName localhost
    DocumentRoot /var/www/html/api/public
    
    <Directory /var/www/html/api/public>
        AllowOverride All
        Require all granted
        
        # Laravel routing
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ index.php [QSA,L]
        
        # Set index files
        DirectoryIndex index.php index.html
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/byu590r_backend_error.log
    CustomLog ${APACHE_LOG_DIR}/byu590r_backend_access.log combined
</VirtualHost>
APACHE_BACKEND_EOF

sudo tee /etc/apache2/sites-available/byu-590r-frontend.conf > /dev/null << 'APACHE_FRONTEND_EOF'
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html/app/browser
    
    <Directory /var/www/html/app/browser>
        AllowOverride All
        Require all granted
        
        # Angular routing support
        RewriteEngine On
        RewriteRule ^index\.html$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /index.html [L]
        
        # Set index files
        DirectoryIndex index.html
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/byu590r_frontend_error.log
    CustomLog ${APACHE_LOG_DIR}/byu590r_frontend_access.log combined
</VirtualHost>
APACHE_FRONTEND_EOF

# Enable sites and disable default
sudo a2ensite byu-590r-backend.conf
sudo a2ensite byu-590r-frontend.conf
sudo a2dissite 000-default

# Add ports to Apache configuration
echo "Listen 4444" | sudo tee -a /etc/apache2/ports.conf

sudo systemctl reload apache2

# Final Apache restart to ensure all changes take effect
sudo systemctl restart apache2
echo "[SUCCESS] Apache configuration complete"

# Set proper permissions for Laravel (if directories exist)
if [ -d "/var/www/html/api" ]; then
    sudo chown -R www-data:www-data /var/www/html/api
    sudo chmod -R 755 /var/www/html/api
    
    # Create Laravel directories if they don't exist
    sudo mkdir -p /var/www/html/api/storage
    sudo mkdir -p /var/www/html/api/bootstrap/cache
    
    # Set permissions for Laravel-specific directories
    sudo chmod -R 775 /var/www/html/api/storage
    sudo chmod -R 775 /var/www/html/api/bootstrap/cache
else
    echo "[INFO] Laravel application directory not found yet - permissions will be set during deployment"
fi

# Ensure Laravel can write to all necessary directories (if they exist)
if [ -d "/var/www/html/api/storage" ]; then
    sudo mkdir -p /var/www/html/api/storage/logs
    sudo mkdir -p /var/www/html/api/storage/framework
    sudo mkdir -p /var/www/html/api/storage/app
    sudo chmod -R 775 /var/www/html/api/storage/logs
    sudo chmod -R 775 /var/www/html/api/storage/framework
    sudo chmod -R 775 /var/www/html/api/storage/app
fi

# Create .env file if it doesn't exist
if [ ! -f /var/www/html/api/.env ]; then
    if [ -f /var/www/html/api/.env.example ]; then
        sudo cp /var/www/html/api/.env.example /var/www/html/api/.env
        sudo chown www-data:www-data /var/www/html/api/.env
        sudo chmod 644 /var/www/html/api/.env
        echo "[SUCCESS] Created .env file from .env.example"
    else
        echo "[INFO] .env.example not found - .env will be created during deployment"
    fi
fi

echo "Server setup complete! Ready for GitHub Actions deployment."
EOF
}

# Null resource to upload book images to S3 after buckets are ready
resource "null_resource" "upload_book_images_dev" {
  depends_on = [
    aws_s3_bucket.dev,
    aws_s3_bucket_public_access_block.dev
  ]

  provisioner "local-exec" {
    command     = "${path.module}/scripts/upload_images.sh ${aws_s3_bucket.dev.id} ${abspath(var.books_dir)}"
    working_dir = path.module
    on_failure  = continue
  }

  triggers = {
    dev_bucket_id = aws_s3_bucket.dev.id
    books_dir     = var.books_dir
  }
}

resource "null_resource" "upload_book_images_prod" {
  depends_on = [
    aws_s3_bucket.prod,
    aws_s3_bucket_public_access_block.prod
  ]

  provisioner "local-exec" {
    command     = "${path.module}/scripts/upload_images.sh ${aws_s3_bucket.prod.id} ${abspath(var.books_dir)}"
    working_dir = path.module
    on_failure  = continue
  }

  triggers = {
    prod_bucket_id = aws_s3_bucket.prod.id
    books_dir      = var.books_dir
  }
}

