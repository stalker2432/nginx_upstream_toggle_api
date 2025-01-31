A lightweight Python Flask API to handle HTTP requests.
Calls the existing Bash script to modify the Nginx config.
Responds with success or failure messages.

Install Flask if you haven’t already:
pip install flask

Flask service exposes two HTTP endpoints:
POST /enable → Enables a server in the upstream block.
POST /disable → Disables a server in the upstream block.


################

How bash script works:
Takes a virtual host config file, an upstream name, a server IP/hostname, and a mode (enable or disable).
Edits only the specified upstream in the given virtual host config.
Comments (#) out the server line to disable it.
Uncomments it to enable it.
Restarts Nginx after changes.

################

Run as a service
sudo nano /etc/systemd/system/nginx-upstream.service

sudo systemctl daemon-reload
sudo systemctl enable nginx-upstream
sudo systemctl start nginx-upstream
sudo systemctl status nginx-upstream


Example to use:

curl -X POST http://localhost:6000/disable \
     -H "Content-Type: application/json" \
     -d '{
           "vhost_config": "/etc/nginx/sites-available/api-atqaapp01.deliverdog.com.conf",
           "upstream_name": "api-atqaapp01_upstream",
           "server": "qa-web01"
         }'
{"message":"Successfully disabled qa-web01 in upstream api-atqaapp01_upstream"}


 curl -X POST http://localhost:6000/enable \
     -H "Content-Type: application/json" \
     -d '{
           "vhost_config": "/etc/nginx/sites-available/api-atqaapp01.deliverdog.com.conf",
           "upstream_name": "api-atqaapp01_upstream",
           "server": "qa-web01"
         }'
{"message":"Successfully enabled qa-web01 in upstream api-atqaapp01_upstream"}
