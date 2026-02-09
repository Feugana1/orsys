# TP3: Production-Ready - Sécurité et Monitoring

**Niveau:** ⭐⭐⭐ Avancé
**Durée:** 1.5 heures
**Objectif:** Créer une image prête pour production

---

## 📚 Concepts Couverts

- Health checks
- Logging avancé
- Labels et métadonnées
- Resource limits
- Sécurité avancée
- Vulnerability scanning
- Image signing

---

## 🎯 Exercice 1: Analyser une Image Production-Ready

### Étape 1: Examiner les patterns

```bash
cd automatisation-build
cat Dockerfile
```

### Questions:
1. Quels sont les labels présents?
2. Y a-t-il des health checks?
3. Comment sont gérées les variables d'environnement?
4. Comment les dépendances sont-elles isolées?

**Réponses attendues:**
- Multistage avec venv
- USER non-root
- Environment variables documentées
- Layer caching optimisé

---

## 🏥 Exercice 2: Implémenter Health Checks

### Créer une app Flask avec health check

```bash
mkdir -p my-flask-app
cd my-flask-app

cat > app.py << 'EOF'
from flask import Flask, jsonify
import os
import sys

app = Flask(__name__)

# Health check endpoint
@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'version': '1.0.0'
    }), 200

@app.route('/')
def hello():
    return 'Hello Flask!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF

cat > requirements.txt << 'EOF'
Flask==2.3.0
gunicorn==20.1.0
EOF

cat > healthcheck.py << 'EOF'
#!/usr/bin/env python3
import requests
import sys

try:
    response = requests.get('http://localhost:5000/health', timeout=5)
    if response.status_code == 200:
        sys.exit(0)
    else:
        sys.exit(1)
except Exception as e:
    print(f"Health check failed: {e}")
    sys.exit(1)
EOF

chmod +x healthcheck.py

cat > Dockerfile << 'EOF'
# Stage 1: Builder
FROM python:3.11-slim AS builder

WORKDIR /build
COPY requirements.txt .
RUN python -m venv /build/venv && \
    /build/venv/bin/pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

# Metadata
LABEL maintainer="your-email@example.com"
LABEL version="1.0.0"
LABEL description="Flask application with health checks"

# Environment variables
ENV PATH="/app/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copy venv from builder
COPY --from=builder /build/venv /app/venv

# Copy app
COPY . .

# Create non-root user
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python healthcheck.py || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
EOF
```

### Builder et tester

```bash
docker build -t flask-app:1.0 .

# Vérifier les labels
docker inspect flask-app:1.0 | jq '.Config.Labels'

# Voir le health check
docker inspect flask-app:1.0 | jq '.Config.Healthcheck'

# Lancer
docker run -d --name flask-test -p 5000:5000 flask-app:1.0

# Vérifier la santé
sleep 5
docker inspect flask-test | jq '.State.Health'

# Test HTTP
curl http://localhost:5000/health
curl http://localhost:5000

# Nettoyer
docker stop flask-test
docker rm flask-test
```

### Vérifications:
- Health check retourne `healthy`
- Status est `healthy` après 5 secondes
- Logs montrent gunicorn running

---

## 🏷️ Exercice 3: Labels et Métadonnées

### Ajouter des labels détaillés

```dockerfile
LABEL maintainer="your-email@example.com" \
      version="1.0.0" \
      description="Flask application" \
      org.opencontainers.image.source="https://github.com/example/repo" \
      org.opencontainers.image.documentation="https://example.com/docs" \
      org.opencontainers.image.vendor="Your Company" \
      com.example.environment="production"
```

### Inspecter les labels

```bash
docker inspect flask-app:1.0 | jq '.Config.Labels'
docker inspect flask-app:1.0 --format='{{json .Config.Labels}}' | jq
```

### Utiliser les labels pour filtrer

```bash
# Trouver les images de production
docker images --filter "label=com.example.environment=production"

# Voir les labels avec docker images
docker images --no-trunc --quiet --filter "reference=flask-app:*" | \
  xargs -I {} docker inspect {} | jq -r '.[0].Config.Labels'
```

---

## 🔐 Exercice 4: Sécurité Avancée

### Créer une image sécurisée

```dockerfile
# Stage 1: Builder
FROM python:3.11-slim AS builder

WORKDIR /build
COPY requirements.txt .
RUN python -m venv /build/venv && \
    /build/venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel && \
    /build/venv/bin/pip install --no-cache-dir -r requirements.txt

# Stage 2: Scanner (optionnel mais bon pour CI/CD)
FROM python:3.11-slim AS scanner

WORKDIR /build
COPY --from=builder /build/venv /build/venv
RUN /build/venv/bin/pip install safety && \
    /build/venv/bin/safety check --json || true

# Stage 3: Runtime (minimal)
FROM python:3.11-slim

# Metadata (sécurité minimale)
LABEL org.opencontainers.image.source="https://github.com/example/repo"

# Environment - Sans secrets!
ENV PATH="/app/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Security: Read-only filesystem où possible
RUN chmod -R 555 /usr/local/lib/python3.11 && \
    chmod -R 755 /app

# Copy venv (immutable après build)
COPY --from=builder --chown=1000:1000 /build/venv /app/venv

# Copy app
COPY --chown=1000:1000 . .

# Create non-root user with explicit UID
RUN useradd -m -u 1000 -s /sbin/nologin appuser

USER 1000:1000

# Security: Drop capabilities
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
    CMD python healthcheck.py || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
EOF
```

