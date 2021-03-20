upstream app {
  #server unix:/tmp/unicorn.mau.sock fail_timeout=0;

  # Path to Puma SOCK file, as defined previously
  server unix:/home/deploy/deployed/mau/shared/tmp/sockets/puma.sock fail_timeout=0;

}

server {
  server_name mau.rcode5.com openstudios.mau.rcode5.com;
  root /home/deploy/deployed/mau/current/public;

  #For Basic Auth
  auth_basic "Restricted";
  auth_basic_user_file /etc/nginx/.htpasswd;

  location ~ (\.php|.aspx|.asp|myadmin) {
    return 404;
  }

  location = /version {
       auth_basic off;
       allow all; # Allow all to see content 
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://app;
  }

  location = /status {
       auth_basic off;
       allow all; # Allow all to see content 
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://app;
  }

  # location / {
  #   if (-f $document_root/maintenance.html) {
  #     return 503;
  #   }
  # }

  # error_page 503 @maintenance;
  # location @maintenance {
  #   if ($uri !~ ^/images/) {
  #     rewrite ^(.*)$ /maintenance.html break;
  #   }
  # }

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
    if ($request_filename ~* \.(eot|woff|woff2|ttf|svg)$) {
      add_header Access-Control-Allow-Origin *;
    }
    if ($request_filename ~* \.woff2$) {
      add_header Content-Type "application/woff2";
    }
  }

  try_files $uri/index.html $uri @app;
  location @app {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-SSL-Client-Cert $ssl_client_cert;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://app;

  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 20M;
  keepalive_timeout 10;

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/mau.rcode5.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/mau.rcode5.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot


    # Redirect non-https traffic to https
    if ($scheme != "https") {
        return 301 https://$host$request_uri;
    } # managed by Certbot

}

server {
    if ($host = mau.rcode5.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


  listen 80 default_server deferred;
  server_name mau.rcode5.com;
    return 404; # managed by Certbot


}


server {
    if ($host = openstudios.mau.rcode5.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


  server_name openstudios.mau.rcode5.com;
    listen 80;
    return 404; # managed by Certbot


}
