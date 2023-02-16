#!/bin/bash

sudo apt update -y

sudo apt-get install grafana

sudo systemctl start grafana-server
sudo systemctl enable grafana-server