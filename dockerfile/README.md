# 🐳 Dockerfile - Créer des Images Docker

Apprenez à créer vos propres images Docker avec des Dockerfile.

## 📚 Contenu

Ce module couvre la création d'images Docker, du simple Dockerfile de base aux patterns avancés optimisés pour la production.

### ⭐ Basique
- `python/Dockerfile` - Image Python simple et commentée ligne par ligne
- Concepts: FROM, WORKDIR, COPY, RUN, CMD
- Parfait pour les débutants

### ⭐⭐ Intermédiaire
- `python/Dockerfile.Multistage` - Optimisation des images avec multistage builds
- Concepts: réduction de taille, stages de build/runtime
- Explique pourquoi c'est important pour la production

### ⭐⭐⭐ Avancé
- `java/Dockerfile` - Exemple enterprise avec sécurité avancée
- Concepts: USER non-root, health checks, layer caching, optimisation
- Patterns production-ready

## 🚀 Démarrage Rapide

### 1. Examiner un Dockerfile Simple

```bash
cd dockerfile/python
cat Dockerfile        # Lire les commentaires
cat requirements.txt  # Dépendances
```

### 2. Créer une Image

```bash
# Image simple
docker build -t my-python:1.0 .

# Avec tag personnalisé
docker build -t myapp:latest --tag myapp:1.0 .

# Voir les layers
docker history my-python:1.0
```

### 3. Lancer un Conteneur à partir de l'Image

```bash
docker run -it my-python:1.0 python --version
docker run -it my-python:1.0 bash  # Accès shell
```

## 📖 Fichiers

| Fichier | Description | Niveau | Taille |
|---------|-------------|--------|--------|
| `python/Dockerfile` | Image Python basique, commentée | ⭐ | ~100 lignes |
| `python/Dockerfile.Multistage` | Build optimisé (2 stages) | ⭐⭐ | ~30 lignes |
| `python/requirements.txt` | Dépendances Python | ⭐ | Simple |
| `java/Dockerfile` | Image Java production-grade | ⭐⭐⭐ | ~80 lignes |

## 🎓 TP Recommandés

### 1. **TP1 (⭐):** Premier Dockerfile
   - Durée: 45 min
   - Créer une image Python simple
   - Voir: TP/TP1-basique.md

### 2. **TP2 (⭐⭐):** Multistage & Optimisation
   - Durée: 1h
   - Comparer tailles simples vs multistage
   - Voir: TP/TP2-multistage.md

### 3. **TP3 (⭐⭐⭐):** Production-Ready
   - Durée: 1.5h
   - Sécurité, health checks, logging
   - Voir: TP/TP3-production.md

## 💡 Concepts Clés

### Layers et Caching
```dockerfile
# ❌ Mauvais: Change le layer cache à chaque modification
FROM ubuntu:latest
RUN apt-get install -y python3
COPY . /app              # COPY peut changer souvent
WORKDIR /app
RUN pip install -r requirements.txt

# ✅ Bon: Stable layers en premier
FROM ubuntu:latest
RUN apt-get install -y python3
COPY requirements.txt /app/
WORKDIR /app
RUN pip install -r requirements.txt
COPY . .                 # Code changé souvent à la fin
```

### Multistage Build
```dockerfile
# Stage 1: Build
FROM node:16 AS builder
COPY . .
RUN npm install && npm run build

# Stage 2: Runtime (plus léger)
FROM node:16-alpine
COPY --from=builder /app/dist .
CMD ["node", "app.js"]
```

### USER Non-Root (Sécurité)
```dockerfile
# ❌ Dangereux: Tourne en root
FROM ubuntu:latest
RUN apt-get update && apt-get install -y python3
CMD ["python3", "app.py"]

# ✅ Sécurisé: Tourne en utilisateur normal
FROM ubuntu:latest
RUN apt-get update && apt-get install -y python3
RUN useradd -m appuser
USER appuser
CMD ["python3", "app.py"]
```

## 🔗 Lire Aussi

- [TP_CORRIGES_ET_AVANCES.md](../TP_CORRIGES_ET_AVANCES.md) - Tous les TP avec solutions
- [STRUCTURE.md](../STRUCTURE.md) - Comment ce module se connecte au reste
- [PLAN_AMELIORATIONS.md](../PLAN_AMELIORATIONS.md) - Bonnes pratiques avancées

## 📚 Ressources Externes

- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [Best Practices for Writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Security](https://docs.docker.com/engine/security/)

## ✅ Progression Pédagogique

```
⭐ Basique (Semaine 1)
  ├─ Concepts: FROM, COPY, RUN, CMD
  ├─ Creer image simple
  └─ Lancer conteneur

⭐⭐ Intermédiaire (Semaine 2)
  ├─ Concepts: Layers, caching
  ├─ Multistage builds
  └─ Optimiser taille

⭐⭐⭐ Avancé (Semaine 3)
  ├─ Concepts: Sécurité, USER
  ├─ Health checks
  ├─ Labels & metadata
  └─ Production patterns
```

## 🆘 Troubleshooting

| Problème | Solution |
|----------|----------|
| "image not found" | Vérifier tag: `docker images` |
| "permission denied" | Utiliser USER non-root |
| "image too large" | Utiliser multistage build |
| "slow builds" | Vérifier layer caching ordre |

---

**Prêt à créer vos images?** 🚀

Commencez par `TP/TP1-basique.md` →
