#!/bin/bash

# 安装 Node.js
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum install -y nodejs

# 安装 MongoDB
echo '[mongodb-org-4.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc' | sudo tee /etc/yum.repos.d/mongodb-org.repo

# 安装MongoDB
sudo yum install -y mongodb-org

# 启动MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# 安装 Nginx
sudo yum install -y epel-release
sudo yum install -y nginx

# 创建 Nginx 配置文件
echo 'server {
    listen 80;
    server_name 113.44.92.80;

    location / {
        root /var/www/chat-app/client/dist;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /socket.io/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}' | sudo tee /etc/nginx/conf.d/chat.conf

# 启动Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# 创建项目目录
sudo mkdir -p /var/www/chat-app/{client,server}

# 复制项目文件
# 注意：这里需要先准备好项目文件
cd /var/www/chat-app

# 安装依赖并构建前端
cd client
npm install
npm run build

# 安装后端依赖并启动
cd ../server
npm install
sudo npm install -g pm2
pm2 start app.js

# 配置防火墙
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=27017/tcp
sudo firewall-cmd --reload

# 安装基本安全工具
sudo yum install -y fail2ban

# 配置 fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# 启动 fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# 设置 MongoDB 认证
mongo admin --eval 'db.createUser({user: "admin", pwd: "your_secure_password", roles: ["root"]})'

# 配置 MongoDB 认证
echo 'security:
  authorization: enabled' | sudo tee -a /etc/mongod.conf

# 重启 MongoDB
sudo systemctl restart mongod

# 设置正确的文件权限
sudo chown -R nginx:nginx /var/www/chat-app
sudo chmod -R 755 /var/www/chat-app

echo "部署完成！" 