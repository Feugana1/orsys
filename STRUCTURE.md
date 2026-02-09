# 📂 STRUCTURE - Guide Détaillé de l'Organisation

Bienvenue! Ce document explique **la structure exacte du projet** et comment naviguer.

---

## 🎯 Objectif de ce Document

- Comprendre **où se trouve chaque concept**
- Savoir **par où commencer** selon votre niveau
- **Connecter les concepts** entre les dossiers
- Trouver **rapidement** ce que vous cherchez

---

## 🏗️ Vue Générale

```
Le projet est organisé en 8 modules pédagogiques:

Niveau:   ⭐ Basique    ⭐⭐ Intermédiaire    ⭐⭐⭐ Avancé

📁 dockerfile/             ⭐ → ⭐⭐⭐  (Créer des images)
📁 docker-compose/         ⭐⭐      (Composer des services)
📁 traefik/                ⭐⭐      (Reverse proxy)
📁 swarm/                  ⭐⭐⭐     (Orchestration)
📁 portainer/              ⭐        (Interface)
📁 supervisor/             ⭐⭐      (Multi-processus)
📁 automatisation-build/   ⭐⭐⭐     (Production)
📁 jenkins/                ⭐⭐⭐     (CI/CD)
```

---

## 📁 Module 1: dockerfile/ - Les Briques de Base

**Objectif:** Apprendre à créer des images Docker

**Niveau:** ⭐ Débutant à ⭐⭐⭐ Avancé

### 📄 Fichiers

```
dockerfile/
├── README.md              ← Lire en premier
├── python/
│   ├── Dockerfile         ⭐ Image Python simple
│   ├── Dockerfile.Multistage ⭐⭐ Optimisée
│   ├── .dockerignore      (À créer)
│   ├── requirements.txt    Dépendances Python
│   └── server.py          (non présent, à créer)
└── java/
    ├── README.md
    ├── Dockerfile         ⭐⭐ Image Java (Red Hat UBI)
    └── target/*.jar       (à créer avec Maven)
```

### 🎯 Chemins d'Apprentissage

#### Pour Débutant (1-2h)

1. **Lire** `dockerfile/python/Dockerfile` en entier
   ```bash
   cat dockerfile/python/Dockerfile
   ```

2. **Comprendre chaque ligne:**
   - Ligne 1-2: Quelle image de base? Pourquoi python:3.9-slim?
   - Ligne 5-9: Variables d'environnement et pourquoi
   - Ligne 15-17: Dépendances système (apt-get)
   - Ligne 20-21: Installation des dépendances Python
   - Ligne 27-28: Utilisateur non-root (IMPORTANT!)

3. **Concepts clés:**
   ```
   - Couches Docker (chaque RUN = 1 couche)
   - COPY (copier des fichiers de l'hôte)
   - WORKDIR (répertoire courant)
   - USER (sécurité: ne pas tourner en root)
   - EXPOSE (port virtuel, pas de mapping)
   - CMD (commande par défaut)
   ```

4. **Essayer:**
   ```bash
   cd dockerfile/python

   # Créer l'image
   docker build -t my-python-app:1.0 .

   # Lancer
   docker run -it -p 8080:8080 my-python-app:1.0
   ```

#### Pour Intermédiaire (2-4h)

1. **Comparer les deux approches:**
   ```bash
   cd dockerfile/python

   # Taille de l'image simple
   docker build -t app:simple -f Dockerfile .
   docker images app:simple

   # Taille de l'image multistage
   docker build -t app:multi -f Dockerfile.Multistage .
   docker images app:multi
   ```

2. **Concepts découverts:**
   - Multistage build: Réduire la taille (800MB → 200MB typiquement)
   - Séparer build et runtime
   - `--from=stage` pour copier entre stages

3. **À modifier (TP):**
   - Ajouter une dépendance dans requirements.txt
   - Rebuild et voir la différence
   - Essayer d'ajouter un USER dans Dockerfile.Multistage

#### Pour Avancé (4-6h)

1. **Patterns avancés:**
   - Utiliser des ARG pour les versions
   - Utiliser des secrets (Docker secrets)
   - Utiliser des HEALTHCHECK
   - Utiliser des images distroless

2. **Exercices:**
   - Créer une image distroless Python
   - Ajouter une scan de sécurité (Trivy)
   - Optimiser pour la production (non-root, labels, health)

### 📝 Exercices Progressifs

