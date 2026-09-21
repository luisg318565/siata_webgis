from typing import Any
from pydantic import BaseModel, Field, model_validator


class GeometriaConsulta(BaseModel):
    """Geometria GeoJSON de area de interes (Polygon o MultiPolygon), en EPSG:4326."""
    type: str
    coordinates: list


class ConsultaInterseccion(BaseModel):
    """
    Acepta EXACTAMENTE una de dos estrategias de consulta espacial,
    tal como pide el enunciado: geometria de area de interes, o
    coordenadas de punto con distancia de influencia.
    los rangos de coordenadas corresponden al extend de la capa limite Medellín
    con un buffer de 150 metros
    """
    geometria: GeometriaConsulta | None = None
    lat: float | None = Field(default=None, ge=6.161096, le=6.376680)
    lon: float | None = Field(default=None, ge=-75.721120, le=-75.470044)
    radio_m: float | None = Field(default=None, gt=0, le=50000)

    @model_validator(mode="after")
    def validar_una_sola_estrategia(self):
        tiene_geometria = self.geometria is not None
        tiene_punto = self.lat is not None and self.lon is not None and self.radio_m is not None

        if tiene_geometria and tiene_punto:
            raise ValueError(
                "Envie 'geometria' O 'lat/lon/radio_m', no ambas estrategias a la vez."
            )
        if not tiene_geometria and not tiene_punto:
            raise ValueError(
                "Debe enviar 'geometria' (GeoJSON) o las tres propiedades 'lat', 'lon' y 'radio_m'."
            )
        return self


class CoberturaInterceptada(BaseModel):
    id: int
    codigo: int | None
    leyenda: str | None
    nivel_3: str | None
    area_ha: float
    geometry: dict[str, Any]


class InterseccionResponse(BaseModel):
    type: str = "FeatureCollection"
    area_total_ha: float
    cantidad_coberturas: int
    features: list[dict[str, Any]]


class EstadisticaCobertura(BaseModel):
    nivel_3: str | None
    area_ha: float
    porcentaje: float


class EstadisticasResponse(BaseModel):
    area_total_ha: float
    coberturas: list[EstadisticaCobertura]