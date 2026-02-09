# TP1: Premier Dockerfile - Basique

**Niveau:** ⭐ Débutant
**Durée:** 45 minutes
**Objectif:** Créer et comprendre un Dockerfile simple

---

## 📚 Concepts Couverts

- `FROM` - Choisir une image de base
- `WORKDIR` - Définir le répertoire de travail
- `COPY` - Copier des fichiers
- `RUN` - Exécuter des commandes
- `CMD` - Commande de démarrage
- `EXPOSE` - Documenter les ports

---

## 🎯 Exercice 1: Analyser un Dockerfile Simple

### Étape 1: Examiner le Dockerfile existant

```bash
cd dockerfile/python
cat Dockerfile
```

### Questions:
1. Quelle est l'image de base utilisée?
2. Quel est le répertoire de travail?
3. Quels fichiers sont copiés et pourquoi dans cet ordre?
4. Quel est le USER qui exécute le conteneur?
5. Quel port est exposé?

**Réponses attendues:**
- Image: `python:3.9-slim` (base légère)
- Répertoire: `/app`
- Fichiers: `requirements.txt` en premier (peu change), puis le code (change souvent)
- USER: `appuser` (non-root pour sécurité)
- Port: `8080`

---

## 🔨 Exercice 2: Builder une Image

### Étape 1: Builder l'image

```bash
cd dockerfile/python
docker build -t my-python:1.0 .
```

### Questions:
- Combien de steps (étapes) y a-t-il?
- Quel est le hash de l'image créée?

### Vérifier:

```bash
docker images | grep my-python
docker image inspect my-python:1.0 | head -30
```

---

## ▶️ Exercice 3: Lancer un Conteneur

### Étape 1: Vérifier Python

```bash
docker run --rm my-python:1.0 python --version
docker run --rm my-python:1.0 python -c "import sys; print(sys.version)"
```

### Questions:
- Quelle version de Python?
- Le USER est-il `root` ou `appuser`?

Vérifier:
```bash
docker run --rm my-python:1.0 whoami
```

**Résultat attendu:** `appuser` (non-root)

---

## 📊 Exercice 4: Analyser les Layers

### Voir l'histoire de construction

```bash
docker history my-python:1.0
```

**Questions:**
1. Combien de layers?
2. Quelle est la taille de chaque layer?
3. Quel layer est le plus volumineux?

**Exemple de sortie:**
```
IMAGE          CREATED        CREATED BY                                    SIZE
...
abc123         2 minutes ago  /bin/sh -c useradd -m appuser                 0B
def456         2 minutes ago  /bin/sh -c pip install --no-cache-dir -r...   45MB
...
```

---

## 🆚 Exercice 5: Comparer Avant/Après

### Créer une "mauvaise" image (anti-pattern)

```bash
cat > Dockerfile.bad << 'EOF'
FROM python:3.9          # ❌ Image complète (pas -slim)
WORKDIR /app
COPY . .                 # ❌ Code copié avant requirements
RUN pip install -r requirements.txt
EXPOSE 8080
CMD ["python", "server.py"]
EOF
```

### Builder les deux versions

```bash
docker build -f Dockerfile -t my-python:good .
docker build -f Dockerfile.bad -t my-python:bad .
```

### Comparer les tailles

```bash
docker images | grep my-python
```

**Résultat attendu:**
- `my-python:good` ~200MB
- `my-python:bad` ~900MB+

### Questions:
1. Pourquoi la différence de taille?
2. Quel est le problème avec copier le code en premier?

**Réponses:**
- `-slim` contient moins de packages
- Copier le code en premier = chaque changement invalide le cache pip install

---

## 🔒 Exercice 6: Vérifier la Sécurité

### Vérifier que l'app tourne en non-root

```bash
docker run -it my-python:1.0 /bin/bash
# À l'intérieur du conteneur:
whoami
id
```

**Résultat attendu:**
```
appuser
uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)
```

### Essayer de devenir root (doit échouer)

```bash
su -    # Doit demander un password
# Appuyer Ctrl+D pour quitter
exit
```

---

## 🐍 Exercice 7 (Optionnel): Créer Votre Propre Dockerfile

### Créer une app simple

```bash
mkdir -p my-app
cd my-app

cat > app.py << 'EOF'
#!/usr/bin/env python3
print("Hello from Docker!")
print(f"Running as user: {__import__('os').getuid()}")
EOF

cat > requirements.txt << 'EOF'
# Empty for now
EOF

cat > Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt && \
    useradd -m appuser

COPY . .
USER appuser

EXPOSE 8080
CMD ["python", "app.py"]
EOF
```

### Builder et tester

```bash
docker build -t my-app:1.0 .
docker run --rm my-app:1.0
docker run --rm my-app:1.0 python app.py
```

---

## ✅ Validation - Checklist

- [ ] Image `my-python:1.0` construite sans erreurs
- [ ] `docker run --rm my-python:1.0 python --version` fonctionne
- [ ] `docker run --rm my-python:1.0 whoami` retourne `appuser`
- [ ] `docker history my-python:1.0` montre les layers
- [ ] Comparaison slim vs non-slim : slim est plus petit
- [ ] Non-root user créé et utilisé

---

## 🎓 Points Clés à Retenir

1. **Image de base:** Utiliser `-slim` ou `-alpine` pour réduire la taille
2. **Layer caching:** Copier `requirements.txt` avant le code
3. **Sécurité:** USER non-root toujours!
4. **EXPOSE:** Documente le port, ne l'expose pas vraiment
5. **Ordre des commandes:** Mettez les choses stables en premier

---

## 🔗 Prochaine Étape

→ **TP2: Multistage Build** - Optimiser encore plus les images

## 💡 Tips & Tricks

```bash
# Voir ce qui se passe lors du build
docker build -t myimage:1.0 --progress=plain .

# Construire sans cache (refaire tous les layers)
docker build -t myimage:1.0 --no-cache .

# Voir la structure d'une image
docker inspect myimage:1.0 | jq '.Config'

# Nettoyer les images inutilisées
docker image prune
```

---

**Fin TP1** ✅
