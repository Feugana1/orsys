# 🐳 Docker Learning Path - ORSYS

Une **collection pédagogique complète** pour maîtriser Docker, Docker Compose, Swarm, et les technologies associées. Du débutant à l'expert.

![Docker](https://img.shields.io/badge/Docker-24.0+-2CA5E0?logo=docker&logoColor=white)
![Compose](https://img.shields.io/badge/Compose-2.20+-9D53B1?logo=docker&logoColor=white)
![Status](https://img.shields.io/badge/Status-En%20Am%C3%A9lioration-yellow)

---

## 📚 À Propos de ce Projet

Ce projet regroupe **10+ exemples progressifs** pour apprendre Docker:
- ✅ Dockerfiles simples à avancés
- ✅ Docker Compose multi-service
- ✅ Orchestration avec Swarm
- ✅ Reverse proxy avec Traefik
- ✅ Gestion avec Portainer
- ✅ Supervision avec Supervisor
- ✅ CI/CD et build automation

**Chaque exemple est conçu pour être:**
- 📖 Pédagogique (commenté en détail)
- 🚀 Fonctionnel (testable immédiatement)
- 📈 Progressif (⭐ → ⭐⭐⭐)
- 🔒 Sécurisé (bonnes pratiques incluses)

---

## 🎯 Public Cible

### ⭐ Débutants
Vous découvrez Docker et cherchez à comprendre les concepts fondamentaux.
- **Commencez par:** `dockerfile/python/Dockerfile`
- **Temps:** 1-2 heures
- **Concepts:** Couches, COPY, RUN, USER

### ⭐⭐ Intermédiaires
Vous avez compris les bases et construisez des applications réelles.
- **Commencez par:** `docker-compose/docker-compose.yml`
- **Temps:** 2-4 heures
- **Concepts:** Multi-services, volumes, networks, env variables

### ⭐⭐⭐ Avancés
Vous optimisez pour la production et explorez les cas complexes.
- **Commencez par:** `swarm/nginx.yml`
- **Temps:** 4-8 heures
- **Concepts:** Orchestration, scheduling, TLS, performance

---

## 📂 Structure du Projet

```
orsys/
├── README.md                   ← Vous êtes ici!
├── AUDIT_DOCKER.md            ← Diagnostique du projet
├── PLAN_AMELIORATIONS.md       ← Améliorations en cours
├── STRUCTURE.md               ← Guide détaillé de navigation
├── .gitignore                 ← Ne pas committer les secrets
├── .dockerignore              ← Template pour images slim
│
├── 📁 dockerfile/             ← Images Docker de base (⭐ → ⭐⭐⭐)
│   ├── README.md              ← Guide dockerfile/
│   ├── python/
│   │   ├── Dockerfile         ⭐ Simple image Python
│   │   ├── Dockerfile.Multistage ⭐⭐ Optimisée
│   │   ├── requirements.txt
│   │   └── .dockerignore
│   └── java/
│       ├── Dockerfile         ⭐⭐ Image Java Enterprise
│       └── README.md
│
├── 📁 docker-compose/         ← Compose multi-conteneurs (⭐⭐)
│   ├── README.md
│   ├── .env.example           ← Template (copier en .env)
│   ├── docker-compose.yml     ← WordPress + MySQL
│   ├── docker-compose-env.yml ← Version avec variables
│   └── docker-compose-phpmyAdmin.yml ← Avec phpmyAdmin
│
├── 📁 traefik/                ← Reverse proxy (⭐⭐)
│   ├── README.md
│   ├── docker-compose.yml     ← Traefik simple
│   └── wp/                    ← WordPress derrière Traefik
│       ├── docker-compose.yml
│       ├── traefik/
│       └── wordpress/
│
├── 📁 swarm/                  ← Orchestration distribuée (⭐⭐⭐)
│   ├── README.md
│   ├── nginx.yml              ← Nginx répliqué
│   ├── nginx-constrainst.yml  ← Avec placement
│   └── swarm-team.md          ← Documentation Swarm
│
├── 📁 portainer/              ← Interface de gestion (⭐)
│   ├── README.md
│   └── docker-compose.yml     ← Portainer CE
│
├── 📁 supervisor/             ← Gestion de processus (⭐⭐)
│   ├── Dockerfile
│   ├── supervisord.conf
│   └── README.md
│
└── 📁 automatisation-build/   ← Build automation (⭐⭐⭐)
    ├── Dockerfile            ← Production-grade
    ├── requirements.txt
    └── README.md
```

---

## 🚀 Démarrage Rapide

### Prérequis

```bash
# Vérifier que Docker est installé
docker --version   # >= 24.0 recommandé
docker-compose --version  # >= 2.20

# Vérifier que le daemon tourne
docker ps
```

### Votre Premier Exemple (5 minutes)

#### 1️⃣ Lancer WordPress localement

```bash
cd docker-compose

# Dupliquer le template .env
cp .env.example .env

# Démarrer les services
docker-compose up -d

# Attendre ~30 secondes (initialisation MySQL)
sleep 30

# Vérifier l'état
docker-compose ps
```

#### 2️⃣ Accéder à l'application

```
http://localhost
```

Vous voyez l'install wizard de WordPress! ✅

#### 3️⃣ Arrêter

```bash
docker-compose down
# Les données restent (volume persistant)
# Pour tout supprimer:
# docker-compose down -v
```

---

## 📖 Chemins d'Apprentissage

### 🟢 Chemin Débutant (Comprendre les bases)

**Objectif:** Savoir créer et lancer une image Docker

```bash
# 1. Lire le Dockerfile commenté
cd dockerfile/python
cat Dockerfile  # Lire ligne par ligne
cat README.md   # Explications

# 2. Créer l'image
docker build -t my-python-app .

# 3. La lancer
docker run -it -p 8080:8080 my-python-app

# 4. Accéder à http://localhost:8080
```

**Durée:** 1-2 heures
**Concepts:** Couches, COPY, RUN, USER, EXPOSE, CMD

---

### 🟡 Chemin Intermédiaire (Construire une application)

**Objectif:** Composer plusieurs services ensemble

```bash
# 1. Étudier la structure
cd docker-compose
cat README.md
cat docker-compose.yml

# 2. Comparer avec la version multistage
cd ../dockerfile/python
diff Dockerfile Dockerfile.Multistage

# 3. Apprendre Traefik
cd ../../traefik
docker-compose up -d
# Accéder à http://whoami.localhost

# 4. Gérer avec Portainer
cd ../portainer
docker-compose up -d
# Accéder à http://localhost:9000
```

**Durée:** 2-4 heures
**Concepts:** Multistage, networks, volumes, reverse proxy, variables d'env

---

### 🔴 Chemin Avancé (Optimiser et orchestrer)

**Objectif:** Production-ready et scalabilité

```bash
# 1. Étudier l'automatisation
cd automatisation-build
cat Dockerfile  # Patterns avancés
cat README.md

# 2. Initier un Swarm
docker swarm init

# 3. Déployer un stack
cd ../swarm
docker stack deploy -c nginx.yml mystack

# 4. Explorer les constraints
cat nginx-constrainst.yml
```

**Durée:** 4-8 heures
**Concepts:** Venv production, Swarm, scheduling, constraints, secrets

---

## 🔒 Important: Sécurité

### ⚠️ Les Secrets

Ce projet est **PÉDAGOGIQUE**. Les patterns de sécurité montrés sont pour l'apprentissage.

```bash
# ❌ NE JAMAIS faire ceci en production:
export MYSQL_PASSWORD=wordpress

# ✅ En production réelle, utiliser:
# - AWS Secrets Manager
# - HashiCorp Vault
# - Azure Key Vault
# - Kubernetes Secrets
```

### 📋 Checklist Sécurité

- [ ] Jamais committer `.env` (voir `.gitignore`)
- [ ] Copier `.env.example` en `.env` pour commencer
- [ ] Changer les mots de passe par défaut
- [ ] Utiliser des images de registres fiables
- [ ] Lire AUDIT_DOCKER.md pour les détails

---

## 📚 Documentation Additionnelle

| Document | Objectif |
|----------|----------|
| **AUDIT_DOCKER.md** | Diagnostique détaillé du projet |
| **PLAN_AMELIORATIONS.md** | Améliorations en cours |
| **STRUCTURE.md** | Guide détaillé de chaque dossier |
| **dockerfile/README.md** | Guide des Dockerfiles |
| **docker-compose/README.md** | Guide de Compose |
| **traefik/README.md** | Guide de Traefik |
| **swarm/README.md** | Guide de Swarm |

---

## 💡 Tips & Tricks

### Voir les logs d'un service

```bash
docker-compose logs -f wordpress
```

### Exécuter une commande dans un conteneur

```bash
docker-compose exec db mysql -u root -p wordpress
```

### Reconstruire une image

```bash
docker-compose up -d --build
```

### Voir l'utilisation ressources

```bash
docker stats
```

### Nettoyer les ressources inutilisées

```bash
# Images non utilisées
docker image prune -a

# Volumes non utilisés
docker volume prune

# Tout (attention!)
docker system prune -a --volumes
```

---

## 🤝 Contribution

Avant de modifier ce projet, **lire obligatoirement:**
1. `AUDIT_DOCKER.md` - Les problèmes identifiés
2. `PLAN_AMELIORATIONS.md` - L'approche d'amélioration
3. Ne pas dénaturer les exemples pédagogiques

**Règles simples:**
- ✅ Enrichir (ajouter, documenter, corriger)
- ❌ Ne pas refactoriser massivement
- ❌ Ne pas supprimer d'exemples
- ❌ Ne pas committer de secrets

---

## 📞 Support

- Chaque dossier a son propre **README.md** spécifique
- La structure est expliquée dans **STRUCTURE.md**
- Les problèmes identifiés sont dans **AUDIT_DOCKER.md**
- Les solutions sont dans **PLAN_AMELIORATIONS.md**

---

## 📄 Licence

Ce projet est fourni à titre pédagogique.

---

## 🎓 Pour les Formateurs

### Comment utiliser ce projet en cours?

1. **Démonstration live:**
   ```bash
   # Démarrer devant les apprenants
   docker-compose up -d
   # Montrer les services, les logs, les volumes
   ```

2. **TP guidé:**
   - Étape 1: Lire le Dockerfile
   - Étape 2: Le modifier (changer version, ports)
   - Étape 3: Rebuilder et tester

3. **TP libre:**
   - Donner une tâche (ex: "Ajouter phpmyAdmin")
   - Laisser les apprenants explorer et résoudre

4. **Évaluation:**
   - Créer un Dockerfile partir de zéro
   - Composer plusieurs services
   - Déployer en Swarm

---

<div align="center">

**Bon apprentissage Docker! 🐳**

Fait avec ❤️ pour l'apprentissage

</div>

