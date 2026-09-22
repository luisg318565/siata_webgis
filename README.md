# SIATA — Solución Geoespacial Integral de Coberturas CLC

Prueba técnica **Ingeniero(a) Geoespacial / Desarrollador FullStack GIS** — Contrato 247 de 2026, Sistema de Alerta Temprana de Medellín y el Valle de Aburrá (SIATA).

Solución orquestada en contenedores que integra una base de datos espacial (**PostGIS**), un microservicio de análisis y geoprocesamiento (**FastAPI**), la publicación automatizada de servicios OGC (**GeoServer — WMS/WFS**) y un **geovisor web ligero** (**Leaflet**) para verificar visualmente el despliegue y las operaciones espaciales.

**Insumo:** Mapa de Coberturas de la Tierra, Metodología CORINE Land Cover adaptada para Colombia, escala 1:100.000, periodo 2018 (IDEAM). Recorte representativo: **municipio de Medellín, 450 polígonos, 23 clases de nivel 3**.

---

## Tabla de contenido

1. [Despliegue en un solo paso](#1-despliegue-en-un-solo-paso)
2. [Despliegue en la nube (AWS)](#2-despliegue-en-la-nube-aws)
3. [URLs del entorno local](#3-urls-del-entorno-local)
4. [Arquitectura](#4-arquitectura)
5. [Tecnologías utilizadas](#5-tecnologías-utilizadas)
6. [Estructura del repositorio](#6-estructura-del-repositorio)
7. [Base de datos espacial](#7-base-de-datos-espacial)
8. [Endpoints del backend y parámetros de prueba](#8-endpoints-del-backend-y-parámetros-de-prueba)
9. [Servicios OGC (GeoServer)](#9-servicios-ogc-geoserver)
10. [Geovisor web](#10-geovisor-web)
11. [Decisiones técnicas y justificación](#11-decisiones-técnicas-y-justificación)
12. [Limitaciones conocidas](#12-limitaciones-conocidas)
13. [Solución de problemas](#13-solución-de-problemas)
14. [Declaración obligatoria de uso de asistentes de IA](#14-declaración-obligatoria-de-uso-de-asistentes-de-inteligencia-artificial)

---

## 1. Despliegue en un solo paso

### Requisitos previos

- Docker Desktop (o Docker Engine + Docker Compose v2)
- Git
- Puertos libres en el host: `80`, `8000`, `8080`, `5433`

### Despliegue

```bash
git clone https://github.com/luisg318565/siata_webgis.git
cd siata_webgis
cp .env.example .env          # En Windows PowerShell: Copy-Item .env.example .env
docker compose up -d --build
```

Eso es todo. El levantamiento es **íntegro y desatendido**: no requiere ningún paso manual adicional. La primera ejecución puede tardar varios minutos mientras se descargan las imágenes (GeoServer es la más pesada).

### Qué ocurre automáticamente, en orden

| # | Servicio | Acción | Condición de arranque |
|---|---|---|---|
| 1 | `db` | Inicia PostgreSQL + PostGIS, crea extensiones, inserta el SRID 9377, crea esquema e índices | — |
| 2 | `loader` | Carga el Shapefile CLC con GDAL/OGR, reproyecta a EPSG:4326 y termina | `db` saludable |
| 3 | `geoserver` | Inicia GeoServer | `db` saludable |
| 4 | `geoserver-init` | Crea workspace, datastore PostGIS, publica la capa y aplica la simbología SLD vía REST API, y termina | `geoserver` saludable **y** `loader` completado |
| 5 | `backend` | Inicia el microservicio FastAPI | `db` saludable, `loader` y `geoserver-init` completados |
| 6 | `frontend` | Sirve el geovisor con Nginx | `backend` iniciado |

### Verificación rápida

```bash
docker compose ps
```

Deben aparecer `siata_postgis`, `siata_geoserver`, `siata_backend` y `siata_frontend` en estado `Up`, y los servicios efímeros `siata_loader` y `siata_geoserver_init` en estado `Exited (0)`.

### Reinicio limpio (desde cero)

```bash
docker compose down -v      # -v elimina los volúmenes: base de datos y configuración de GeoServer
docker compose up -d --build
```

---

## 2. Despliegue en la nube (AWS)

### URL de la aplicación desplegada

**Geovisor en producción:** [http://44.222.114.10/](http://44.222.114.10/)
**Backend — documentación:** [http://44.222.114.10:8000/docs](http://44.222.114.10:8000/docs)
**GeoServer — administración:** [http://44.222.114.10:8080/geoserver/web/](http://44.222.114.10:8080/geoserver/web/)

> **Nota:** la URL usa HTTP (no HTTPS) y expone directamente los puertos de cada servicio, sin dominio propio ni proxy inverso — una simplificación consciente y documentada en la sección [Limitaciones conocidas](#12-limitaciones-conocidas), apropiada para el alcance de esta prueba técnica.

### Proveedor y arquitectura de despliegue

**Proveedor:** AWS (Amazon Web Services), región `us-east-1`. Una única instancia EC2 (`t3.small`, 2 GB RAM, 20 GB de disco, Ubuntu 22.04) ejecuta el mismo `docker-compose.yml` usado en desarrollo local — los 6 servicios (`db`, `loader`, `geoserver`, `geoserver-init`, `backend`, `frontend`) corren dentro de la misma instancia, comunicándose por la red interna de Docker. No se usan servicios gestionados (RDS, ECS) para mantener el despliegue simple y dentro de los créditos gratuitos de una cuenta nueva de AWS.

Se eligió `t3.small` en lugar de `t3.micro` porque GeoServer (Java/Tomcat) requiere más memoria de la que ofrece la instancia más pequeña; con 1 GB de RAM el arranque de GeoServer es propenso a fallar.

```
                          ┌───────────────────────────────────────────┐
                          │        AWS EC2 (t3.small, us-east-1)       │
                          │                                             │
   Internet  :80  ────────┼──▶  frontend (Nginx)  ──▶  backend (FastAPI) │
             :8000 ───────┼──▶  backend (FastAPI)  ──▶       │           │
             :8080 ───────┼──▶  geoserver ──────────────────┼──▶  db     │
                          │                    Docker Compose network   │
                          └───────────────────────────────────────────┘
```

### Infraestructura como Código (Terraform)

Ubicada en `infra/`. Provisiona exactamente 2 recursos:

- `aws_instance.siata_server`: la instancia EC2, con un script `user_data` que instala Docker, clona este repositorio y ejecuta `docker compose up -d --build` automáticamente al arrancar — el mismo levantamiento desatendido que en local, sin pasos manuales adicionales (a diferencia de otros despliegues, este stack no requiere ninguna migración o seed posterior: la carga de datos y la publicación OGC ya están automatizadas dentro del propio `docker compose up`).
- `aws_security_group.siata_sg`: reglas de firewall que permiten tráfico entrante en los puertos 22 (SSH), 80 (geovisor), 8000 (backend) y 8080 (GeoServer).

**Para desplegar desde cero:**

```bash
cd infra
terraform init
terraform plan
terraform apply
```

Requiere: AWS CLI configurado (`aws configure`) con un usuario IAM de permisos acotados (no la cuenta raíz), un Key Pair de EC2 ya creado, y un archivo `infra/terraform.tfvars` (no versionado, ver `.gitignore`) con:

```hcl
key_pair_name            = "nombre-de-tu-key-pair"
geoserver_admin_password = "tu_contraseña_geoserver"
postgres_password        = "tu_contraseña_postgres"
```

**Para destruir toda la infraestructura y detener cualquier cobro:**

```bash
cd infra
terraform destroy
```

### Decisiones y limitaciones del despliegue (documentadas, no accidentales)

- **Una sola instancia, sin alta disponibilidad ni balanceo de carga.** Apropiado para el alcance de una prueba técnica; en un entorno productivo se separaría la base de datos a un servicio gestionado (RDS con PostGIS) y GeoServer/backend correrían en instancias independientes, escalables por separado.
- **Sin HTTPS.** Requeriría un dominio propio y un proxy inverso (Nginx/Caddy) con certificado, o un Load Balancer de AWS con ACM — fuera del alcance de tiempo de esta prueba.
- **Contraseñas pasadas por `user_data`.** AWS almacena su contenido en texto plano, accesible por cualquiera con permisos de lectura sobre la instancia dentro de la cuenta; en producción se usaría AWS Secrets Manager o Parameter Store.
- **Puertos de administración expuestos públicamente** (GeoServer, backend) para facilitar la revisión de la prueba; en producción solo el puerto 80 (o 443) debería ser público, con los demás accesibles únicamente desde la red interna.
- **Costo:** con los créditos de bienvenida de una cuenta AWS nueva (hasta $200 USD), el costo de esta infraestructura durante el período de evaluación es efectivamente $0. Fuera de esos créditos, una instancia `t3.small` cuesta aproximadamente $15 USD/mes.

---

## 3. URLs del entorno local

| Componente | URL |
|---|---|
| **Geovisor web** | http://localhost/ |
| Backend — documentación interactiva (Swagger) | http://localhost:8000/docs |
| Backend — healthcheck | http://localhost:8000/health |
| GeoServer — administración | http://localhost:8080/geoserver/web/ |
| WMS — GetCapabilities | http://localhost:8080/geoserver/siata/wms?service=WMS&version=1.1.0&request=GetCapabilities |
| WFS — GetCapabilities | http://localhost:8080/geoserver/siata/wfs?service=WFS&version=2.0.0&request=GetCapabilities |
| PostGIS (cliente externo, p. ej. pgAdmin/QGIS) | `localhost:5433` |

Las credenciales de GeoServer y PostgreSQL son las definidas en el archivo `.env`.

---

## 4. Arquitectura

```
                               ┌──────────────────────────────┐
                               │        Navegador web         │
                               │   Geovisor Leaflet (HTML/JS) │
                               └───────┬──────────────┬───────┘
                           WMS (tiles) │              │ REST/JSON (GeoJSON)
                                       ▼              ▼
 ┌──────────────┐        ┌──────────────────┐   ┌──────────────────┐
 │   frontend   │        │    geoserver     │   │     backend      │
 │ Nginx :80    │        │ GeoServer :8080  │   │  FastAPI :8000   │
 │ (estáticos)  │        │ WMS / WFS / SLD  │   │ SQL espacial     │
 └──────────────┘        └────────┬─────────┘   └────────┬─────────┘
                                  │ JDBC                  │ psycopg3
                                  ▼                       ▼
                        ┌──────────────────────────────────────────┐
                        │                   db                     │
                        │     PostgreSQL 16 + PostGIS 3.4 :5432    │
                        │  tabla coberturas · índice GIST · 9377   │
                        └──────────────────────────────────────────┘
                                  ▲                       ▲
                    ogr2ogr (una  │                       │ REST API (una vez)
                    sola vez)     │                       │
                        ┌─────────┴────────┐   ┌──────────┴───────────┐
                        │      loader      │   │    geoserver-init    │
                        │  GDAL/OGR (ETL)  │   │ publicación OGC+SLD  │
                        │  efímero         │   │  efímero             │
                        └──────────────────┘   └──────────────────────┘

             Todos los servicios comparten la red interna aislada `siata_net`.
             Volúmenes persistentes: `pgdata` (base de datos) y `geoserver_data`.
```

### Principios de diseño

- **Separación de responsabilidades.** La base de datos solo define su esquema; la carga de datos (ETL) y la publicación OGC viven en servicios efímeros dedicados que se ejecutan una vez y terminan.
- **El motor espacial hace el trabajo espacial.** Intersecciones, buffers, reproyecciones, áreas y agregaciones se resuelven en SQL dentro de PostGIS. El backend orquesta la petición HTTP y entrega el GeoJSON que PostGIS ya produjo con `ST_AsGeoJSON`, sin cargar geometrías en memoria de Python.
- **Arranque determinista.** Las dependencias entre servicios se declaran con `healthcheck` y `service_completed_successfully`, de modo que ningún servicio arranca antes de que sus dependencias estén realmente listas.
- **Idempotencia.** Tanto la carga de datos como la publicación en GeoServer verifican el estado actual antes de actuar; reiniciar el stack no duplica registros ni recursos.

---

## 5. Tecnologías utilizadas

| Capa | Tecnología | Versión | Uso |
|---|---|---|---|
| Orquestación | Docker Compose | v2 | Levantamiento multi-contenedor, red y volúmenes |
| Base de datos | PostgreSQL + PostGIS | 16 / 3.4 | Almacenamiento y análisis espacial |
| ETL | GDAL/OGR (`ogr2ogr`) | imagen `osgeo/gdal:alpine-small` | Carga del Shapefile y reproyección |
| Backend | Python + FastAPI | 3.13 / 0.115 | Microservicio de consulta espacial |
| Acceso a datos | SQLAlchemy + psycopg 3 | 2.0 / 3.2 | Pool de conexiones y ejecución de SQL |
| Validación | Pydantic | 2.9 | Validación de parámetros de entrada |
| Servicios OGC | GeoServer | 2.25.2 | Publicación WMS / WFS y simbología SLD |
| Automatización OGC | GeoServer REST API + `curl` | — | Publicación desatendida |
| Frontend | Leaflet | 1.9.4 | Geovisor web |
| Servidor web | Nginx | alpine | Servir el geovisor estático |

---

## 6. Estructura del repositorio

```
siata_webgis/
├── docker-compose.yml          # Orquestación de los 6 servicios
├── .env.example                # Plantilla de variables de entorno
├── data/
│   └── clc_clip_med.*          # Recorte CLC de Medellín (Shapefile, EPSG:4686)
├── db/
│   └── init/                   # Ejecutados automáticamente por PostGIS al primer arranque
│       ├── 01_extensiones_srid.sql   # PostGIS + inserción de EPSG:9377
│       ├── 02_esquema.sql            # Tabla coberturas con SRID explícito
│       └── 03_indices.sql            # Índice GIST espacial + índice sobre nivel_3
├── loader/
│   └── load.sh                 # ETL Shapefile -> PostGIS con ogr2ogr (idempotente)
├── geoserver-init/
│   ├── Dockerfile
│   ├── publicar.sh             # Workspace, datastore, capa y estilo vía REST API
│   └── coberturas.sld          # Simbología oficial IDEAM (23 clases)
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── main.py             # Rutas HTTP
│       ├── core/config.py      # Configuración por variables de entorno
│       ├── db/session.py       # Engine y sesión de base de datos
│       ├── schemas/consulta.py # Modelos Pydantic de entrada y salida
│       └── services/analisis_service.py  # Lógica espacial (SQL/PostGIS)
└── frontend/
    └── index.html              # Geovisor Leaflet
```

---

## 7. Base de datos espacial

### Tabla `coberturas`

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | `SERIAL PRIMARY KEY` | Identificador |
| `codigo` | `INTEGER` | Código CLC del nivel más detallado disponible en la fuente |
| `leyenda` | `VARCHAR(70)` | Descripción de la cobertura |
| `nivel_1` … `nivel_6` | `VARCHAR(70)` | Jerarquía CLC |
| `confiabilidad` | `VARCHAR(12)` | Confiabilidad reportada por el IDEAM |
| `geom` | `geometry(MultiPolygon, 4326)` | Geometría con tipo y SRID explícitos |

### Índices

- `idx_coberturas_geom` — **GIST** sobre `geom`: soporta `ST_Intersects` y demás consultas de vecindad y corte.
- `idx_coberturas_nivel_3` — B-tree sobre `nivel_3`: soporta la agregación de estadísticas y los filtros de la simbología.

### Sistemas de referencia

| SRID | Nombre | Uso en el proyecto |
|---|---|---|
| 4686 | MAGNA-SIRGAS | CRS de la fuente IDEAM (entrada) |
| 4326 | WGS84 | CRS de almacenamiento y de intercambio (GeoJSON, WMS, Leaflet) |
| 9377 | MAGNA-SIRGAS 2018 / Origen-Nacional (CTM12) | CRS proyectado para cálculos métricos: áreas en hectáreas y buffers en metros |

---

## 8. Endpoints del backend y parámetros de prueba

Documentación interactiva completa en **http://localhost:8000/docs**.

### `GET /health` — Salud del servicio

Verifica el estado del backend y la conectividad activa con PostGIS. Responde `503` si la base de datos no está disponible.

```bash
curl http://localhost:8000/health
```

```json
{ "status": "ok", "database": "connected", "coberturas_cargadas": 450 }
```

### `POST /analisis/interseccion` — Intersección y cálculo de área

Identifica las coberturas interceptadas por un área de interés y calcula el **área real de intersección** en hectáreas (no el área total de cada polígono). Acepta **exactamente una** de dos estrategias:

| Estrategia | Campos | Restricciones |
|---|---|---|
| Punto + radio de influencia | `lat`, `lon`, `radio_m` | `lat` ∈ [-4.2, 12.5], `lon` ∈ [-81.0, -66.8], `0 < radio_m ≤ 50000` |
| Geometría de área de interés | `geometria` (GeoJSON `Polygon` o `MultiPolygon`, EPSG:4326) | — |

Enviar ambas estrategias, o ninguna, produce un error de validación `422` con un mensaje descriptivo.

**Ejemplo 1 — punto con radio (centro de Medellín, 1 km):**

```bash
curl -X POST http://localhost:8000/analisis/interseccion \
  -H "Content-Type: application/json" \
  -d '{"lat": 6.244, "lon": -75.581, "radio_m": 1000}'
```

**Ejemplo 2 — rectángulo como área de interés:**

```bash
curl -X POST http://localhost:8000/analisis/interseccion \
  -H "Content-Type: application/json" \
  -d '{"geometria": {"type": "Polygon", "coordinates": [[[-75.60,6.23],[-75.56,6.23],[-75.56,6.26],[-75.60,6.26],[-75.60,6.23]]]}}'
```

**Equivalente en Windows PowerShell:**

```powershell
$body = @{ lat = 6.244; lon = -75.581; radio_m = 1000 } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:8000/analisis/interseccion" -Method POST -ContentType "application/json" -Body $body
```

**Estructura de la respuesta** (GeoJSON `FeatureCollection` enriquecido):

```json
{
  "type": "FeatureCollection",
  "area_total_ha": 312.14,
  "cantidad_coberturas": 8,
  "resumen_por_clase": [
    { "nivel_3": "1.1.2. Tejido urbano discontinuo", "area_ha": 111.56 },
    { "nivel_3": "1.1.1. Tejido urbano continuo",    "area_ha": 81.25 }
  ],
  "features": [
    {
      "type": "Feature",
      "geometry": { "type": "Polygon", "coordinates": [ ... ] },
      "properties": {
        "id": 14, "codigo": 112, "leyenda": "1.1.2. Tejido urbano discontinuo",
        "nivel_3": "1.1.2. Tejido urbano discontinuo", "area_ha": 57.31
      }
    }
  ]
}
```

- `features` contiene **cada polígono** interceptado, recortado a la zona de solape, con su área.
- `resumen_por_clase` agrega el área por **clase** `nivel_3`: dos polígonos separados de la misma clase suman en una sola entrada.
- `cantidad_coberturas` es el número de **clases distintas**, no de polígonos.

### `GET /analisis/estadisticas` — Estadísticas consolidadas

Resumen de toda el área de estudio: área total por tipo de cobertura y su porcentaje respecto al total, calculado directamente en el motor espacial.

```bash
curl http://localhost:8000/analisis/estadisticas
```

```json
{
  "area_total_ha": 39825.26,
  "coberturas": [
    { "nivel_3": "1.1.1. Tejido urbano continuo", "area_ha": 9609.24, "porcentaje": 24.13 },
    { "nivel_3": "3.2.3. Vegetación secundaria o en transición", "area_ha": 6210.83, "porcentaje": 15.6 }
  ]
}
```

---

## 9. Servicios OGC (GeoServer)

La capa `siata:coberturas` se publica automáticamente al levantar el entorno.

| Recurso | Valor |
|---|---|
| Workspace | `siata` |
| Datastore | `postgis_coberturas` (PostGIS, conexión por la red interna) |
| Capa | `siata:coberturas` |
| Estilo por defecto | `coberturas_clc` (SLD, 23 clases) |
| SRS | EPSG:4326 |

### Consultas de ejemplo

**WMS — imagen renderizada con la simbología oficial:**

```
http://localhost:8080/geoserver/siata/wms?service=WMS&version=1.1.0&request=GetMap&layers=siata:coberturas&bbox=-75.72,6.16,-75.47,6.38&width=600&height=600&srs=EPSG:4326&format=image/png
```

**WMS — leyenda:**

```
http://localhost:8080/geoserver/siata/wms?service=WMS&request=GetLegendGraphic&layer=siata:coberturas&format=image/png
```

**WFS — entidades en GeoJSON (primeras 5):**

```
http://localhost:8080/geoserver/siata/wfs?service=WFS&version=2.0.0&request=GetFeature&typeNames=siata:coberturas&count=5&outputFormat=application/json
```

### Simbología

El estilo categoriza por el campo `nivel_3`, igual que la capa oficial del IDEAM. Los 23 colores corresponden a los valores hexadecimales **oficiales** de la *Ficha de Representación Gráfica* del IDEAM (`FRS_e_cobertura_tierra_clc_2018.xlsm`), no a una paleta aproximada.

---

## 10. Geovisor web

Disponible en **http://localhost/**.

| Funcionalidad | Descripción |
|---|---|
| Capa temática | Coberturas CLC consumidas desde GeoServer vía **WMS**, con la simbología oficial |
| Mapas base | Selector con Calles (OSM), Claro (CARTO), Oscuro (CARTO) y Satelital (Esri) |
| Opacidad | Control deslizante para la transparencia de la capa de coberturas |
| Consulta por punto | Clic en el mapa → consulta de intersección con el radio configurado |
| Consulta por rectángulo | Botón *Dibujar rectángulo* → dos clics (esquinas opuestas) |
| Resultado | Coberturas interceptadas dibujadas en el mapa (con *popup* por polígono) y panel con área total, número de clases y área por clase |
| Resumen general | Estadísticas consolidadas de toda la capa, cargadas al abrir la página, en una sección independiente y colapsable |
| Leyenda | Generada por GeoServer (`GetLegendGraphic`) |

El geovisor construye las URLs del backend y de GeoServer a partir del host desde el que se sirve (`window.location.hostname`), de modo que el mismo archivo funciona sin cambios en local y en un despliegue remoto.

---

## 11. Decisiones técnicas y justificación

### Base de datos

- **Almacenamiento en EPSG:4326, cálculos en EPSG:9377.** La fuente viene en EPSG:4686 (MAGNA-SIRGAS); se reproyecta a 4326 durante la carga porque es el CRS esperado por GeoJSON, Leaflet y WMS. Las áreas y los buffers se calculan transformando al vuelo a **EPSG:9377**, el sistema proyectado oficial de Colombia (IGAC, origen único nacional), porque `ST_Area` sobre coordenadas geográficas devuelve grados cuadrados, sin significado físico.
- **Inserción explícita de EPSG:9377.** Esta definición no viene precargada en todas las distribuciones de PostGIS (depende de la versión de PROJ empaquetada). Se inserta en `01_extensiones_srid.sql` con una cláusula `WHERE NOT EXISTS`, garantizando reproducibilidad en cualquier entorno.
- **Atributos descartados.** Se omiten los campos de procesamiento del IDEAM (`insumo`, `apoyo`, `cambio`) y los campos `Shape_Length` / `Shape_Area` calculados por ArcGIS, cuyos valores están expresados en grados y no sirven para el cálculo en hectáreas.
- **`nivel_3` y no `codigo` como campo temático.** El campo `codigo` contiene el código del nivel más detallado disponible por polígono (niveles 4, 5 o 6 en algunos casos: `3231`, `31111`, `321113`), por lo que un mismo tipo de nivel 3 aparece con varios códigos. `nivel_3` es consistente: 25 valores de `codigo` corresponden a 23 clases reales de nivel 3.

### Carga de datos

- **Servicio `loader` dedicado con GDAL/OGR.** Se verificó que la imagen `postgis/postgis` incluye `psql` pero **no** `ogr2ogr` ni `shp2pgsql`. En lugar de instalar herramientas dentro del contenedor de la base de datos, la carga se delegó a un contenedor efímero con la imagen oficial de GDAL, cuyo driver PostgreSQL es de lectura/escritura. Esto separa responsabilidades y usa la herramienta estándar de la industria para la tarea.
- **`ogr2ogr -append` sobre el esquema declarado.** La tabla la crea el script SQL (con tipos y SRID explícitos); `ogr2ogr` solo inserta, con `-sql` para seleccionar y renombrar atributos y `-t_srs` para reproyectar.

### Backend

- **Backend sin dependencias geoespaciales de Python.** El servicio es de solo consulta; toda la lógica espacial vive en SQL. Esto produce una imagen más liviana y concentra la complejidad espacial en el componente optimizado para ella.
- **`ST_Intersection` y no solo `ST_Intersects`.** `ST_Intersects` solo responde si dos geometrías se tocan; el área afectada exige la geometría de solape real, que se obtiene con `ST_Intersection`.
- **Buffer calculado en EPSG:9377.** El radio se aplica sobre la geometría proyectada, para que la distancia esté efectivamente en metros, y el resultado se devuelve a 4326.
- **Window function para porcentajes.** `SUM(...) OVER ()` calcula el total general en la misma consulta de agregación, sin una segunda consulta.
- **Validación en la capa Pydantic.** La regla "exactamente una estrategia de consulta" y los límites de coordenadas se validan antes de tocar la base de datos, con errores `422` descriptivos.
- **Resumen agregado por clase.** La respuesta de intersección incluye tanto los polígonos individuales (necesarios para dibujar la geometría) como el resumen por clase (necesario para reportar tipos de cobertura sin duplicados).

### GeoServer

- **Automatización por REST API.** Se prefirió a un *datadir* preconfigurado porque cada paso es explícito y legible, no depende de la estructura interna de una versión específica de GeoServer y es verificable de forma aislada.
- **Espera activa sobre la API REST.** Además del `healthcheck` del contenedor (que confirma que Tomcat responde), el script espera a que el endpoint REST esté disponible antes de crear recursos.
- **Idempotencia.** Cada recurso se consulta antes de crearse; el estilo se actualiza con `PUT` si ya existe.

### Geovisor

- **HTML estático y Leaflet, sin paso de *build*.** El enunciado pide un visor ligero; un framework con compilación sería desproporcionado para el alcance.
- **Capa temática por WMS, resultados por GeoJSON.** La capa completa se consume desde GeoServer (demuestra el servicio OGC y trae la simbología resuelta en servidor); el resultado de la consulta es dinámico y se dibuja desde la respuesta GeoJSON del backend.
- **Consulta y resumen general en secciones separadas.** El resultado de la consulta interactiva y las estadísticas globales son informaciones de naturaleza distinta; ocupan contenedores independientes para que una no reemplace a la otra.

---

## 12. Limitaciones conocidas

Aspectos identificados conscientemente y fuera del alcance de la prueba:

- **Credenciales de desarrollo.** El usuario de PostgreSQL definido en `POSTGRES_USER` tiene privilegios completos sobre la base; GeoServer también se conecta con él. En producción se usarían roles separados con privilegios mínimos (solo `SELECT` para GeoServer y el backend) y un gestor de secretos.
- **CORS abierto.** El backend permite cualquier origen (`allow_origins=["*"]`), apropiado para la evaluación local; en producción debe restringirse al dominio del geovisor.
- **Sin HTTPS ni proxy inverso.** Los servicios se exponen directamente en sus puertos. Un despliegue productivo ubicaría Nginx como proxy inverso único con TLS.
- **Puertos de administración expuestos.** GeoServer (`8080`) y PostGIS (`5433`) se publican en el host para facilitar la revisión; en producción no se expondrían públicamente.
- **Consultas sin límite de tamaño de área.** Un área de interés muy grande procesa todo el recorte; con 450 polígonos no es un problema, pero con datos a escala nacional convendría acotar el área o paginar resultados.

---

## 13. Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| `port is already allocated` en `5433` | Otra instancia de PostgreSQL en el host | Cambiar el puerto publicado del servicio `db` en `docker-compose.yml` |
| `siata_backend` no arranca | `loader` o `geoserver-init` no terminaron correctamente | `docker compose logs loader` y `docker compose logs geoserver-init` |
| El mapa no muestra la capa de coberturas | GeoServer aún inicializando o publicación fallida | Esperar 1–2 min; revisar `docker compose logs geoserver-init` |
| `lookup registry-1.docker.io: no such host` durante el *build* | Resolución DNS del motor de *build* de Docker (BuildKit) en Windows | Reintentar; construir con `docker compose build --pull=false` para usar las imágenes base ya descargadas; configurar DNS `8.8.8.8` en *Docker Desktop → Settings → Docker Engine* |
| Tildes mostradas como `Ã³` en PowerShell | La consola de Windows usa la página de códigos IBM850, no UTF-8. Los datos y la API están correctos | `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` |
| Cambios de datos no se reflejan tras reiniciar | Los scripts de inicialización solo corren con un volumen nuevo | `docker compose down -v` y volver a levantar |

---

## 14. Declaración obligatoria de uso de asistentes de Inteligencia Artificial

### 1. Herramientas utilizadas durante el desarrollo

- [ ] Asistentes integrados al editor (Copilot, Cursor, Codeium, etc.)
- [x] Modelos de chat generativo (ChatGPT, Claude, Gemini, etc.) — **Claude (Anthropic)**
- [ ] Ninguna herramienta de IA fue utilizada.

### 2. Naturaleza del apoyo recibido

- [x] Estructuración de plantillas base (scaffolding de Docker, compose o boilerplate de API / frontend)
- [x] Asistencia en sintaxis de consultas espaciales, visor web o configuración de GeoServer
- [x] Depuración de errores de configuración o dependencias
- [x] Redacción de documentación y pruebas

### 3. Validación crítica del desarrollador

Aspectos sugeridos o producidos con asistencia de IA que requirieron verificación, corrección o adaptación:

- **Herramienta de carga de datos.** La primera propuesta asumió que `shp2pgsql` venía incluido en la imagen `postgis/postgis`; la carga falló con `command not found`. Se verificó qué binarios contenía cada imagen (`psql` sí; `ogr2ogr` y `shp2pgsql` no) y se rediseñó la carga como un servicio `loader` independiente con la imagen oficial de GDAL, previa confirmación de que su driver PostgreSQL es de lectura/escritura.
- **CRS de la fuente.** Se asumía inicialmente que el insumo estaba en EPSG:4326. La inspección con `ogrinfo` mostró EPSG:4686 (MAGNA-SIRGAS), lo que obligó a declarar la reproyección explícita durante la carga.
- **Campo temático.** La inspección de los datos mostró que `codigo` mezcla niveles 3 a 6 de la jerarquía (25 códigos para 23 clases); se adoptó `nivel_3` como campo de agrupación y de simbología, coherente con la capa oficial.
- **Conteo de tipos de cobertura.** La primera versión del endpoint de intersección reportaba como "tipos de cobertura" el número de polígonos interceptados, y el panel del geovisor listaba clases repetidas. Lo detecté al revisar resultados en el visor; se corrigió agregando el área por `nivel_3` y reportando clases distintas.
- **Simbología.** No fue posible decodificar los colores del archivo binario `.lyr` de ArcGIS. En lugar de usar una paleta genérica, los valores hexadecimales oficiales de las 23 clases se extrajeron de la *Ficha de Representación Gráfica* del IDEAM y se validó visualmente el resultado contra la leyenda oficial del mapa nacional.
- **Diagnóstico de codificación.** Las tildes aparecían corruptas en las respuestas vistas desde PowerShell. Antes de modificar el backend se verificó que PostgreSQL almacenaba los datos correctamente y que la causa era la página de códigos IBM850 de la consola, no la API.
- **Configuración de Docker Compose.** Se corrigieron errores de indentación YAML que anidaban un servicio dentro de otro, y un reemplazo parcial de código que eliminó la definición de la consulta de estadísticas (`NameError`), detectado mediante los logs del contenedor.
- **Disponibilidad de imágenes.** Ante fallos intermitentes de resolución DNS de BuildKit al descargar imágenes nuevas, el servicio `geoserver-init` se construyó sobre la imagen base de Python ya disponible localmente, en lugar de depender de una imagen adicional.
- **Experiencia de usuario del geovisor.** El diseño inicial usaba un único panel donde las estadísticas globales reemplazaban el resultado de la consulta del usuario. Se rediseñó en secciones independientes: la consulta interactiva arriba y el resumen general de la capa, cargado automáticamente, debajo.
- **Decisiones de alcance propias.** Selección del recorte de Medellín y preparación del insumo en ArcGIS; uso de EPSG:9377 como sistema métrico nacional; incorporación de mapas base seleccionables, control de opacidad y consulta por rectángulo como funcionalidades adicionales del visor.
