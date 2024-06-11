#!/bin/bash

# Creación de los directorios temporales
mkdir -p tempdir/templates
mkdir -p tempdir/static

# Verifica si myapp.py existe antes de copiarlo
if [ -f "myapp.py" ]; then
    cp myapp.py tempdir/
else
    echo "Error: myapp.py no encontrado."
    exit 1
fi

# Copia los archivos si los directorios existen y no están vacíos
if [ -d "templates" ] && [ "$(ls -A templates)" ]; then
    cp -r templates/* tempdir/templates/
else
    echo "Advertencia: El directorio 'templates' no existe o está vacío."
fi

if [ -d "static" ] && [ "$(ls -A static)" ]; then
    cp -r static/* tempdir/static/
else
    echo "Advertencia: El directorio 'static' no existe o está vacío."
fi

# Crear Dockerfile
cat <<EOL > tempdir/Dockerfile
FROM python
RUN pip3 install flask
COPY ./static /home/myapp/static/
COPY ./templates /home/myapp/templates/
COPY myapp.py /home/myapp/
EXPOSE 8080
CMD python3 /home/myapp/myapp.py
EOL

# Construir el contenedor Docker
cd tempdir
docker build -t myapp .

# Verificar si un contenedor con el nombre myapprunning ya está en ejecución y eliminarlo si es necesario
if [ "$(docker ps -a -q -f name=myapprunning)" ]; then
    docker rm -f myapprunning
fi

# Ejecutar el contenedor Docker
docker run -t -d -p 8080:8080 --name myapprunning myapp

# Verificar si el contenedor está corriendo
docker ps -a
