# TP2: Multistage Build - Optimiser les Images

**Niveau:** ⭐⭐ Intermédiaire
**Durée:** 1 heure
**Objectif:** Comprendre et implémenter les builds multistage

---

## 📚 Concepts Couverts

- Stages dans Dockerfile
- `AS` - Nommer un stage
- `COPY --from` - Copier depuis un autre stage
- Réduction drastique de taille d'image
- Layer caching et build speed

---

## 🎯 Exercice 1: Analyser un Multistage Dockerfile

### Étape 1: Examiner le fichier

```bash
cd dockerfile/python
cat Dockerfile.Multistage
```

### Questions:
1. Combien de stages y a-t-il?
2. Quel est le nom de chaque stage?
3. Qu'est-ce qui est copié du premier stage au second?
4. Pourquoi cette approche?

**Réponses attendues:**
- 2 stages: `builder` et `runtime`
- Stage 1 (builder): Installe les dépendances
- Stage 2 (runtime): Copie uniquement ce qui est nécessaire
- Raison: Réduire l'image finale (sans les outils de build)

---

## 📊 Exercice 2: Comparer Tailles Simple vs Multistage

### Builder les deux versions

```bash
cd dockerfile/python

# Version simple
docker build -f Dockerfile -t python-simple:1.0 .

# Version multistage
docker build -f Dockerfile.Multistage -t python-multistage:1.0 .
```

### Comparer les tailles

```bash
docker images | grep -E "python-simple|python-multistage"
```

**Résultat attendu:**
```
REPOSITORY           TAG      SIZE
python-simple        1.0      ~400MB
python-multistage    1.0      ~150MB
```

### Questions:
1. Quelle est la réduction de taille (en %)?
2. Qu'est-ce qui rend l'image simple si grosse?
3. Comment le multistage réduit la taille?

**Analyse:**
- Simple: Image complète Python + compilateur + outils de build
- Multistage: Copie seulement le venv du stage de build, pas les outils

---

## 🔍 Exercice 3: Inspecter les Stages

### Voir la construction du multistage

```bash
docker history python-multistage:1.0
```

### Voir les layers du simple

```bash
docker history python-simple:1.0
```

### Questions:
1. Combien de layers pour chaque?
2. Lequel a plus de layers inutiles?
3. Quelle est la taille du layer "pip install" dans chaque?

**Observations:**
- Multistage: Fewer layers in final image
- Simple: Toutes les dépendances de build sont dans l'image finale

---

## 🏗️ Exercice 4: Construire Votre Propre Multistage

### Créer un projet Node.js multistage

```bash
mkdir -p my-node-app
cd my-node-app

# Créer un package.json simple
cat > package.json << 'EOF'
{
  "name": "my-app",
  "version": "1.0.0",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# Créer l'app
cat > app.js << 'EOF'
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello from Node!');
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
EOF

# Créer un Dockerfile multistage
cat > Dockerfile << 'EOF'
# Stage 1: Builder
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Runtime (beaucoup plus léger)
FROM node:18-alpine

WORKDIR /app

# Copier node_modules du stage builder
COPY --from=builder /app/node_modules ./node_modules

# Copier le code source
COPY app.js .

# Créer user non-root
RUN addgroup -g 1001 nodejs && \
    adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000

CMD ["node", "app.js"]
EOF
```

### Builder et tester

```bash
# Builder
docker build -t my-node:simple .

# Voir la taille
docker images | grep my-node

# Tester
docker run -p 3000:3000 my-node:simple
# Dans un autre terminal: curl http://localhost:3000
```

---

## ⚡ Exercice 5: Comparaison Build Speed

### Tester le caching

```bash
cd dockerfile/python

# Premier build (pas de cache)
time docker build -f Dockerfile.Multistage -t python-multistage:v1 .

# Deuxième build (avec cache)
time docker build -f Dockerfile.Multistage -t python-multistage:v2 .

# Modifier le code et rebuilder
echo "# Comment" >> requirements.txt

# Rebuilder (cache jusqu'à requirements.txt change)
time docker build -f Dockerfile.Multistage -t python-multistage:v3 .
```

### Observations:
1. Le 2e build est plus rapide (cache)
2. Le 3e build invalide le cache au moment de "requirements.txt"
3. Tout après ce point doit être rebuilt

---

## 🆚 Exercice 6: Anti-Pattern - Pourquoi PAS Multistage?

### Cas où multistage n'est PAS utile:

```bash
# Image déjà petite (alpine)
FROM alpine:latest
RUN apk add --no-cache python3
COPY app.py .
CMD ["python3", "app.py"]

# Ici, multistage n'ajoute rien car alpine est déjà minimalist
```

### Cas où multistage EST critique:

```bash
# Compilé (Go, Rust)
FROM golang:1.20 AS builder
COPY . .
RUN go build -o myapp .

FROM alpine:latest
COPY --from=builder /go/myapp .
# Image: 10MB au lieu de 1GB+
```

---

## 🔒 Exercice 7: Sécurité dans Multistage

### Vérifier la structure de sécurité

```bash
docker run --rm python-multistage:1.0 whoami
docker run --rm python-multistage:1.0 id
```

**Points:**
- USER non-root préservé
- Pas d'outils de build dans l'image finale
- Moins de surface d'attaque

---

## 📈 Exercice 8: Progression - 3 Stages

Créer un Dockerfile avec 3 stages:

```dockerfile
# Stage 1: Downloader les dépendances
FROM python:3.9-slim AS downloader
WORKDIR /tmp
RUN pip download -d . numpy scipy

# Stage 2: Builder
FROM python:3.9-slim AS builder
COPY --from=downloader /tmp .
RUN pip install --no-index --find-links . numpy scipy

# Stage 3: Runtime (minimal)
FROM python:3.9-alpine
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY app.py .
CMD ["python", "app.py"]
```

---

## ✅ Validation - Checklist

- [ ] Image simple construite: ~400MB
- [ ] Image multistage construite: ~150MB
- [ ] Réduction >= 60%
- [ ] Docker history montre moins de layers dans multistage
- [ ] Test Node.js multistage fonctionne
- [ ] USER non-root dans l'image finale
- [ ] Caching fonctionne (2e build plus rapide)

---

## 🎓 Points Clés à Retenir

1. **Multistage = Architecture Layerée**
   - Builder stage: Installe tout ce qui est nécessaire pour build
   - Runtime stage: Copie seulement les artifacts

2. **Réduction de Taille**
   - Compilateurs, outils de build = pas dans l'image finale
   - Dépendances système réduites = images plus petites

3. **Quand l'utiliser**
   - Langages compilés (Go, Rust, Java)
   - Dépendances de build volumineuses (npm, pip)
   - Applications nécessitant des outils de compilation

4. **Quand c'est overkill**
   - Images alpine très petites
   - Single-stage déjà petit
   - Développement local (Docker Desktop)

---

## 🔗 Prochaine Étape

→ **TP3: Production-Ready** - Sécurité, monitoring, health checks

## 💡 Tips & Tricks

```bash
# Voir exactement ce qui se passe
docker build --progress=plain -f Dockerfile.Multistage .

# Construire uniquement jusqu'à un stage
docker build --target=builder -t myapp:builder .

# Analyser l'image finale
docker run --rm myimage:1.0 ls -la /

# Trouver les fichiers volumineux
docker run --rm myimage:1.0 du -sh /usr/local/lib/*
```

---

**Fin TP2** ✅
