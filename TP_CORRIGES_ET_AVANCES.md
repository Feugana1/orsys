# 📋 TP Docker - Corrections et Versions Avancées

Basé sur le support de formation TAMTSE - Docker 1.6

---

## 📚 Table des Matières

1. [TP 1: Premier Conteneur](#tp-1-premier-conteneur)
2. [TP 2: Interconnexion TCP](#tp-2-interconnexion-tcp)
3. [TP 3: Connexion du Volume](#tp-3-connexion-du-volume)
4. [TP 4: Publication des Ports](#tp-4-publication-des-ports)
5. [TP Avancés pour Experts](#tp-avancés-pour-experts)

---

## TP 1: Premier Conteneur

### 📖 Exercice du Support

**Objectif:** Lancer un serveur web NGINX simple

### ✅ Solution Basique (Correcte)

```bash
# Lancer NGINX sur le port 8080
docker run --name nginx -p 8080:80 nginx

# Alternative: Mode détaché (-d)
docker run -d --name nginx -p 8080:80 nginx
```

**Explications:**
- `--name nginx` : Nommer le conteneur (plus lisible que l'ID)
- `-p 8080:80` : Mapper port 8080 (hôte) → 80 (conteneur)
- `-d` : Détaché (background)

**Validation:**
```bash
# Vérifier que le conteneur tourne
docker ps

# Accéder au service
curl http://localhost:8080
# Ou navigateur: http://localhost:8080
```

### 🔧 Points d'Amélioration dans le Support

Le support montre la commande basique mais manque:
- ❌ Pas de `--rm` pour nettoyer automatiquement
- ❌ Pas d'explications sur les flags
- ❌ Pas de health checks

### ✨ Version Améliorée (Bonnes Pratiques)

```bash
# Version recommandée avec meilleure gestion
docker run -d \
  --name nginx \
  --restart unless-stopped \
  --health-cmd="curl -f http://localhost/ || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  -p 8080:80 \
  nginx:latest

# Vérifier l'état de santé
docker ps
# STATUS devrait dire "Up ... (healthy)"
```

**Améliorations:**
- `--restart unless-stopped` : Redémarrer si crash
- `--health-*` : Vérifier que le service est prêt
- Tag version `latest` explicite (meilleure pratique)

### 🚀 Version Avancée (Expert)

```bash
# Lancer avec limite de ressources et logs structurés
docker run -d \
  --name nginx-pro \
  --restart unless-stopped \
  --memory="256m" \
  --cpus="0.5" \
  --log-driver json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  --health-cmd="curl -f http://localhost/ || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  --label "app=webserver" \
  --label "version=1.0" \
  --label "env=production" \
  -p 8080:80 \
  -v /etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  --network web-network \
  nginx:alpine

# Vérifier les ressources
docker stats nginx-pro

# Voir les labels
docker inspect nginx-pro | jq '.Config.Labels'

# Voir les logs structurés
docker logs --tail 50 -f nginx-pro
```

**Nouveautés Expert:**
- `--memory` / `--cpus` : Limiter les ressources
- `--log-driver` / `--log-opt` : Gestion des logs
- `--label` : Métadonnées pour tagging/filtrage
- `-v` : Volume en lecture seule pour config
- `--network` : Intégration réseau nommée
- `nginx:alpine` : Image plus légère (5MB vs 140MB)

---

## TP 2: Interconnexion TCP

### 📖 Exercice du Support

**Objectif:** Lancer WordPress + MySQL avec connexion TCP

### ✅ Solution Basique (Correcte)

**Étape 1: Lancer MySQL**
```bash
docker run -e MYSQL_ROOT_PASSWORD=wordpress \
           -e MYSQL_DATABASE=wordpress \
           --name wordpressdb \
           -d \
           mariadb:latest
```

**Étape 2: Lancer WordPress**
```bash
docker run -e WORDPRESS_DB_USER=root \
           -e WORDPRESS_DB_PASSWORD=wordpress \
           -e WORDPRESS_DB_HOST=wordpressdb:mysql \
           -e WORDPRESS_DB_NAME=wordpress \
           --name wordpress \
           --link wordpressdb:mysql \
           -p 80:80 \
           -d \
           wordpress
```

**Étape 3: Vérifier la connexion**
```bash
# Vérifier les conteneurs
docker ps

# Ping depuis WordPress
docker exec -it wordpress bash
apt-get update && apt-get install -y iputils-ping
ping wordpressdb

# Tester MySQL
mysql -h wordpressdb -u root -pwordpress wordpress
```

### ⚠️ Problèmes dans le Support

Le support utilise:
- ❌ `--link` (deprecated depuis Docker 1.9!)
- ❌ Pas de volumes (données perdues!)
- ❌ Credentials en clair
- ❌ Pas de réseau isolé

### ✨ Version Améliorée (Recommandée)

```bash
# Créer un réseau dédié
docker network create wordpress-net

# Lancer MySQL
docker run -d \
  --name wordpress-db \
  --network wordpress-net \
  --restart unless-stopped \
  -e MYSQL_ROOT_PASSWORD=secure_password_123 \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wp_user \
  -e MYSQL_PASSWORD=secure_wp_pass \
  -v wordpress_db_data:/var/lib/mysql \
  --health-cmd="mysqladmin ping -h localhost" \
  --health-interval=10s \
  mariadb:10.6-focal

# Lancer WordPress
docker run -d \
  --name wordpress \
  --network wordpress-net \
  --restart unless-stopped \
  -e WORDPRESS_DB_HOST=wordpress-db:3306 \
  -e WORDPRESS_DB_USER=wp_user \
  -e WORDPRESS_DB_PASSWORD=secure_wp_pass \
  -e WORDPRESS_DB_NAME=wordpress \
  -e WORDPRESS_TABLE_PREFIX=wp_ \
  -p 80:80 \
  -v wordpress_html:/var/www/html \
  wordpress:latest

# Vérifier
docker ps
docker logs wordpress  # Voir les logs
docker network inspect wordpress-net  # Voir le réseau
```

**Améliorations:**
- ✅ Réseau dédié (plus sûr que `--link`)
- ✅ Volumes pour la persistance
- ✅ Health checks
- ✅ Restart policy
- ✅ Passwords securisées

### 🚀 Version Avancée (Expert)

```bash
# Créer un réseau avec configuration avancée
docker network create \
  --driver bridge \
  --subnet=172.25.0.0/16 \
  --gateway=172.25.0.1 \
  --opt "com.docker.network.driver.mtu=1500" \
  wordpress-net-pro

# MySQL avec backup automatique
docker run -d \
  --name wordpress-db-pro \
  --network wordpress-net-pro \
  --ip=172.25.0.2 \
  --restart unless-stopped \
  --health-cmd="mysqladmin ping -h localhost" \
  --health-interval=10s \
  --memory="512m" \
  --cpus="1" \
  -e MYSQL_ROOT_PASSWORD_FILE=/run/secrets/mysql_root_pass \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wp_user \
  -e MYSQL_PASSWORD_FILE=/run/secrets/mysql_wp_pass \
  -v wordpress_db_data:/var/lib/mysql \
  -v $(pwd)/backups:/backups \
  --log-driver json-file \
  --log-opt max-size=10m \
  --label "app=wordpress-db" \
  --label "version=10.6" \
  mariadb:10.6-focal

# WordPress avec optimisations
docker run -d \
  --name wordpress-pro \
  --network wordpress-net-pro \
  --ip=172.25.0.3 \
  --restart unless-stopped \
  --health-cmd="curl -f http://localhost/ || exit 1" \
  --health-interval=30s \
  --memory="1g" \
  --cpus="2" \
  -e WORDPRESS_DB_HOST=wordpress-db-pro:3306 \
  -e WORDPRESS_DB_USER=wp_user \
  -e WORDPRESS_DB_PASSWORD_FILE=/run/secrets/wordpress_db_pass \
  -e WORDPRESS_DB_NAME=wordpress \
  -e WORDPRESS_TABLE_PREFIX=wp_ \
  -e WORDPRESS_DEBUG=false \
  -e WORDPRESS_CONFIG_EXTRA='
    define("ALTERNATE_WP_CRON", true);
    define("WP_MEMORY_LIMIT", "256M");
  ' \
  -p 80:80 \
  -p 443:443 \
  -v wordpress_html:/var/www/html \
  -v wordpress_plugins:/var/www/html/wp-content/plugins \
  -v wordpress_themes:/var/www/html/wp-content/themes \
  --log-driver json-file \
  --log-opt max-size=10m \
  --label "app=wordpress" \
  --label "version=latest" \
  wordpress:php8.1-apache

# Créer un script de backup
cat > backup_wordpress.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/wordpress-backups"
DB_CONTAINER="wordpress-db-pro"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Dump MySQL
docker exec $DB_CONTAINER mysqldump -u wp_user -p$WP_PASS wordpress > \
  $BACKUP_DIR/wordpress_$TIMESTAMP.sql

# Compression
gzip $BACKUP_DIR/wordpress_$TIMESTAMP.sql

echo "Backup créé: $BACKUP_DIR/wordpress_$TIMESTAMP.sql.gz"
EOF

chmod +x backup_wordpress.sh
```

**Nouveautés Expert:**
- Subnet fixe pour contrôle réseau
- Secrets (au lieu de passwords en clair)
- Ressources limitées pour stabilité
- Health checks avancés
- Configuration WordPress optimisée
- Script de backup
- Logging structuré
- Labels pour orchestration

---

## TP 3: Connexion du Volume

### 📖 Exercice du Support

**Objectif:** Persister les données WordPress et MySQL

### ✅ Solution Basique (Correcte)

```bash
# Créer les volumes
docker volume create wordpress_html
docker volume create wordpress_db_data

# Lancer MySQL avec volume
docker run -d \
  --name wordpress-db \
  -v wordpress_db_data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=wordpress \
  mariadb

# Lancer WordPress avec volume
docker run -d \
  --name wordpress \
  -v wordpress_html:/var/www/html \
  -p 80:80 \
  -e WORDPRESS_DB_HOST=wordpress-db \
  wordpress

# Vérifier les volumes
docker volume ls
docker volume inspect wordpress_db_data
```

### ✨ Version Améliorée

```bash
# Utiliser docker-compose pour mieux organiser
cat > docker-compose.yml << 'EOF'
version: '3.9'

services:
  wordpress-db:
    image: mariadb:10.6
    container_name: wordpress-db
    restart: unless-stopped
    networks:
      - wordpress
    volumes:
      - wordpress_db_data:/var/lib/mysql
      - ./backup:/backups  # Pour les sauvegardes
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: wordpress
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 3

  wordpress:
    image: wordpress:latest
    container_name: wordpress
    restart: unless-stopped
    networks:
      - wordpress
    volumes:
      - wordpress_html:/var/www/html
      - ./config/php.ini:/usr/local/etc/php/conf.d/custom.ini:ro
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: wordpress-db:3306
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      wordpress-db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  wordpress:
    driver: bridge

volumes:
  wordpress_db_data:
    driver: local
  wordpress_html:
    driver: local
EOF

# Fichier .env
cat > .env << 'EOF'
MYSQL_ROOT_PASSWORD=secure_root_pass
MYSQL_USER=wp_user
MYSQL_PASSWORD=secure_wp_pass
EOF

# Lancer le stack
docker-compose up -d

# Vérifier
docker-compose ps
docker volume ls
```

### 🚀 Version Avancée (Expert)

```bash
# Docker compose avancé avec persistance optimisée
cat > docker-compose-pro.yml << 'EOF'
version: '3.9'

services:
  wordpress-db:
    image: mariadb:10.6-focal
    container_name: wordpress-db-pro
    restart: unless-stopped
    networks:
      - wordpress-pro
    volumes:
      # Mount binding pour backups
      - type: bind
        source: ./data/mysql
        target: /var/lib/mysql

      # Volume nommé pour durabilité
      - wordpress_db_data_pro:/backups

      # Config MySQL personnalisée
      - ./config/mysql.cnf:/etc/mysql/conf.d/custom.cnf:ro

    environment:
      MYSQL_ROOT_PASSWORD_FILE: /run/secrets/db_root_password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wp_user
      MYSQL_PASSWORD_FILE: /run/secrets/db_password

    secrets:
      - db_root_password
      - db_password

    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M

  wordpress:
    image: wordpress:php8.1-apache
    container_name: wordpress-pro
    restart: unless-stopped
    networks:
      - wordpress-pro

    volumes:
      - type: bind
        source: ./data/wordpress
        target: /var/www/html

      - wordpress_html_pro:/var/www/html

      # Config PHP personnalisée
      - ./config/php.ini:/usr/local/etc/php/conf.d/custom.ini:ro

      # Thèmes et plugins en volume séparé
      - wordpress_plugins_pro:/var/www/html/wp-content/plugins
      - wordpress_themes_pro:/var/www/html/wp-content/themes

    ports:
      - "80:80"
      - "443:443"

    environment:
      WORDPRESS_DB_HOST: wordpress-db-pro:3306
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wp_user
      WORDPRESS_DB_PASSWORD_FILE: /run/secrets/db_password
      WORDPRESS_TABLE_PREFIX: wp_
      WORDPRESS_DEBUG: ${WP_DEBUG:-false}
      WORDPRESS_CONFIG_EXTRA: |
        define('ALTERNATE_WP_CRON', true);
        define('WP_MEMORY_LIMIT', '256M');
        define('WP_MAX_MEMORY_LIMIT', '512M');

    secrets:
      - db_password

    depends_on:
      wordpress-db:
        condition: service_healthy

    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service=wordpress"

    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          cpus: '1'
          memory: 512M

  phpmyadmin:
    image: phpmyadmin:latest
    container_name: phpmyadmin-pro
    restart: unless-stopped
    networks:
      - wordpress-pro

    ports:
      - "8081:80"

    environment:
      PMA_HOST: wordpress-db-pro
      PMA_USER: wp_user
      PMA_PASSWORD_FILE: /run/secrets/db_password
      PMA_ABSOLUTE_URI: http://localhost:8081/

    secrets:
      - db_password

    depends_on:
      - wordpress-db

    logging:
      driver: "json-file"
      options:
        max-size: "5m"
        max-file: "2"

  # Backup automatique
  backup:
    image: mariadb:10.6-focal
    container_name: backup-pro
    restart: unless-stopped
    networks:
      - wordpress-pro

    volumes:
      - wordpress_db_data_pro:/backups
      - ./scripts/backup.sh:/backup.sh:ro

    entrypoint: /bin/bash
    command: -c "while true; do /backup.sh; sleep 86400; done"

    environment:
      MYSQL_HOST: wordpress-db-pro
      MYSQL_USER: wp_user
      MYSQL_PASSWORD_FILE: /run/secrets/db_password

    secrets:
      - db_password

    depends_on:
      - wordpress-db

networks:
  wordpress-pro:
    driver: bridge
    driver_opts:
      com.docker.network.driver.mtu: 1500

volumes:
  wordpress_db_data_pro:
    driver: local
    driver_opts:
      type: tmpfs
      device: tmpfs
      o: size=1G

  wordpress_html_pro:
    driver: local

  wordpress_plugins_pro:
    driver: local

  wordpress_themes_pro:
    driver: local

secrets:
  db_root_password:
    file: ./secrets/db_root_password.txt
  db_password:
    file: ./secrets/db_password.txt
EOF

# Script de backup
cat > scripts/backup.sh << 'EOFSCRIPT'
#!/bin/bash
set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
DB_HOST="${MYSQL_HOST:-wordpress-db-pro}"
DB_USER="${MYSQL_USER:-wp_user}"
DB_NAME="wordpress"

echo "[$(date)] Début du backup..."

# Créer le dump
mysqldump -h "$DB_HOST" -u "$DB_USER" -p$(cat /run/secrets/db_password) \
  "$DB_NAME" | gzip > "$BACKUP_DIR/wordpress_$TIMESTAMP.sql.gz"

# Garder seulement les 7 derniers backups
find "$BACKUP_DIR" -name "wordpress_*.sql.gz" -mtime +7 -delete

echo "[$(date)] Backup complété: $BACKUP_DIR/wordpress_$TIMESTAMP.sql.gz"
EOFSCRIPT

chmod +x scripts/backup.sh

# Fichier .env avancé
cat > .env.pro << 'EOF'
WP_DEBUG=true
COMPOSE_PROJECT_NAME=wordpress-pro
MYSQL_ROOT_PASSWORD_FILE=./secrets/db_root_password.txt
EOF

# Créer les répertoires
mkdir -p data/{mysql,wordpress} config secrets scripts

# Générer les secrets
openssl rand -base64 32 > secrets/db_root_password.txt
openssl rand -base64 32 > secrets/db_password.txt
chmod 600 secrets/*.txt

# Lancer le stack complet
docker-compose -f docker-compose-pro.yml up -d

# Afficher le status
echo "📊 Status du stack:"
docker-compose -f docker-compose-pro.yml ps

echo "📁 Volumes:"
docker volume ls | grep pro

echo "🔗 Réseaux:"
docker network ls | grep pro

echo "✅ WordPress accessible à: http://localhost"
echo "✅ phpMyAdmin accessible à: http://localhost:8081"
```

**Nouveautés Expert:**
- Mount bindings pour contrôle OS
- Secrets sécurisés (pas de passwords visibles)
- Config MySQL et PHP personnalisée
- Service phpmyadmin pour gestion DB
- Service de backup automatique
- Ressources limitées et réservées
- Logging structuré par service
- Cleanup des anciens backups
- Prêt pour production (healthchecks, restart policies)

---

## TP 4: Publication des Ports

### 📖 Exercice du Support

**Objectif:** Exposer les ports des conteneurs

### ✅ Solution Basique (Correcte)

```bash
# Port fixe (-p)
docker run -d -p 8080:80 nginx

# Port aléatoire (-P)
docker run -d -P nginx

# Vérifier les ports
docker ps
# Voir PORTS colonne

# Tester
curl http://localhost:8080
```

### ✨ Version Améliorée

```bash
# Plusieurs ports
docker run -d \
  --name nginx-multi \
  -p 8080:80 \
  -p 8443:443 \
  -p 9000:9000 \
  nginx

# Port spécifique à une interface réseau
docker run -d \
  --name nginx-specific \
  -p 127.0.0.1:8080:80 \
  -p 0.0.0.0:8443:443 \
  nginx

# UDP ports
docker run -d \
  --name dns \
  -p 53:53/udp \
  -p 53:53/tcp \
  ubuntu/bind9
```

### 🚀 Version Avancée (Expert)

```bash
# Expose avancé avec ingress networking
docker network create \
  --driver overlay \
  --scope swarm \
  nginx-network

# Service avec ingress (Swarm mode)
docker service create \
  --name nginx-service \
  --publish published=8080,target=80,protocol=tcp,mode=ingress \
  --publish published=8443,target=443,protocol=tcp,mode=ingress \
  --replicas 3 \
  --constraint node.role==worker \
  --limit-cpu 1 \
  --limit-memory 512m \
  --reserve-cpu 0.5 \
  --reserve-memory 256m \
  --update-delay 10s \
  --update-parallelism 1 \
  --rollback-on-failure \
  --health-cmd="curl -f http://localhost/ || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  --log-driver json-file \
  --log-opt max-size=10m \
  nginx:latest

# Service avec load balancing avancé
docker service update \
  --publish-rm 8080 \
  --publish-add published=8080,target=80,protocol=tcp,mode=ingress,load-balancer-algorithm=random \
  nginx-service

# Vérifier le service
docker service ps nginx-service
docker service logs nginx-service

# Accéder via load balancer
curl http://localhost:8080

# Stats du service
docker stats --no-stream
```

---

## 🚀 TP Avancés pour Experts

### TP 5: Dockerfile Optimisé Multi-Stage

**Objectif:** Créer une image légère et sécurisée

```dockerfile
# Stage 1: Builder
FROM node:18-alpine AS builder

WORKDIR /build

COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

COPY . .
RUN npm run build

# Stage 2: Runtime
FROM node:18-alpine

WORKDIR /app

# Créer utilisateur non-root
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

# Copier depuis builder
COPY --from=builder --chown=nodejs:nodejs /build/dist /app/
COPY --from=builder --chown=nodejs:nodejs /build/node_modules /app/node_modules
COPY --from=builder --chown=nodejs:nodejs /build/package.json /app/

# Labels
LABEL maintainer="your-email@example.com"
LABEL version="1.0"
LABEL description="Optimized Node.js application"
LABEL security="non-root user"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# User non-root
USER nodejs

# Port
EXPOSE 3000

# Startup
CMD ["node", "index.js"]
```

### TP 6: Docker Compose avec Traefik

```yaml
version: '3.9'

services:
  traefik:
    image: traefik:v2.10
    container_name: traefik
    restart: unless-stopped
    networks:
      - traefik
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"  # Dashboard
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/traefik.yml:ro
      - ./acme.json:/acme.json
      - ./config:/config:ro
    environment:
      - CF_API_EMAIL=${CF_API_EMAIL}
      - CF_API_KEY=${CF_API_KEY}
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.rule=Host(`traefik.example.com`)"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.middlewares=auth@docker"
      - "traefik.http.middlewares.auth.basicauth.users=admin:$$apr1$$xyz..."

  app:
    image: myapp:latest
    container_name: myapp
    restart: unless-stopped
    networks:
      - traefik
    environment:
      - ENVIRONMENT=production
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`app.example.com`)"
      - "traefik.http.routers.app.entrypoints=websecure"
      - "traefik.http.routers.app.tls.certresolver=letsencrypt"
      - "traefik.http.services.app.loadbalancer.server.port=3000"
      - "traefik.http.middlewares.ratelimit.ratelimit.average=100"
      - "traefik.http.middlewares.ratelimit.ratelimit.burst=50"
      - "traefik.http.routers.app.middlewares=ratelimit@docker"

networks:
  traefik:
    driver: bridge
```

### TP 7: Monitoring avec Prometheus et Grafana

```yaml
version: '3.9'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_INSTALL_PLUGINS=grafana-clock-panel
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    ports:
      - "8080:8080"
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
```

### TP 8: CI/CD avec Docker et GitHub Actions

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main, develop ]
    tags: [ 'v*' ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: .
        push: ${{ github.event_name != 'pull_request' }}
        tags: |
          ${{ secrets.DOCKER_USERNAME }}/myapp:latest
          ${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.sha }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
        build-args: |
          BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
          VCS_REF=${{ github.sha }}
          VERSION=${{ github.ref }}
```

---

## 📊 Résumé Comparatif

| Aspect | Basique | Amélioré | Avancé |
|--------|---------|----------|---------|
| **Persistance** | Aucune | Volumes | Backups automatiques |
| **Sécurité** | Passwords en clair | Env vars | Secrets Docker |
| **Monitoring** | Aucun | Logs | Prometheus + Grafana |
| **Scaling** | 1 instance | Manual | Docker Swarm/K8s |
| **Networking** | `--link` | Networks | Overlay networks |
| **Resources** | Illimité | Limité | Reserved + Limited |
| **Health** | Aucun | Basic | Advanced checks |
| **CI/CD** | Manuel | Scripts | GitHub Actions |

---

## 🎓 Progression Recommandée

```
Jour 1: TP1-2 (Basique) → 2-3 heures
Jour 2: TP2-4 (Amélioré) → 3-4 heures
Jour 3: TP5-8 (Expert) → 4-6 heures
```

---

**Bon apprentissage Docker! 🐳**

