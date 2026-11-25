#!/bin/bash
set -euxo pipefail

dnf install -y docker git
systemctl enable --now docker

cd /opt
git clone https://github.com/asajjad82/aws-devops-api.git
cd aws-devops-api
docker build -t aws-devops-api:latest .
docker run -d --restart unless-stopped -p 80:3000 --name api aws-devops-api:latest