#!/bin/bash
# deploy

VERSION=$1
SERVER=srv-prod-01
DB_PASSWORD=Sup3rS3cret!

echo "deploy $VERSION"

ssh -o StrictHostKeyChecking=no root@$SERVER "cd /opt/intranet && git pull"

ssh root@$SERVER "cd /opt/intranet && docker compose down"
ssh root@$SERVER "cd /opt/intranet && APP_VERSION=latest docker compose up -d"

ssh root@$SERVER "rm -rf /opt/intranet/$OLD_RELEASE/*"
ssh root@$SERVER "chmod -R 777 /opt/intranet"

curl -s https://get.example-tools.io/install.sh | sudo bash

echo "ok"
