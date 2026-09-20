-- =====================================================================
-- 02. Esquema de la capa tematica de coberturas de la tierra
-- =====================================================================

-- ---------------------------------------------------------------------
-- Tabla de coberturas (CORINE Land Cover adaptada para Colombia - IDEAM)
--
-- Decisiones de modelado:
--  * Geometria almacenada en EPSG:4326 (WGS84). La fuente original esta
--    en EPSG:4686 (MAGNA-SIRGAS); se reproyecta durante la carga porque
--    4326 es el CRS esperado por los estandares web (GeoJSON, Leaflet)
--    y simplifica la publicacion OGC.
--  * Tipo MULTIPOLYGON explicito con SRID, coherente con la geometria
--    de origen.
--  * Se conservan unicamente los atributos con valor para el caso de uso
--    (identificacion y jerarquia de la cobertura). Los campos de
--    procesamiento del IDEAM (insumo, apoyo, cambio) y los calculados por
--    ArcGIS (Shape_Length, Shape_Area, expresados en grados) se descartan.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS coberturas (
    id            SERIAL PRIMARY KEY,
    codigo        INTEGER,
    leyenda       VARCHAR(70),
    nivel_1       VARCHAR(70),
    nivel_2       VARCHAR(70),
    nivel_3       VARCHAR(70),
    nivel_4       VARCHAR(70),
    nivel_5       VARCHAR(70),
    nivel_6       VARCHAR(70),
    confiabilidad VARCHAR(12),
    geom          geometry(MultiPolygon, 4326) NOT NULL
);

COMMENT ON TABLE  coberturas IS 'Coberturas de la tierra CLC (IDEAM) - recorte Valle de Aburra';
COMMENT ON COLUMN coberturas.codigo  IS 'Codigo numerico de la cobertura CLC';
COMMENT ON COLUMN coberturas.leyenda IS 'Descripcion de la cobertura';
COMMENT ON COLUMN coberturas.nivel_3 IS 'Nivel 3 de la jerarquia CLC (usado para simbologia)';
COMMENT ON COLUMN coberturas.geom    IS 'Geometria MULTIPOLYGON en EPSG:4326';