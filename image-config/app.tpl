#!/bin/bash
set -e

echo ">>>>>>>>>>>>> nginx config  >>>>>>>>>>>>>"

rm -rf /etc/nginx/sites-available/default

cat > /etc/nginx/sites-available/default <<EOF
server {
    listen       80 default_server;
    listen       [::]:80 default_server;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
   location /health {
     return 200 ok;
     add_header Content-Type text/plain;
    }
    error_page 404 /404.html;
        location = /40x.html {
    }

    error_page 500 502 503 504 /50x.html;
        location = /50x.html {
    }
}
EOF

cd /etc/nginx/sites-enabled

ln -sf /etc/nginx/sites-available/default default

service nginx restart

echo ""
