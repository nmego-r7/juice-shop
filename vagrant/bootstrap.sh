#!/bin/sh

#
# Copyright (c) 2014-2022 Bjoern Kimminich & the OWASP Juice Shop contributors.
# SPDX-License-Identifier: MIT
#

# Exit on error
set -e

# Install dirmngr
apt-get update -q
apt-get install -qy dirmngr --install-recommends

# Install curl, add-apt-key and pull the gpg key
apt-get install -qy curl software-properties-common apt-transport-https ca-certificates
# apt-get install -qy add-apt-key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add docker key and repository
# apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9DC858229FC7DD38854AE2D88D81803C0EBFCD88
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/docker.list
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

# Install apache and docker
apt-get update -q
apt-get upgrade -qy
apt-get install -qy apache2 docker-ce

# Install make, gcc, g++, build-essential
apt-get install -qy make
apt-get install -qy gcc g++ build-essential

# Install ppa dependency and set up PPA for deadsnakes
add-apt-repository ppa:deadsnakes/ppa -y
apt-get update -q

# Install Python 3.10 and set to default
apt-get install -qy python3.10
# update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
# update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2

# Set env variables
TCELL_AGENT_APP_ID="NMMJuiceNo-BHXj9"
TCELL_AGENT_API_KEY="AQQBBAGq9Iu1Kr1J0Y9wN67ZYgfe1zRoaTOrRP2RuQhM6JS9DVogMf7AYKaeHAsxOcw5fM8"
TCELL_AGENT_API_URL="https://us.agent.tcell.insight.rapid7.com/api/v1"
TCELL_AGENT_INPUT_URL="https://us.input.tcell.insight.rapid7.com/api/v1"
TCELL_AGENT_JS_AGENT_API_URL="https://us.agent.tcell.insight.rapid7.com/api/v1"

# Put the relevant files in place
cp /tmp/juice-shop/default.conf /etc/apache2/sites-available/000-default.conf

echo "At docker run"

# docker run --restart=always -d -p 3000:3000 --name juice-shop bkimminich/juice-shop
docker run --restart=always -d -p 3000:3000 -e TCELL_AGENT_APP_ID -e TCELL_AGENT_API_KEY -e TCELL_AGENT_API_URL -e TCELL_AGENT_INPUT_URL -e TCELL_AGENT_JS_AGENT_API_URL --name juice-shop nmego-r7/juice-shop

# Download and start docker image with Juice Shop
# sed -i "li require('tcell_agent');" ../server.ts

# Enable proxy modules in apache and restart
a2enmod proxy_http
# systemctl restart apache2.service
systemctl restart apache2