**Exo 1 (⭐):** Créer votre première image
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl
WORKDIR /app
COPY . .
CMD ["bash"]
```

**Exo 2 (⭐⭐):** Multistage avec Python
- Créer une image avec dependencies
- Copier dans une image runtime slim
- Réduire la taille

**Exo 3 (⭐⭐⭐):** Image production-grade
- Ajouter un USER non-root
- Ajouter des LABEL
- Ajouter un HEALTHCHECK
- Ajouter une scan Trivy

---

## 📁 Module 2: docker-compose/ - L'Orchestration Multi-Service

**Objectif:** Lancer plusieurs conteneurs ensemble

**Niveau:** ⭐⭐ Intermédiaire

### 📄 Fichiers

```
docker-compose/
├── README.md
├── .env.example           ← Copier en .env
├── docker-compose.yml     ⭐ WordPress + MySQL
├── docker-compose-env.yml ⭐⭐ Même stack mais avec variables
├── docker-compose-phpmyAdmin.yml ⭐⭐ 3 services
└── .dockerignore          (À créer)
```

### 🎯 Apprentissage

#### Version Basique (docker-compose.yml)

**Conteneurs:**
- `db`: MySQL 8.0
- `wordpress`: WordPress Apache

**Concepts:**
```yaml
services:        # Les conteneurs à lancer
  db:            # Nom du service
    image:       # Quelle image utiliser
    volumes:     # Stocker les données (persistance)
    restart:     # Redémarrer automatiquement
    environment: # Variables d'environnement
    expose:      # Ports internes au réseau

volumes:         # Définir les volumes nommés
```

**Démarrer:**
```bash
cd docker-compose
docker-compose up -d
```

**Réseau automatique:**
- WordPress peut accéder MySQL via `hostname db`
- Pas besoin de mapper les ports de MySQL
- WordPress est accessible sur `http://localhost`

#### Version Avancée (docker-compose-env.yml)

**Différence:**
```yaml
# ❌ Version basique (hardcoded)
environment:
  - MYSQL_PASSWORD=wordpress

# ✅ Version avancée (variables)
environment:
  - MYSQL_PASSWORD=${MYSQL_PASSWORD}
```

**Utilisation:**
```bash
# Dupliquer le template
cp .env.example .env

# Modifier les valeurs
# Lancer avec les variables
docker-compose up -d

# Les variables viennent de .env automatiquement
```

#### Version avec 3 Services (docker-compose-phpmyAdmin.yml)

**Services:**
1. `db`: MySQL
2. `wordpress`: Application web
3. `phpmyadmin`: Interface d'administration MySQL

**Points d'apprentissage:**
- Lancer 3 services
- Gérer les dépendances (WordPress attend MySQL)
- Ajouter un nouvel outil (phpmyAdmin)

### 📝 Exercices

**Exo 1 (⭐⭐):** Modifier et relancer
```bash
cd docker-compose

# Changer le port de WordPress
# Éditer docker-compose.yml:
# ports:
#   - 8080:80  (au lieu de 80:80)

docker-compose up -d
# Accéder à http://localhost:8080
```

**Exo 2 (⭐⭐):** Ajouter un service
```yaml
# Ajouter à docker-compose.yml:
phpmyadmin:
  image: phpmyadmin:latest
  ports:
    - 8081:80
  environment:
    PMA_HOST: db
    PMA_USER: root
    PMA_PASSWORD: ${MYSQL_ROOT_PASSWORD}
```

**Exo 3 (⭐⭐⭐):** Créer votre stack perso
- Créer `docker-compose-myapp.yml`
- Lancer votre app Python + Redis + MySQL
- Documenter

---

## 📁 Module 3: traefik/ - Le Reverse Proxy

**Objectif:** Routage HTTP/HTTPS intelligent

**Niveau:** ⭐⭐ Intermédiaire

### 📄 Fichiers

```
traefik/
├── README.md
├── docker-compose.yml   ⭐ Traefik + exemple simple
├── wp/
│   ├── docker-compose.yml ⭐⭐ WordPress derrière Traefik
│   ├── traefik/
│   │   └── config.yml   Configuration Traefik
│   └── wordpress/
│       └── docker-compose.yml
└── .dockerignore        (À créer)
```

### 🎯 Apprentissage

#### Traefik Simple (docker-compose.yml)

**À comprendre:**
```yaml
traefik:
  image: traefik:v2.11
  command:
    - "--api.insecure=true"  # Dashboard sans password (pour dev!)
    - "--providers.docker=true"  # Lire les labels Docker
    - "--entrypoints.web.address=:80"  # Écouter le port 80

  whoami:
    labels:
      - "traefik.enable=true"  # Enregistrer ce service
      - "traefik.http.routers.whoami.rule=Host(`whoami.localhost`)"
      # Si vous accédez whoami.localhost → routé vers ce conteneur
```

