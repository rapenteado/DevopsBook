#!/bin/bash

sudo yum update -y
sudo yum install epel-release -y
sudo yum install git zip unzip -y

sudo useradd -m -s /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus /var/lib/prometheus/
sudo dnf install wget -y
wget https://github.com/prometheus/prometheus/releases/download/v2.14.0/prometheus-2.14.0.linux-amd64.tar.gz -P /tmp

cd /tmp
sudo tar -zxpvf prometheus-2.14.0.linux-amd64.tar.gz
cd /tmp/prometheus-2.14.0.linux-amd64
sudo cp prometheus  /usr/local/bin
sudo cp promtool  /usr/local/bin
sudo cat << EOF > /etc/prometheus/prometheus.yml
# Global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute. 
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute. 
  scrape_timeout: 15s  # scrape_timeout is set to the global default (10s).
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']
EOF

sudo firewall-cmd --add-port=9090/tcp --permanent
sudo firewall-cmd --reload

sudo cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Time Series Collection and Processing Server
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
