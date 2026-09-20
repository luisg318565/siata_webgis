-- =====================================================================
-- 01. Extensiones espaciales y sistema de referencia nacional
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS postgis;

-- ---------------------------------------------------------------------
-- EPSG:9377 - MAGNA-SIRGAS 2018 / Origen-Nacional (CTM12)
--
-- Sistema de referencia proyectado oficial de Colombia (IGAC), adoptado
-- como origen unico nacional. Se requiere para calcular areas en unidades
-- metricas (hectareas), ya que la capa se almacena en un CRS geografico
-- (grados), donde ST_Area no produce valores con significado fisico.
--
-- Nota tecnica: esta definicion no viene precargada en todas las
-- distribuciones de PostGIS (depende de la version de PROJ empaquetada),
-- por lo que se inserta explicitamente aqui para garantizar la
-- reproducibilidad del despliegue en cualquier entorno.
-- ---------------------------------------------------------------------
INSERT INTO spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text)
SELECT
    9377,
    'EPSG',
    9377,
    'PROJCS["MAGNA-SIRGAS 2018 / Origen-Nacional",GEOGCS["MAGNA-SIRGAS 2018",DATUM["Marco_Geocentrico_Nacional_de_Referencia_2018",SPHEROID["GRS 1980",6378137,298.257222101,AUTHORITY["EPSG","7019"]],AUTHORITY["EPSG","1150"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","20046"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",4],PARAMETER["central_meridian",-73],PARAMETER["scale_factor",0.9992],PARAMETER["false_easting",5000000],PARAMETER["false_northing",2000000],UNIT["metre",1,AUTHORITY["EPSG","9001"]],AXIS["Northing",NORTH],AXIS["Easting",EAST],AUTHORITY["EPSG","9377"]]',
    '+proj=tmerc +lat_0=4 +lon_0=-73 +k=0.9992 +x_0=5000000 +y_0=2000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs'
WHERE NOT EXISTS (SELECT 1 FROM spatial_ref_sys WHERE srid = 9377);