**Démarrer:**
```bash
cd traefik
docker-compose up -d

# Accéder au dashboard
http://localhost:8080

# Accéder à whoami
http://whoami.localhost

# (Ajouter à /etc/hosts sur Mac/Linux:)
# 127.0.0.1 whoami.localhost
```

#### Traefik Avancé (wp/)

**Stack complet:**
- Traefik
- MySQL
- WordPress

**Points d'apprentissage:**
- WordPress accessible via `wp.localhost` (pas port 80)
- Traefik route automatiquement
- Configuration séparée du routing

### 📝 Exercices

**Exo 1 (⭐⭐):** Ajouter un service
```yaml
whoami2:
  image: traefik/whoami
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.whoami2.rule=Host(`whoami2.localhost`)"
    - "traefik.http.services.whoami2.loadbalancer.server.port=80"
```

**Exo 2 (⭐⭐⭐):** Ajouter WordPress
- Lancer WordPress derrière Traefik
- Accéder via un domaine perso

---

## 📁 Module 4: swarm/ - L'Orchestration Distribuée

**Objectif:** Déployer sur plusieurs machines

**Niveau:** ⭐⭐⭐ Avancé

### 📄 Fichiers

```
swarm/
├── README.md
├── swarm-team.md          Concepts Swarm expliqués
├── nginx.yml              ⭐⭐⭐ Nginx répliqué sur plusieurs nœuds
├── nginx-constrainst.yml  ⭐⭐⭐ Avec placement constraints
└── .dockerignore          (À créer)
```

### 🎯 Apprentissage

#### Concepts Clés

**Docker Swarm = Kubernetes simplifié**
- Mode de gestion distribuée
- Réplication automatique
- Load balancing
- Self-healing (redémarrage auto)

#### Nginx Répliqué (nginx.yml)

**À comprendre:**
```yaml
services:
  nginx:
    image: nginx:latest
    deploy:
      replicas: 3  # Lancer 3 copies
      update_config:
        parallelism: 1  # Updater 1 à la fois
```

**Utilisation:**
```bash
# Initialiser Swarm (une fois)
docker swarm init

# Déployer le stack
docker stack deploy -c nginx.yml myapp

# Voir les services
docker service ls
docker service ps myapp_nginx

# Scaler (augmenter les replicas)
docker service scale myapp_nginx=5
```

#### Avec Placement (nginx-constrainst.yml)

**À comprendre:**
```yaml
deploy:
  replicas: 3
  placement:
    constraints:
      - node.hostname == manager
      # Ou d'autres constraints
```

### 📝 Exercices

**Exo 1 (⭐⭐⭐):** Déployer Nginx
```bash
docker swarm init
docker stack deploy -c nginx.yml web
docker service ls
docker service ps web_nginx

# Accéder à http://localhost:80
# Chaque refresh = serveur différent (load balancing)
```

**Exo 2 (⭐⭐⭐):** Ajouter des nœuds (simulation)
```bash
# Sur une vraie infrastructure avec 3 machines:
docker swarm init  # Sur machine 1 (manager)
docker swarm join  # Sur machine 2, 3 (workers)

# Voir les nœuds
docker node ls
```

---

## 📁 Module 5: portainer/ - L'Interface

**Objectif:** Gérer Docker avec une UI

**Niveau:** ⭐ Basique

### 📄 Fichiers

```
portainer/
├── README.md
├── docker-compose.yml  ⭐ Interface Portainer
└── .dockerignore       (À créer)
```

### 🎯 Apprentissage

**Très simple:**
```bash
cd portainer
docker-compose up -d

# Accéder à http://localhost:9000
# Créer un compte admin
# Explorer les conteneurs, images, volumes, networks
```

**À explorer:**
- Voir les logs en direct
- Créer des conteneurs
- Gérer les images
- Voir les stats

---

## 📁 Module 6: supervisor/ - Multi-processus

**Objectif:** Gérer plusieurs services dans 1 conteneur

**Niveau:** ⭐⭐ Intermédiaire

### 📄 Fichiers

```
supervisor/
├── Dockerfile            Services SSH + Apache2
├── supervisord.conf      Configuration des services
└── README.md
```

### 🎯 Apprentissage

**Concept:** 1 conteneur = 1 processus ❌

Pour certains cas (supervision legacy), lancer plusieurs:
- SSH
- Apache2
- Autres services

**supervisord.conf:**
```ini
[program:sshd]
command=/usr/sbin/sshd -D

[program:apache2]
command=bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"
```

**À noter:** Pattern moins recommandé aujourd'hui (préférer microservices)

---

## 📁 Module 7: automatisation-build/ - Production-Ready

**Objectif:** Image production avec venv

**Niveau:** ⭐⭐⭐ Avancé

### 📄 Fichiers

