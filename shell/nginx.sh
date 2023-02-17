# adding repository and installing nginx		

sudo apt update
sudo apt install wget -y
sudo apt install nginx -y

sudo cat << EOF > /etc/nginx/conf.d/nginx_export.conf
server {
  listen 8080;
  server_name localhost;

  access_log off;
  allow 127.0.0.1;
     
  location /status {
    stub_status on;
  }
}
EOF

#starting nginx service and firewall
sudo systemctl enable nginx
sudo systemctl restart nginx