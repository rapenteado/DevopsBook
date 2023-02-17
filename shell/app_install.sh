#!/bin/bash

sudo apt update
sudo apt install python3-pip -y
sudo apt install unzip
sudo pip install flask
sudo pip install gunicorn
sudo mkdir /opt/myapp

cd /opt/myapp
wget http://github.com/rapenteado/simple_app_falsk/archive/refs/heads/main.zip
sudo unzip main.zip -d /opt/myapp
sudo useradd --system --no-create-home --shell /bin/false myapp
chown -R myapp:myapp /opt/myapp


sudo cat << EOF > /etc/systemd/system/myapp.service 
[Unit]
Description=My App
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=myapp
Group=myapp
Type=simple
Restart=on-failure
RestartSec=5s

WorkingDirectory=/opt/myapp
ExecStart=/usr/local/bin/gunicorn -w 4 'app:app' --bind 127.0.0.1:8282

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable myapp
sudo systemctl start myapp
sudo systemctl status myapp

sudo cat << EOF > /etc/nginx/conf.d/myapp.conf
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8282/;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Prefix /;
    }
}
EOF

sudo rm /etc/nginx/conf.d/default.conf

sudo nginx -t
sudo systemctl reload nginx
