#!/bin/bash

sudo apt update -y
sudo apt install wget -y

sudo useradd -m -s /bin/false node_exporter
sudo mkdir /etc/node_exporter
sudo chown node_exporter /etc/node_exporter/

wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz -P /tmp

cd /tmp
sudo tar -zxpvf node_exporter-1.5.0.linux-amd64.tar.gz
cd /tmp/node_exporter-1.5.0.linux-amd64
sudo cp node_exporter /usr/bin/
sudo chown node_exporter /usr/bin/node_exporter

sudo cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
ExecStart=/usr/bin/node_exporter \
  --web.listen-address=:9200

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start node_exporter.service
sudo systemctl enable node_exporter.service

sudo rm -rf node_exporter-*