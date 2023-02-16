# adding repository and installing nginx		

apt update

apt install nginx -y

sudo cat << EOF > /etc/nginx/conf.d/nginx_export.conf
server {
  listen 9113;
  server_name localhost;

  access_log off;
  allow 127.0.0.1;
     
  location /metrics {
    stub_status on;
  }
}
EOF

#starting nginx service and firewall
systemctl enable nginx
systemctl restart nginx