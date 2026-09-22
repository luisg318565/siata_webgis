#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io docker-compose-v2 git

systemctl start docker
systemctl enable docker

git clone https://github.com/luisg318565/siata_webgis.git /opt/siata-webgis
cd /opt/siata-webgis

cat > .env <<EOF
POSTGRES_USER=siata_user
POSTGRES_PASSWORD=${postgres_password}
POSTGRES_DB=siata_geoespacial
POSTGRES_HOST=db
DATABASE_URL=postgresql+psycopg://siata_user:${postgres_password}@db:5432/siata_geoespacial

GEOSERVER_ADMIN_USER=admin
GEOSERVER_ADMIN_PASSWORD=${geoserver_admin_password}
GEOSERVER_WORKSPACE=siata
GEOSERVER_DATASTORE=postgis_coberturas
GEOSERVER_LAYER=coberturas
EOF

docker compose up -d --build