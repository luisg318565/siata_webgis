#!/bin/sh
# =====================================================================
# Automatizacion de publicacion OGC en GeoServer via REST API
#
# Crea workspace -> datastore (PostGIS) -> capa publicada, dejando la
# capa de coberturas disponible como WMS y WFS sin intervencion manual.
# Idempotente: verifica existencia antes de crear cada recurso.
# =====================================================================
set -e

GS_URL="http://${GEOSERVER_HOST}:8080/geoserver/rest"
GS_AUTH="${GEOSERVER_ADMIN_USER}:${GEOSERVER_ADMIN_PASSWORD}"
WS="${GEOSERVER_WORKSPACE}"
DS="${GEOSERVER_DATASTORE}"
LAYER="${GEOSERVER_LAYER}"

echo "[geoserver-init] Esperando disponibilidad de GeoServer..."
until curl -s -f -u "$GS_AUTH" "$GS_URL/about/version.json" > /dev/null 2>&1; do
    echo "[geoserver-init]  ... aun no disponible, reintentando en 5s"
    sleep 5
done
echo "[geoserver-init] GeoServer disponible."

# ---------------------------------------------------------------------
# 1. Workspace
# ---------------------------------------------------------------------
if curl -s -f -u "$GS_AUTH" "$GS_URL/workspaces/$WS.json" > /dev/null 2>&1; then
    echo "[geoserver-init] Workspace '$WS' ya existe, se omite creacion."
else
    echo "[geoserver-init] Creando workspace '$WS'..."
    curl -s -f -u "$GS_AUTH" -X POST \
        -H "Content-Type: application/json" \
        -d "{\"workspace\": {\"name\": \"$WS\"}}" \
        "$GS_URL/workspaces"
fi

# ---------------------------------------------------------------------
# 2. Datastore (conexion a PostGIS)
# ---------------------------------------------------------------------
if curl -s -f -u "$GS_AUTH" "$GS_URL/workspaces/$WS/datastores/$DS.json" > /dev/null 2>&1; then
    echo "[geoserver-init] Datastore '$DS' ya existe, se omite creacion."
else
    echo "[geoserver-init] Creando datastore '$DS' -> PostGIS..."
    curl -s -f -u "$GS_AUTH" -X POST \
        -H "Content-Type: application/json" \
        -d "{
            \"dataStore\": {
                \"name\": \"$DS\",
                \"connectionParameters\": {
                    \"entry\": [
                        {\"@key\": \"host\", \"$\": \"${POSTGRES_HOST}\"},
                        {\"@key\": \"port\", \"$\": \"5432\"},
                        {\"@key\": \"database\", \"$\": \"${POSTGRES_DB}\"},
                        {\"@key\": \"user\", \"$\": \"${POSTGRES_USER}\"},
                        {\"@key\": \"passwd\", \"$\": \"${POSTGRES_PASSWORD}\"},
                        {\"@key\": \"dbtype\", \"$\": \"postgis\"},
                        {\"@key\": \"schema\", \"$\": \"public\"},
                        {\"@key\": \"Expose primary keys\", \"$\": \"true\"}
                    ]
                }
            }
        }" \
        "$GS_URL/workspaces/$WS/datastores"
fi

# ---------------------------------------------------------------------
# 3. Publicar la capa (feature type) desde la tabla 'coberturas'
# ---------------------------------------------------------------------
if curl -s -f -u "$GS_AUTH" "$GS_URL/workspaces/$WS/datastores/$DS/featuretypes/$LAYER.json" > /dev/null 2>&1; then
    echo "[geoserver-init] Capa '$LAYER' ya publicada, se omite creacion."
else
    echo "[geoserver-init] Publicando capa '$LAYER'..."
    curl -s -f -u "$GS_AUTH" -X POST \
        -H "Content-Type: application/json" \
        -d "{
            \"featureType\": {
                \"name\": \"$LAYER\",
                \"nativeName\": \"coberturas\",
                \"title\": \"Coberturas de la Tierra CLC - Valle de Aburra\",
                \"srs\": \"EPSG:4326\",
                \"enabled\": true
            }
        }" \
        "$GS_URL/workspaces/$WS/datastores/$DS/featuretypes"
fi

# ---------------------------------------------------------------------
# 4. Estilo (SLD): 23 clases con colores oficiales IDEAM, por nivel_3
# ---------------------------------------------------------------------
STYLE_NAME="coberturas_clc"

if curl -s -f -u "$GS_AUTH" "$GS_URL/workspaces/$WS/styles/$STYLE_NAME.json" > /dev/null 2>&1; then
    echo "[geoserver-init] Estilo '$STYLE_NAME' ya existe, se actualiza el SLD..."
    curl -s -f -u "$GS_AUTH" -X PUT \
        -H "Content-Type: application/vnd.ogc.sld+xml" \
        --data-binary @/scripts/coberturas.sld \
        "$GS_URL/workspaces/$WS/styles/$STYLE_NAME"
else
    echo "[geoserver-init] Creando estilo '$STYLE_NAME'..."
    curl -s -f -u "$GS_AUTH" -X POST \
        -H "Content-Type: application/vnd.ogc.sld+xml" \
        --data-binary @/scripts/coberturas.sld \
        "$GS_URL/workspaces/$WS/styles?name=$STYLE_NAME"
fi

echo "[geoserver-init] Asignando estilo '$STYLE_NAME' como estilo por defecto de la capa..."
curl -s -f -u "$GS_AUTH" -X PUT \
    -H "Content-Type: application/json" \
    -d "{\"layer\": {\"defaultStyle\": {\"name\": \"$STYLE_NAME\", \"workspace\": \"$WS\"}}}" \
    "$GS_URL/layers/$WS:$LAYER"

echo "[geoserver-init] Estilo aplicado correctamente."
echo "[geoserver-init] Publicacion OGC completada."
echo "[geoserver-init] WMS:  $GS_URL/../$WS/wms?service=WMS&version=1.1.0&request=GetCapabilities"
echo "[geoserver-init] WFS:  $GS_URL/../$WS/wfs?service=WFS&version=2.0.0&request=GetCapabilities"