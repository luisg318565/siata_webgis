-- =====================================================================
-- 04. Indexacion espacial y de atributos
-- =====================================================================

-- ---------------------------------------------------------------------
-- Indice espacial GIST: indispensable para las consultas de interseccion
-- y vecindad (ST_Intersects, ST_DWithin). Sin el, cada consulta espacial
-- requeriria evaluar la geometria de las 450 filas una por una.
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_coberturas_geom
    ON coberturas USING GIST (geom);

-- Indice sobre nivel_3: campo usado para agrupar en las estadisticas
-- consolidadas y para la simbologia de la capa publicada en GeoServer.
CREATE INDEX IF NOT EXISTS idx_coberturas_nivel_3
    ON coberturas (nivel_3);

-- Recoleccion de estadisticas para que el planificador de consultas
-- disponga de informacion actualizada desde el primer arranque.
ANALYZE coberturas;