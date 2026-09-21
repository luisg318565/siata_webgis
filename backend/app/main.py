from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.consulta import ConsultaInterseccion, InterseccionResponse, EstadisticasResponse
from app.services.analisis_service import (
    verificar_conexion_bd,
    consultar_interseccion,
    obtener_estadisticas,
)

app = FastAPI(
    title="SIATA - Backend de Analisis Geoespacial",
    description="Microservicio de consulta espacial sobre coberturas CLC (Valle de Aburra)",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", tags=["Sistema"])
def health(db: Session = Depends(get_db)):
    """Verifica el estado del backend y la conectividad con PostGIS."""
    try:
        return verificar_conexion_bd(db)
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Sin conexion a la base de datos: {e}")


@app.post("/analisis/interseccion", response_model=InterseccionResponse, tags=["Analisis"])
def interseccion(consulta: ConsultaInterseccion, db: Session = Depends(get_db)):
    """
    Recibe una geometria de area de interes, o un punto con radio de
    influencia. Identifica las coberturas interceptadas y calcula el
    area afectada en hectareas. Responde en GeoJSON estructurado.
    """
    geojson_dict = consulta.geometria.model_dump() if consulta.geometria else None
    resultado = consultar_interseccion(
        db, geojson_dict, consulta.lat, consulta.lon, consulta.radio_m
    )
    return resultado


@app.get("/analisis/estadisticas", response_model=EstadisticasResponse, tags=["Analisis"])
def estadisticas(db: Session = Depends(get_db)):
    """Resumen consolidado: area total por tipo de cobertura y su
    porcentaje respecto al area total del recorte de estudio."""
    return obtener_estadisticas(db)