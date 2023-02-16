#!/bin/bash
DATABASE_PASS='admin123'

sudo useradd -m -s /bin/false mysqld_exporter
sudo mkdir /etc/mysqld_exporter
sudo chown mysqld_exporter /etc/mysqld_exporter/

wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.12.1/mysqld_exporter-0.12.1.linux-amd64.tar.gz -P /tmp

cd /tmp
sudo tar -zxpvf mysqld_exporter-0.12.1.linux-amd64.tar.gz
cd /tmp/mysqld_exporter-0.12.1.linux-amd64
sudo cp mysqld_exporter /usr/local/bin
sudo chown mysqld_exporter /usr/local/bin/mysqld_exporter

sudo mysqladmin -u admin password "$DATABASE_PASS"
sudo mysql -u admin -p"$DATABASE_PASS" -e "CREATE USER 'exporter'@'localhost' IDENTIFIED BY '$DATABASE_PASS' WITH MAX_USER_CONNECTIONS 3;"
sudo mysql -u admin -p"$DATABASE_PASS" -e "GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';"
sudo mysql -u admin -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

###Service config
sudo cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Documentation=https://prometheus.io/docs/guides/mysqld_exporter/
Wants=network-online.target
After=network-online.target

[Service]
User=mysqld_exporter
Group=mysqld_exporter
Type=simple
Restart=on-failure
ExecStart=/usr/local/bin/mysqld_exporter \
  --web.listen-address=:9114

[Install]
WantedBy=multi-user.target
EOF

##Reload system
sudo systemctl daemon-reload
sudo systemctl start mysqld_exporter
sudo systemctl enable mysqld_exporter

##Firewall rules
sudo firewall-cmd --add-port=9114/tcp --permanent
sudo firewall-cmd --reload
