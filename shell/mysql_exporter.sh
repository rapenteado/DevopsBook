#!/bin/bash

sudo useradd -m -s /bin/false mysqld_exporter
sudo mkdir /etc/mysqld_exporter
sudo chown mysqld_exporter /etc/mysqld_exporter/

wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.12.1/mysqld_exporter-0.12.1.linux-amd64.tar.gz -P /tmp

cd /tmp
sudo tar -zxpvf mysqld_exporter-0.12.1.linux-amd64.tar.gz
cd /tmp/mysqld_exporter-0.12.1.linux-amd64
sudo cp mysqld_exporter /usr/local/bin
sudo chown mysqld_exporter /usr/local/bin/mysqld_exporter

sudo mysqladmin -u root
sudo mysql -u root -e "CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'StrongPassword' WITH MAX_USER_CONNECTIONS 3;"
sudo mysql -u root -e "GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES"

sudo cat << EOF > /etc/.mysqld_exporter.cnf
[client]
user=exporter
password=StrongPassword
host=192.168.0.110
EOF

sudo chown root:mysqld_exporter /etc/.mysqld_exporter.cnf

###Service config
sudo cat << EOF > /etc/systemd/system/mysqld_exporter.service
[Unit]
Description=Prometheus MySQL Exporter
After=network.target
User=mysqld_exporter
Group=mysqld_exporter

[Service]
Type=simple
Restart=always
ExecStart=/usr/local/bin/mysqld_exporter \
--config.my-cnf /etc/.mysqld_exporter.cnf \
--collect.global_status \
--collect.info_schema.innodb_metrics \
--collect.auto_increment.columns \
--collect.info_schema.processlist \
--collect.binlog_size \
--collect.info_schema.tablestats \
--collect.global_variables \
--collect.info_schema.query_response_time \
--collect.info_schema.userstats \
--collect.info_schema.tables \
--collect.perf_schema.tablelocks \
--collect.perf_schema.file_events \
--collect.perf_schema.eventswaits \
--collect.perf_schema.indexiowaits \
--collect.perf_schema.tableiowaits \
--collect.slave_status \
--web.listen-address=0.0.0.0:9114

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
