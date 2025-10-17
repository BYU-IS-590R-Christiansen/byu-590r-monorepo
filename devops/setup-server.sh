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
sudo apt install -y php8.3 php8.3-fpm php8.3-mysql php8.3-xml php8.3-mbstring php8.3-curl php8.3-zip php8.3-gd php8.3-cli php8.3-common

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Install MySQL
sudo apt install -y mysql-server
sudo systemctl enable mysql
sudo systemctl start mysql

# Install Nginx
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Install Git
sudo apt install -y git

# Create application directories
sudo mkdir -p /var/www/byu-590r/backend
sudo mkdir -p /var/www/byu-590r/frontend
sudo chown -R ubuntu:ubuntu /var/www/byu-590r

# Create database and user
sudo mysql -u root << 'MYSQL_EOF'
CREATE DATABASE IF NOT EXISTS byu_590r_app;
CREATE USER IF NOT EXISTS 'byu_user'@'localhost' IDENTIFIED BY 'byu590r123!';
GRANT ALL PRIVILEGES ON byu_590r_app.* TO 'byu_user'@'localhost';
FLUSH PRIVILEGES;
MYSQL_EOF

# Configure Nginx
sudo tee /etc/nginx/sites-available/byu-590r > /dev/null << 'NGINX_EOF'
server {
    listen 80;
    server_name _;
    
    root /var/www/byu-590r/frontend/dist/byu-590r-builder;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX_EOF

sudo ln -sf /etc/nginx/sites-available/byu-590r /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

# Create systemd service for Laravel (but don't start it yet)
sudo tee /etc/systemd/system/byu-590r-laravel.service > /dev/null << 'SERVICE_EOF'
[Unit]
Description=BYU 590R Laravel Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/var/www/byu-590r/backend
ExecStart=/usr/bin/php artisan serve --host=0.0.0.0 --port=8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE_EOF

sudo systemctl daemon-reload
sudo systemctl enable byu-590r-laravel

echo "Server setup complete! Ready for GitHub Actions deployment."
