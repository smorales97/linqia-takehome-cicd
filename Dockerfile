FROM python:3.12-slim

WORKDIR /app

# Instalar dependencias mínimas (no hay requirements; instalamos el paquete local si aplica)
COPY . /app

# No hay dependencias externas; si existieran, agregarlas vía requirements.txt
# RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["python", "-m", "sample_app"]