```
automatisation-build/
├── Dockerfile           Multistage + venv production
├── requirements.txt
└── README.md
```

### 🎯 Apprentissage

**Pattern avancé:**
```dockerfile
# Stage 1: Build
FROM ubuntu:20.04 AS builder-image
RUN python3.9 -m venv /home/myuser/venv
COPY requirements.txt .
RUN /home/myuser/venv/bin/pip install -r requirements.txt

# Stage 2: Runtime
FROM ubuntu:20.04 AS runner-image
COPY --from=builder-image /home/myuser/venv /home/myuser/venv
COPY . .
USER myuser
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
```

**Avantages:**
- Image runtime petite (sans build-tools)
- Venv isolé (pas de conflit Python)
- Non-root
- Production-grade

---

## 📁 Module 8: jenkins/ (À explorer)

**Objectif:** CI/CD intégration

**Niveau:** ⭐⭐⭐ Avancé

*À documenter davantage*

---

## 🔗 Comment les Modules se Connectent

```
dockerfile/
  ├─→ Crée l'image Python
      └─→ Utilisée par docker-compose/
          ├─→ Lance WordPress
          │   └─→ Routée par traefik/
          │       └─→ Accessible via un domaine
          │
          └─→ Images réutilisables
              └─→ Déployées dans swarm/
                  └─→ Gérées via portainer/

supervisor/
  └─→ Cas spécial: Multi-processus dans 1 conteneur
      (éviter si possible, préférer microservices)

automatisation-build/
  └─→ Pattern production: Multistage + venv
      (réutilisable pour vos propres apps)
```

---

## 📊 Matrice d'Apprentissage

### Par Concept

| Concept | Niveau | Dossier | Fichier |
|---------|--------|---------|---------|
| Image de base | ⭐ | dockerfile | Dockerfile |
| Multistage | ⭐⭐ | dockerfile | Dockerfile.Multistage |
| Compose simple | ⭐⭐ | docker-compose | docker-compose.yml |
| Variables d'env | ⭐⭐ | docker-compose | docker-compose-env.yml |
| Reverse proxy | ⭐⭐ | traefik | docker-compose.yml |
| Swarm | ⭐⭐⭐ | swarm | nginx.yml |
| Constraints | ⭐⭐⭐ | swarm | nginx-constrainst.yml |
| Production | ⭐⭐⭐ | automatisation-build | Dockerfile |

### Par Durée

| Durée | Niveau | À faire |
|-------|--------|---------|
| 15min | ⭐ | Lancer Portainer |
| 30min | ⭐ | Lancer WordPress (compose) |
| 1h | ⭐ | Lire et comprendre Dockerfile |
| 2h | ⭐⭐ | Créer un Dockerfile perso |
| 3h | ⭐⭐ | Créer un docker-compose perso |
| 4h | ⭐⭐⭐ | Déployer en Swarm |
| 6h | ⭐⭐⭐ | Créer une image production |

---

## 🎯 Questions Fréquentes

### "Je veux lancer WordPress"
→ `docker-compose/`

### "Je veux créer une image"
→ `dockerfile/`

### "Je veux lancer plusieurs services"
→ `docker-compose/`

### "Je veux l'accéder via un domaine"
→ `traefik/`

### "Je veux déployer sur plusieurs machines"
→ `swarm/`

### "Je veux une UI pour gérer"
→ `portainer/`

### "Je veux optimiser les images"
→ `dockerfile/Dockerfile.Multistage` et `automatisation-build/`

---

## 🚀 Flux d'Apprentissage Recommandé

```
JOUR 1:
  ⭐ Lancer WordPress (15min)
     └→ docker-compose/docker-compose.yml

  ⭐ Lire premier Dockerfile (30min)
     └→ dockerfile/python/Dockerfile

  ⭐⭐ Créer votre propre image (1h)
     └→ Dockerfile personnel

JOUR 2:
  ⭐⭐ Comprendre docker-compose (1h)
     └→ docker-compose/docker-compose-env.yml

  ⭐⭐ Ajouter des services (1h)
     └→ Votre propre docker-compose.yml

JOUR 3:
  ⭐⭐ Traefik reverse proxy (1h30)
     └→ traefik/docker-compose.yml

  ⭐⭐⭐ Multistage build (1h)
     └→ dockerfile/python/Dockerfile.Multistage

JOUR 4:
  ⭐⭐⭐ Docker Swarm (2h)
     └→ swarm/nginx.yml

  ⭐⭐⭐ Production-ready (1h)
     └→ automatisation-build/Dockerfile
```

---

<div align="center">

**Bon voyage dans Docker! 🐳**

Prochaine étape → Choisir votre chemin dans README.md

</div>

