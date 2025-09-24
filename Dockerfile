# ---- STAGE 1: build ----
FROM node:18-alpine3.15 AS builder

# Set working directory
WORKDIR /var/www/pokedex

# Copiar el directorio y su contenido
COPY package.json package-lock.json* ./

# Instalar todas las dependencias (incluyendo dev) necesarias para build
RUN npm ci

# Copiar el resto del código fuente
COPY . .

# Ejecutar build (usa el script "build" de package.json)
RUN npm run build


# ---- STAGE 2: production image ----
FROM node:18-alpine3.15 AS runner

# Crear usuario no-root
RUN adduser -D -g '' pokeuser

WORKDIR /var/www/pokedex

# Copiar package.json y package-lock para instalar solo prod deps
COPY package.json package-lock.json* ./

# Instalar solo dependencias de producción
RUN npm ci --only=production

# Copiar los archivos resultantes del build desde el stage builder
COPY --from=builder /var/www/pokedex/dist ./dist

# Ajustar permisos y cambiar usuario
RUN chown -R pokeuser:pokeuser /var/www/pokedex
USER pokeuser

EXPOSE 3000

CMD [ "node","dist/main" ]