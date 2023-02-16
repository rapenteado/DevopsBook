#!/bin/bash

sudo useradd -m -s /bin/false nginx-exporter
sudo mkdir /etc/nginx-exporter
sudo chown nginx-exporter /etc/nginx-exporter/

wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v0.7.0/nginx-prometheus-exporter-0.7.0-linux-amd64.tar.gz -P /tmp

cd /tmp
tar -xf nginx-prometheus-exporter-0.7.0-linux-amd64.tar.gz 

cd /tmp
sudo tar -zxpvf nginx-prometheus-exporter-0.7.0-linux-amd64.tar.gz
cd /tmp/nginx-prometheus-exporter-0.7.0-linux-amd64.tar.gz
sudo mv nginx-prometheus-exporter nginx-exporter
sudo cp nginx-exporter /usr/local/bin
sudo chown nginx-exporter /usr/local/bin/nginx-exporter

sudo cat << EOF > /etc/systemd/system/nginx-exporter.service
[Unit]
Description=Nginx Exporter
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=0

[Service]
User=nginx-exporter
Group=nginx-exporter
Type=simple
Restart=on-failure
RestartSec=5s

ExecStart=/usr/local/bin/nginx-exporter \
    -nginx.scrape-uri=http://localhost:9113/metrics

[Install]
WantedBy=multi-user.target
EOF

##Firewall rules
sudo firewall-cmd --add-port=9113/tcp --permanent
sudo firewall-cmd --reload

##Reload system
sudo systemctl daemon-reload
sudo systemctl start nginx-exporter
sudo systemctl enable nginx-exporter


