#! /bin/bash
sudo apt-get update
sudo apt install nginx -y
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo certbot run -n --nginx --agree-tos -d apptestquickapp.eastasia.cloudapp.azure.com -m chivy1204@gmail.com  --redirect