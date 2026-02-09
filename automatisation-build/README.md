# 🤖 Automatisation Build - CI/CD avec Docker

Apprenez à automatiser la construction et le déploiement d'images Docker.

## 📚 Contenu

Ce module démontre les patterns de production pour builder, tagger et déployer des images Docker automatiquement.

### ⭐ Basique
- `Dockerfile` - Multistage optimisé avec venv Python
- `build.sh` - Script de build basique
- Concepts: multistage, optimisation, venv
- Production-ready

### ⭐⭐ Intermédiaire
- Automatisation avec scripts shell
- Tagging d'images propre
- Gestion des dépendances
- Concepts: versioning, tagging, registries

### ⭐⭐⭐ Avancé
- GitHub Actions (CI/CD)
- Lint → Build → Tag → Push
- Voir: `.github/workflows/` (à créer)
- Concepts: automation, pipelines, registries

## 🚀 Démarrage Rapide

### 1. Examiner la Structure

```bash
cd automatisation-build
cat Dockerfile          # Production pattern
cat build.sh           # Build script
cat requirements.txt   # Dépendances
```

### 2. Build Manuel

```bash
# Lancer le script de build
./build.sh

# Ou manuellement
docker build -t myapp:1.0 .

# Avec métadonnées
docker build \
  -t myapp:1.0 \
  --label "version=1.0" \
  --label "date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  .
```

### 3. Tester l'Image

```bash
docker run --rm myapp:1.0 python --version
docker run --rm myapp:1.0 pip list
```

## 📖 Fichiers

| Fichier | Description | Rôle |
|---------|-------------|------|
| `Dockerfile` | Multistage Python production-grade | Build |
| `build.sh` | Script automatisé | Automation |
| `requirements.txt` | Dépendances Python | Config |
| `.github/workflows/` | GitHub Actions (NEW) | CI/CD |

## 🎓 TP Recommandés

### 1. **TP1 (⭐):** Build Script Basique
   - Durée: 45 min
   - Comprendre build.sh
   - Builder une image
   - Voir: TP/TP1-build.md

### 2. **TP2 (⭐⭐):** Tagging & Versioning
   - Durée: 1h
   - Tags sémantiques
   - Push à un registry
   - Voir: TP/TP2-tagging.md

### 3. **TP3 (⭐⭐⭐):** GitHub Actions
   - Durée: 1.5h
   - Lint & Build auto
   - Push automatique
   - Voir: TP/TP3-github-actions.md

## 💡 Concepts Clés

### Multistage Build (Production Pattern)

```dockerfile
# Stage 1: Build
FROM python:3.11-slim AS builder

WORKDIR /build
COPY requirements.txt .
RUN python -m venv /build/venv && \
    /build/venv/bin/pip install -r requirements.txt

# Stage 2: Runtime (petite image)
FROM python:3.11-slim

COPY --from=builder /build/venv /app/venv
COPY . /app
WORKDIR /app

ENV PATH="/app/venv/bin:$PATH"
CMD ["python", "app.py"]

# Image finale: ~200MB au lieu de ~1GB
```

### Tagging Sémantique

```bash
# Version: MAJOR.MINOR.PATCH
docker build -t myapp:1.0.0 .
docker build -t myapp:1.0 .
docker build -t myapp:latest .

# Avec registry
docker build -t registry.example.com/myapp:1.0.0 .
docker push registry.example.com/myapp:1.0.0
```

### Build Script Automatisé

```bash
#!/bin/bash
set -e

VERSION=${1:-1.0.0}
REGISTRY=${2:-docker.io}
IMAGE="${REGISTRY}/myapp"

echo "Building $IMAGE:$VERSION"
docker build \
  -t $IMAGE:$VERSION \
  -t $IMAGE:latest \
  --build-arg VERSION=$VERSION \
  .

echo "Tagging..."
docker tag $IMAGE:$VERSION $IMAGE:latest

echo "Done!"
echo "To push: docker push $IMAGE:$VERSION"
```

## 🔧 Commandes Essentielles

```bash
# Builder avec script
cd automatisation-build
./build.sh 1.0.0

# Builder manuellement
docker build -t myapp:1.0 .

# Voir les layers
docker history myapp:1.0

# Inspecter métadonnées
docker inspect myapp:1.0 | jq '.Config'

# Push à un registry
docker push registry.example.com/myapp:1.0

# Scanner les vulnérabilités
docker scan myapp:1.0
```

## 🔗 Lire Aussi

- [TP_CORRIGES_ET_AVANCES.md](../TP_CORRIGES_ET_AVANCES.md) - TP complets
- [STRUCTURE.md](../STRUCTURE.md) - Architecture
- [dockerfile/README.md](../dockerfile/README.md) - Créer des images
- `.github/workflows/docker.yml` - GitHub Actions configuration

## 📚 Ressources

- [Docker Build Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [GitHub Actions & Docker](https://github.com/features/actions)
- [Semantic Versioning](https://semver.org/)

## ✅ Progression Pédagogique

```
⭐ Basique (Semaine 1)
  ├─ Multistage builds
  ├─ Venv Python
  └─ Build scripts

⭐⭐ Intermédiaire (Semaine 2)
  ├─ Semantic tagging
  ├─ Registry integration
  └─ Push automation

⭐⭐⭐ Avancé (Semaine 3)
  ├─ GitHub Actions
  ├─ Lint & tests
  ├─ Security scanning
  └─ Multi-registry deploys
```

## 🆘 Troubleshooting

| Problème | Solution |
|----------|----------|
| "build.sh not found" | `chmod +x build.sh` |
| "Permission denied" | `chmod +x build.sh` |
| "Module not found" | Vérifier requirements.txt |
| "Image too large" | Utiliser multistage + slim base |

---

**Prêt à automatiser?** 🚀

Commencez par `TP/TP1-build.md` →
