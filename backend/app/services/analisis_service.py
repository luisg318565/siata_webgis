import json

from sqlalchemy import text
from sqlalchemy.orm import Session

SRID_GEOGRAFICO = 4326
SRID_PROYECTADO = 9377  # MAGNA-SIRGAS 2018 / Origen-Nacional (metros) CTM12


def verificar_conexion_bd(db: Session) -> dict:
    """Confirma que el backend tiene conectividad activa con PostGIS,
    y reporta cuantos registros de coberturas hay cargados."""
    resultado = db.execute(text("SELECT COUNT(*) FROM coberturas")).scalar_one()
    return {"status": "ok", "database": "connected", "coberturas_cargadas": resultado}


_QUERY_INTERSECCION_POR_GEOMETRIA = text("""
    SELECT
        id, codigo, leyenda, nivel_3,
        ROUND((ST_Area(ST_Transform(
            ST_Intersection(geom, ST_SetSRID(ST_GeomFromGeoJSON(:geojson), :srid_geo)),
        :srid_proy)) / 10000)::numeric, 4) AS area_ha,
        ST_AsGeoJSON(ST_Intersection(geom, ST_SetSRID(ST_GeomFromGeoJSON(:geojson), :srid_geo))) AS interseccion_geojson
    FROM coberturas
    WHERE ST_Intersects(geom, ST_SetSRID(ST_GeomFromGeoJSON(:geojson), :srid_geo))
    ORDER BY area_ha DESC;
""")

_QUERY_INTERSECCION_POR_PUNTO = text("""
    WITH area_consulta AS (
        SELECT ST_Transform(
            ST_Buffer(
                ST_Transform(ST_SetSRID(ST_MakePoint(:lon, :lat), :srid_geo), :srid_proy),
                :radio_m
            ),
        :srid_geo) AS geom
    )
    SELECT
        c.id, c.codigo, c.leyenda, c.nivel_3,
        ROUND((ST_Area(ST_Transform(ST_Intersection(c.geom, a.geom), :srid_proy)) / 10000)::numeric, 4) AS area_ha,
        ST_AsGeoJSON(ST_Intersection(c.geom, a.geom)) AS interseccion_geojson
    FROM coberturas c, area_consulta a
    WHERE ST_Intersects(c.geom, a.geom)
    ORDER BY area_ha DESC;
""")


def consultar_interseccion(
    db: Session,
    geojson: dict | None,
    lat: float | None,
    lon: float | None,
    radio_m: float | None,
) -> dict:
    """
    RF Modulo 3 (Interseccion y Calculo de Area): identifica las coberturas
    interceptadas por un area de interes, y calcula el area REAL de
    interseccion (no el area total de cada poligono) en hectareas.

    Devuelve tanto los poligonos individuales (para representacion
    geografica) como un resumen agregado por clase nivel_3 (para
    reportar cuantos TIPOS de cobertura distintos hay, sumando el area
    de todos los poligonos de una misma clase -- dos poligonos separados
    de la misma categoria cuentan como 1 tipo, no 2).
    """
    if geojson is not None:
        filas = db.execute(
            _QUERY_INTERSECCION_POR_GEOMETRIA,
            {
                "geojson": json.dumps(geojson),
                "srid_geo": SRID_GEOGRAFICO,
                "srid_proy": SRID_PROYECTADO,
            },
        ).mappings().all()
    else:
        filas = db.execute(
            _QUERY_INTERSECCION_POR_PUNTO,
            {
                "lat": lat, "lon": lon, "radio_m": radio_m,
                "srid_geo": SRID_GEOGRAFICO, "srid_proy": SRID_PROYECTADO,
            },
        ).mappings().all()

    features = []
    resumen_por_clase: dict[str, float] = {}
    area_total = 0.0

    for fila in filas:
        area_ha = float(fila["area_ha"])
        area_total += area_ha

        nivel_3 = fila["nivel_3"]
        resumen_por_clase[nivel_3] = resumen_por_clase.get(nivel_3, 0.0) + area_ha

        features.append({
            "type": "Feature",
            "geometry": json.loads(fila["interseccion_geojson"]),
            "properties": {
                "id": fila["id"],
                "codigo": fila["codigo"],
                "leyenda": fila["leyenda"],
                "nivel_3": nivel_3,
                "area_ha": area_ha,
            },
        })

    resumen = sorted(
        [{"nivel_3": k, "area_ha": round(v, 4)} for k, v in resumen_por_clase.items()],
        key=lambda r: r["area_ha"],
        reverse=True,
    )

    return {
        "type": "FeatureCollection",
        "area_total_ha": round(area_total, 4),
        "cantidad_coberturas": len(resumen),
        "resumen_por_clase": resumen,
        "features": features,
    }


_QUERY_ESTADISTICAS = text("""
    SELECT
        nivel_3,
        ROUND((SUM(ST_Area(ST_Transform(geom, :srid_proy))) / 10000)::numeric, 4) AS area_ha,
        ROUND((
            100 * SUM(ST_Area(ST_Transform(geom, :srid_proy)))
            / SUM(SUM(ST_Area(ST_Transform(geom, :srid_proy)))) OVER ()
        )::numeric, 2) AS porcentaje
    FROM coberturas
    GROUP BY nivel_3
    ORDER BY area_ha DESC;
""")


def obtener_estadisticas(db: Session) -> dict:
    """
    RF Modulo 3 (Estadisticas Consolidadas): area total por tipo de
    cobertura y su porcentaje respecto al area total, calculado
    directamente en el motor espacial con una window function --
    SUM(...) OVER() evita una segunda consulta para obtener el total.
    """
    filas = db.execute(_QUERY_ESTADISTICAS, {"srid_proy": SRID_PROYECTADO}).mappings().all()

    coberturas = [
        {"nivel_3": f["nivel_3"], "area_ha": float(f["area_ha"]), "porcentaje": float(f["porcentaje"])}
        for f in filas
    ]
    area_total = round(sum(c["area_ha"] for c in coberturas), 4)

    return {"area_total_ha": area_total, "coberturas": coberturas}