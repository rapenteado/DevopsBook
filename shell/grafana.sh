#!/bin/bash

sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/oss/release/grafana_9.3.6_amd64.deb
sudo dpkg -i grafana_9.3.6_amd64.deb

sudo apt update -y

sudo apt-get install grafana

sudo systemctl start grafana-server
sudo systemctl enable grafana-server