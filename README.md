# Dockerizando una web estática con Nginx, publicándola en Docker Hub y desplegándola en AWS EC2

## Autor
- Nombre: Enmanuel Santos Diaz
- Matrícula: 25-1544
- Universidad: UNIBE
- Asignatura: TI3501-01-2026-1 — Tendencias en Desarrollo de Software (Electiva Prof.)
- GitHub: enmasdiaz1
- Docker Hub: enmasdiaz

## Repositorios y despliegue
- Repositorio: https://github.com/Enmasdiaz1/DockerizandoWebEstatica
- Imagen en Docker Hub: https://hub.docker.com/r/enmasdiaz/nginx-2048
  - Pull: `docker pull enmasdiaz/nginx-2048:1.0`
- Despliegue en EC2: http://18.221.43.134

## Resumen
Este documento detalla cómo:
- Dockericé la web estática 2048 con Nginx.
- Publiqué la imagen en Docker Hub manualmente y con CI/CD (GitHub Actions).
- Desplegué en Amazon EC2 usando Docker Compose (binario).

## Índice
1. Objetivo y alcance
2. Arquitectura y herramientas
3. Estructura del repositorio
4. Dockerfile y construcción local
5. Pruebas locales
6. Publicación en Docker Hub (manual)
7. Automatización con GitHub Actions (CI/CD)
8. Despliegue en AWS EC2 con Docker Compose
9. Evidencias (capturas)
10. Problemas y soluciones
11. Validaciones finales
12. .gitignore
13. Referencias

---

## 1) Objetivo y alcance
- Empaquetar la web 2048 en una imagen Docker con Nginx, distribuirla en Docker Hub y desplegarla en EC2.
- Incluir pipeline de GitHub Actions y troubleshooting.

## 2) Arquitectura y herramientas
- App: 2048 (estática) servida por Nginx.
- Base: Ubuntu + Nginx + Git.
- Registro: Docker Hub (enmasdiaz/nginx-2048).
- CI/CD: GitHub Actions.
- Infraestructura: AWS EC2 (Amazon Linux 2023, t2.micro).
- Orquestación: Docker y Docker Compose (binario).

## 3) Estructura del repositorio
- `Dockerfile`
- `.github/workflows/main.yml`
- `.gitignore`
- `README.md` (este documento)

## 4) Dockerfile y construcción local
Dockerfile:
```Dockerfile
FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y nginx git ca-certificates && \
    rm -rf /var/lib/apt/lists/*
RUN rm -rf /var/www/html/* && \
    git clone https://github.com/josejuansanchez/2048 /var/www/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```
## 5)Pruebas locales
- `docker run -d --name test-2048 -p 8080:80 tu_carpeta`
- `docker stop test-2048 && docker rm test-2048`

## 6) Publicación en Docker Hub (manual)
- Login y etiquetas:
```
  docker login
  docker tag nginx-2048 enmasdiaz/nginx-2048:1.0
  docker tag nginx-2048 enmasdiaz/nginx-2048:latest
```
- Push
```
  docker push enmasdiaz/nginx-2048:1.0
  docker push enmasdiaz/nginx-2048:latest
```

## 7) Automatización con GitHub Actions (CI/CD)
- Workflow .github/workflows/main.yml
```
  name: Build and Push Docker image

on:
  push:
    branches: ["main"]

permissions:
  contents: read
  packages: write
  id-token: write

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: |
            enmasdiaz/nginx-2048:latest
            enmasdiaz/nginx-2048:1.0
```
- Secrets:
  - DOCKERHUB_USERNAME = enmasdiaz
  - DOCKERHUB_TOKEN = Access Token de Docker Hub (write)
- Secrets:
  - Cada push a main construye y publica latest y 1.0.
    
## 8) Despliegue en AWS EC2 con Docker Compose
- Instancia:
  - Amazon Linux 2023, t2.micro.
  - SG: SSH 22 (IP cliente), HTTP 80 (0.0.0.0/0).
- SSH:
  `ssh -i "C:\ruta\docker-clase.pem" ec2-user_o_ubuntu@IPV4_PUBLICA`
- Instalar Docker:
  ```
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  docker-compose version
  ```
- docker-compose.yml:
   ```
  services:
    web:
      image: enmasdiaz/nginx-2048:latest
      ports:
        - "80:80"
      restart: unless-stopped
  ```
- Despliegue:
   ```
  mkdir -p ~/apps/nginx-2048 && cd ~/apps/nginx-2048
  # crear archivo docker-compose.yml
  docker-compose up -d
  ```
- Verificación: http://18.221.43.134

