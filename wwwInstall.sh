# run install www service
# Change into the www directory
cd www

# Install ember-cli and bower globally
sudo npm install -g ember-cli@2.18.2
sudo npm install -g bower

# Change ownership of npm and config directories
sudo chown -R $USER:$GROUP ~/.npm
sudo chown -R $USER:$GROUP ~/.config

# Install npm and bower dependencies
npm install
bower install

# Install ember-truth-helpers
ember install ember-truth-helpers

# Install jdenticon
npm install jdenticon@2.1.0

# Run the build.sh script within the www directory
bash build.sh

# Change back to the main directory
cd ..

# Nginx configuration
nginx_config=$(cat <<EOF
upstream api {
    server 127.0.0.1:8080;
}

server {
    listen *:80;
    listen [::]:80;
    root /var/www/etc2pool;

    index index.html index.htm index.nginx-debian.html;
    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location /api {
        proxy_pass http://127.0.0.1:8080;
    }
}
EOF
)

# Path to the pool configuration file
pool_config_path="/etc/nginx/sites-available/pool"

# Write the Nginx configuration to the pool configuration file
echo "$nginx_config" | sudo tee "$pool_config_path" > /dev/null

# Create a symbolic link in the sites-enabled directory
sudo ln -s "$pool_config_path" "/etc/nginx/sites-enabled/"

# Restart Nginx to apply the changes
sudo systemctl restart nginx

set +x  # Disable displaying commands
echo "Installation completed!"