### Vérifier les permissions

```bash
docker run --rm flask-app:1.0 id
# uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)

# Vérifier qu'on ne peut pas devenir root
docker run --rm flask-app:1.0 sudo -l
# ne doit pas fonctionner

# Vérifier qu'on ne peut pas modifier les files système
docker run --rm flask-app:1.0 touch /usr/bin/test
# Doit échouer avec "Read-only file system"
```

---

## 📊 Exercice 5: Scanning Vulnerabilités

### Installer Trivy

```bash
# MacOS
brew install trivy

# Linux
wget https://github.com/aquasecurity/trivy/releases/download/v0.42.0/trivy_0.42.0_Linux-64bit.tar.gz
tar xzf trivy_0.42.0_Linux-64bit.tar.gz

# Windows
chocolatey install trivy
```

### Scanner l'image

```bash
docker build -t flask-app:1.0 .

# Scanner de vulnérabilités
trivy image flask-app:1.0

# Format JSON pour analyse
trivy image --format json flask-app:1.0 | jq '.[0].Results[0].Vulnerabilities'

# Scanner avec severity minimal
trivy image --severity HIGH,CRITICAL flask-app:1.0

# Compare avec une image non-optimisée
docker build -f Dockerfile.bad -t flask-app:bad .
trivy image flask-app:bad
```

### Actions si vulnérabilités trouvées:
1. Update base image
2. Update dépendances
3. Use minimal base images (alpine)

---

## 🎬 Exercice 6: Build Arguments et Configurabilité

### Créer un Dockerfile avec build args

```dockerfile
# Version avec build-time configuration
ARG BASE_IMAGE=python:3.11-slim
ARG APP_VERSION=1.0.0
ARG BUILD_DATE="2024-01-01"

FROM ${BASE_IMAGE} AS base

ARG APP_VERSION
ARG BUILD_DATE

LABEL org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}"

# ... reste du Dockerfile
```

### Builder avec des arguments

```bash
# Build avec versions personnalisées
docker build \
  --build-arg APP_VERSION=2.0.0 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  -t flask-app:2.0.0 .

# Vérifier les labels
docker inspect flask-app:2.0.0 | jq '.Config.Labels'
```

---

## 📦 Exercice 7: Optimisation Finale

### Mesurer tout

```bash
# Taille de l'image
docker images flask-app

# Layers
docker history flask-app:1.0

# Utilisation mémoire
docker run -d -m 256m flask-app:1.0
docker stats

# Scanner complète
dive flask-app:1.0  # if installed
```

### Matrice de qualité:

| Critère | Basique ⭐ | Intermédiaire ⭐⭐ | Production ⭐⭐⭐ |
|---------|-----------|----------------|------------|
| Taille | <500MB | <300MB | <150MB |
| Layers | <15 | <10 | <5 |
| USER | N/A | non-root | explicit UID |
| Health | N/A | Basique | Avancé |
| Labels | N/A | Version | Complet |
| Scan | N/A | Manuel | CI/CD |

---

## ✅ Validation - Checklist

- [ ] Image construite sans erreurs
- [ ] Health check implémenté et actif
- [ ] USER est non-root avec UID explicite
- [ ] Labels présents et corrects
- [ ] Trivy scanner: Pas de vulnérabilités CRITICAL
- [ ] Taille < 200MB
- [ ] Tests HTTP réussissent
- [ ] Logs visibles: `docker logs`
- [ ] Peut être scalé: resource limits applicables

---

## 🎓 Points Clés à Retenir

1. **Health Checks = Orchestration-Ready**
   - Sans health checks, l'orchestrateur ne sait pas l'état réel
   - Évite de router vers des services défaillants

2. **Labels = Documentés et Filtrable**
   - Métadonnées pour registries, CI/CD, logs
   - Essentielles pour la gestion d'images

3. **Sécurité = Couches**
   - Non-root + dropped capabilities + read-only
   - Reduce attack surface drastiquement

4. **Monitoring = Intégré**
   - Logs structurés
   - Métriques disponibles
   - Health checks actifs

5. **Scanning = Obligatoire**
   - Trivy, Grype, ou Snyk
   - CI/CD hook
   - Alertes sur vulnérabilités

---

## 🔗 Prochaine Étape

→ **Docker Compose** - Orchestrer plusieurs conteneurs production-ready

## 💡 Ressources Production

- [OWASP Container Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Snyk Container Scanning](https://snyk.io/product/container-security/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)

---

**Fin TP3** ✅