## 9) Evidencias (capturas)
Creación del proyecto y Dockerfile
- creando proyecto de prueba.png (Dockerfile en VS Code)
  <img width="1680" height="1031" alt="creando proyecto de prueba" src="https://github.com/user-attachments/assets/f34fb541-8581-469c-89c2-e525be4873b3" />
Build, tag y push de la imagen (incluye troubleshooting)
- configurando docker.png (build, tag, push y resolución de permisos)
  <img width="1693" height="1315" alt="configurando docker" src="https://github.com/user-attachments/assets/7aaab138-d130-42b9-8adb-758ce86593b2" />
Prueba local de la imagen
- proyecto corriendo en docker.png (Docker Desktop con contenedor 8080:80)
  <img width="1712" height="1397" alt="proyecto corriendo en docker" src="https://github.com/user-attachments/assets/496f14ed-7ad8-4973-bae3-e77a4f96c741" />
- Proyecto de prueba corriendo localhost.png (app local)
  <img width="1388" height="1216" alt="Proyecto de prueba corriendo localhost" src="https://github.com/user-attachments/assets/ddb5bc4d-cbde-47a3-88ca-b7f1abf7d8af" />
Automatización CI/CD en GitHub Actions
- github pipeline corriendo.png (workflow en progreso)
  <img width="1709" height="934" alt="github pipeline corriendo" src="https://github.com/user-attachments/assets/81aa10a6-2a17-4ee0-9523-943f7165aa35" />
- action ejecutado satisfactoriamente.png (pipeline “Success”)
  <img width="1710" height="1263" alt="action ejecutado satisfactoriamente" src="https://github.com/user-attachments/assets/1a6abf1a-392b-4b69-999e-142c96b3907e" />
Preparación de la infraestructura en AWS
- Aws.png (instancia EC2 e IP pública 18.221.43.134)
  <img width="1697" height="1336" alt="Aws" src="https://github.com/user-attachments/assets/80aa3940-65e2-4936-bcfc-6e6d833839fe" />
- conexion ssh.png (SSH y setup Docker)
  <img width="1686" height="1046" alt="conexion ssh" src="https://github.com/user-attachments/assets/eaef4aa2-b628-4918-bb15-65bc8462da26" />
Despliegue en EC2 con Docker Compose y verificación final
- publicacion docker.png (docker-compose up -d en EC2)
  <img width="1551" height="1144" alt="publicacion docker" src="https://github.com/user-attachments/assets/eef49b00-58cf-4a1d-88d5-62b3ef6b60c5" />
- Proyecto de prueba corriendo en docker.png (web 2048 servida en la IP pública)
  <img width="1260" height="1230" alt="Proyecto de prueba corriendo en docker" src="https://github.com/user-attachments/assets/ec15fe4c-472f-4e31-a93f-fb163304e6ba" />

## 10) Problemas y soluciones
- Clave .pem en Windows (Permission denied):
  - Causa: ACLs amplias (OneDrive).
  - Solución: mover .pem a %USERPROFILE%\.ssh y restringir permisos (o usar WSL con chmod 400).
- Push denied por namespace:
  - Causa: tag o login con usuario distinto.
  - Solución: `docker tag ... enmasdiaz/...` o `docker logout` && `docker login` con el usuario correcto.
- GitHub Actions 401 “insufficient scopes”:
  -Causa: token sin permisos/erróneo.
  -Solución: regenerar Access Token (write) en Docker Hub y actualizar DOCKERHUB_TOKEN.
- Permiso al socket Docker en EC2:
  -Causa: usuario fuera del grupo docker.
  -Solución: sudo usermod -aG docker ec2-user y reconectar.

## 11) Validaciones finales
- Local: build + run en `localhost:8080`.
- CI/CD: workflow en Actions con estado “Success”; imagen visible en Docker Hub (latest, 1.0).
- Producción: servicio activo en `http://18.221.43.134`.

## 12) .gitignore
```
# SO / editores
.DS_Store
Thumbs.db
desktop.ini
.vscode/
.idea/
*.iml

# Logs / temporales
*.log
*.tmp
~$*
*.swp

# Docker
*.tar
docker-save-*.tar
docker*cache*

# Claves y secretos
*.pem
*.key
*.crt
.env
.env.*
```
## 13) Referencias
- Práctica: https://josejuansanchez.org/iaw/practica-dockerizar-web/
- Dockerfile: https://docs.docker.com/engine/reference/builder/
- Docker Compose: https://docs.docker.com/compose/
- GitHub Actions (Docker): https://docs.github.com/es/actions/publishing-packages/publishing-docker-images
- Proyecto 2048: https://github.com/josejuansanchez/2048
