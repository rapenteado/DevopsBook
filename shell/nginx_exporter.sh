#!/bin/bash

## Install Nginx Prometheus Exporter ##

# Create a dedicated user and group
sudo useradd --system --no-create-home --shell /bin/false nginx-exporter

# Dowload de package and install
sudo wget http://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v0.11.0/nginx-prometheus-exporter_0.11.0_linux_amd64.tar.gz 
sudo tar -zxf nginx-prometheus-exporter_0.11.0_linux_amd64.tar.gz
sudo rm nginx-prometheus-exporter_0.11.0_linux_amd64.tar.gz
sudo chown nginx-exporter:nginx-exporter /opt/nginx-prometheus-exporter

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

ExecStart=/opt/nginx-prometheus-exporter \
    -nginx.scrape-uri=http://localhost:8080/status

[Install]
WantedBy=multi-user.target
EOF

# Reload system
sudo systemctl enable nginx-exporter
sudo systemctl start nginx-exporter

# Firewall rules
sudo firewall-cmd --add-port=9113/tcp --permanent
sudo firewall-cmd --reload
