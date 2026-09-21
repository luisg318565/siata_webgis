from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings

# client_encoding=utf8 fuerza explicitamente la codificacion del cliente
# psycopg hacia PostgreSQL, evitando problemas de doble codificacion
# (mojibake) en cadenas con caracteres especiales del espanol.
engine = create_engine(
    settings.database_url,
    pool_pre_ping=True,
    connect_args={"client_encoding": "utf8"},
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()