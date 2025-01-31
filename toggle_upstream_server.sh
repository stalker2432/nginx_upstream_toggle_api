#!/bin/bash

# Usage: ./toggle_upstream_server.sh <vhost_config_path> <upstream_name> <server_ip_or_hostname> <enable|disable>
# Example: ./toggle_upstream_server.sh /etc/nginx/sites-available/example.com my_upstream backend1.example.com disable

VHOST_CONFIG=$1
UPSTREAM_NAME=$2
SERVER=$3
MODE=$4

if [[ -z "$VHOST_CONFIG" || -z "$UPSTREAM_NAME" || -z "$SERVER" || -z "$MODE" ]]; then
  echo "Usage: $0 <vhost_config_path> <upstream_name> <server_ip_or_hostname> <enable|disable>"
  exit 1
fi

if [[ ! -f "$VHOST_CONFIG" ]]; then
  echo "Error: Virtual host config file not found: $VHOST_CONFIG"
  exit 1
fi

if [[ "$MODE" != "enable" && "$MODE" != "disable" ]]; then
  echo "Error: Mode must be 'enable' or 'disable'"
  exit 1
fi

# Backup original config
cp "$VHOST_CONFIG" "$VHOST_CONFIG.bak"

# Enable or disable the specific server inside the upstream block
if [[ "$MODE" == "disable" ]]; then
  sed -i "/upstream $UPSTREAM_NAME {/,/}/ s/^\(\s*\)server $SERVER/\1# server $SERVER/" "$VHOST_CONFIG"
  echo "Disabled server '$SERVER' in upstream '$UPSTREAM_NAME' in $VHOST_CONFIG"
elif [[ "$MODE" == "enable" ]]; then
  sed -i "/upstream $UPSTREAM_NAME {/,/}/ s/^\(\s*\)#\s*server $SERVER/\1server $SERVER/" "$VHOST_CONFIG"
  echo "Enabled server '$SERVER' in upstream '$UPSTREAM_NAME' in $VHOST_CONFIG"
fi

# Test and reload Nginx
nginx -t && systemctl reload nginx

if [[ $? -eq 0 ]]; then
  echo "Nginx reloaded successfully."
else
  echo "Error reloading Nginx. Restoring backup."
  mv "$VHOST_CONFIG.bak" "$VHOST_CONFIG"
fi
