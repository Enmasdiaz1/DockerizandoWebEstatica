FROM ubuntu:latest

# Evitar prompts en apt
ENV DEBIAN_FRONTEND=noninteractive

# Actualiza e instala nginx y git
RUN apt-get update && \
    apt-get install -y nginx git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Limpia el contenido por defecto y clona la web 2048
RUN rm -rf /var/www/html/* && \
    git clone https://github.com/josejuansanchez/2048 /var/www/html

# Expone el puerto 80
EXPOSE 80

# Comando para ejecutar nginx en foreground
CMD ["nginx", "-g", "daemon off;"]