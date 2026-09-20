#!/bin/sh
# =====================================================================
# Carga de la capa de coberturas CLC (Shapefile -> PostGIS) via GDAL/OGR
#
# Se ejecuta como servicio efimero de Docker Compose, una sola vez, tras
# confirmar que la base de datos esta disponible. La carga es idempotente:
# si la tabla ya contiene registros, el proceso no vuelve a insertarlos.
# =====================================================================
set -e

SHP="/data/clc_clip_med.shp"
CAPA_ORIGEN="clc_clip_med"
TABLA_DESTINO="coberturas"
SRID_DESTINO="EPSG:4326"

PG_CONN="host=${POSTGRES_HOST} port=5432 dbname=${POSTGRES_DB} user=${POSTGRES_USER} password=${POSTGRES_PASSWORD}"

echo "[loader] Verificando archivo de entrada..."
if [ ! -f "$SHP" ]; then
    echo "[loader] ERROR: no se encontro el Shapefile en $SHP"
    exit 1
fi

echo "[loader] Consultando estado actual de la tabla '$TABLA_DESTINO'..."
REGISTROS=$(ogrinfo -q PG:"$PG_CONN" \
    -sql "SELECT COUNT(*) AS n FROM $TABLA_DESTINO" 2>/dev/null \
    | grep -oE '= [0-9]+' | grep -oE '[0-9]+' || echo "0")

if [ "$REGISTROS" -gt 0 ]; then
    echo "[loader] La tabla ya contiene $REGISTROS registros. Se omite la carga."
    exit 0
fi

echo "[loader] Cargando capa con reproyeccion a $SRID_DESTINO..."
# Notas tecnicas:
#  -sql        : selecciona unicamente los atributos de interes y renombra
#                'confiabili' (truncado por el formato DBF) a su nombre completo.
#  -t_srs      : reproyecta desde EPSG:4686 (MAGNA-SIRGAS, CRS de origen IDEAM)
#                hacia EPSG:4326, el CRS de almacenamiento.
#  -append     : inserta sobre la tabla ya creada por los scripts de esquema,
#                preservando el modelo de datos definido explicitamente.
#  -nlt        : fuerza tipo MULTIPOLYGON, coherente con la columna declarada.
ogr2ogr \
    -f PostgreSQL \
    PG:"$PG_CONN" \
    "$SHP" \
    -sql "SELECT codigo, leyenda, nivel_1, nivel_2, nivel_3, nivel_4, nivel_5, nivel_6, confiabili AS confiabilidad FROM $CAPA_ORIGEN" \
    -nln "$TABLA_DESTINO" \
    -append \
    -t_srs "$SRID_DESTINO" \
    -nlt MULTIPOLYGON \
    --config PG_USE_COPY YES

echo "[loader] Verificando resultado de la carga..."
ogrinfo -q PG:"$PG_CONN" -sql "SELECT COUNT(*) AS poligonos FROM $TABLA_DESTINO"

echo "[loader] Actualizando estadisticas del planificador..."
ogrinfo -q PG:"$PG_CONN" -sql "ANALYZE $TABLA_DESTINO" > /dev/null 2>&1 || true

echo "[loader] Carga completada correctamente."