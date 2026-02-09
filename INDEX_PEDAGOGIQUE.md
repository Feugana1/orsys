# 🎓 Index Pédagogique Complet - Support TAMTSE Docker

Bienvenue! Ce fichier vous oriente dans le matériel pédagogique Docker.

---

## 📚 Ordre de Lecture Recommandé

### **Phase 1: Comprendre (1-2 jours)**
```
1. README.md                    ← Point de départ
2. STRUCTURE.md                 ← Organisation du projet
3. TP_CORRIGES_ET_AVANCES.md   ← TP 1-2 (Basique)
```

### **Phase 2: Pratiquer (2-3 jours)**
```
1. TP_CORRIGES_ET_AVANCES.md   ← TP 3-4 (Amélioré)
2. docker-compose/             ← Exemples concrets
3. dockerfile/                  ← Créer vos images
```

### **Phase 3: Maîtriser (3-4 jours)**
```
1. TP_CORRIGES_ET_AVANCES.md   ← TP 5-8 (Avancé)
2. swarm/                       ← Orchestration
3. PLAN_AMELIORATIONS.md        ← Patterns avancés
```

---

## 📖 Fichiers par Objectif

### 🎯 "Je veux comprendre Docker"
```
→ README.md
→ STRUCTURE.md
→ dockerfile/ (lire les Dockerfile avec commentaires)
```

### 🛠️ "Je veux lancer mon premier conteneur"
```
→ TP_CORRIGES_ET_AVANCES.md [TP 1: Premier Conteneur]
→ docker run docker ps
→ Essayer les exemples du support
```

### 🔗 "Je veux connecter plusieurs conteneurs"
```
→ TP_CORRIGES_ET_AVANCES.md [TP 2: Interconnexion TCP]
→ docker-compose/ (voir les exemples)
→ traefik/ (routing avancé)
```

### 💾 "Je veux persister les données"
```
→ TP_CORRIGES_ET_AVANCES.md [TP 3: Volumes]
→ docker-compose/docker-compose.yml
→ Documentation Docker Volumes
```

### 🚀 "Je veux déployer en production"
```
→ TP_CORRIGES_ET_AVANCES.md [TP 5-8: Avancé]
→ PLAN_AMELIORATIONS.md
→ swarm/ (orchestration)
→ traefik/ (reverse proxy)
```

### 🔐 "Je veux sécuriser mes conteneurs"
```
→ AUDIT_DOCKER.md [Section Sécurité]
→ TP_CORRIGES_ET_AVANCES.md [Version Avancée - Secrets]
→ dockerfile/ (USER non-root, healthchecks)
```

---

## 📂 Structure du Projet

```
orsys/
├── 📖 DOCUMENTATION
│   ├── README.md                    # Point de départ
│   ├── TP_CORRIGES_ET_AVANCES.md   # ⭐ TP principaux
│   ├── INDEX_PEDAGOGIQUE.md         # CE FICHIER
│   └── NEXT_STEPS.md                # Prochaines étapes
│
├── 🐳 DOCKERFILE (Créer des images)
│   ├── python/
│   │   ├── Dockerfile              # ⭐ Simple (débutant)
│   │   ├── Dockerfile.Multistage   # ⭐⭐ Optimisé
│   │   ├── requirements.txt
│   │   └── README.md
│   └── java/
│       ├── Dockerfile              # ⭐⭐ Enterprise
│       └── README.md
│
├── 🔧 DOCKER-COMPOSE (Multi-conteneurs)
│   ├── docker-compose.yml          # ⭐ WordPress basique
│   ├── docker-compose-env.yml      # ⭐ Avec variables
│   ├── docker-compose-phpmyAdmin.yml # ⭐ 3 services
│   ├── .env.example                # Template (LIRE!)
│   └── README.md
│
├── 🌐 TRAEFIK (Reverse proxy)
│   ├── docker-compose.yml          # ⭐ Traefik simple
│   ├── wp/                         # ⭐⭐ WordPress + Traefik
│   └── README.md
│
├── 🔀 SWARM (Orchestration distribuée)
│   ├── nginx.yml                   # ⭐⭐⭐ Multi-nœud
│   ├── nginx-constrainst.yml       # ⭐⭐⭐ Constraints
│   ├── swarm-team.md
│   └── README.md
│
└── ...autres modules
```

---

## 🎯 TP Pratiques - Par Niveau

### ⭐ Débutant (2-3h)

**TP 1: Votre Premier Conteneur NGINX**

Durée: 30 min

```bash
# Ouvrir: TP_CORRIGES_ET_AVANCES.md [TP 1]
docker run -d --name my-nginx -p 8080:80 nginx
docker ps
curl http://localhost:8080
docker logs my-nginx
docker stop my-nginx
docker rm my-nginx
```

**Concepts:** `docker run`, `docker ps`, `docker logs`, ports mapping

**Fichier de référence:** `dockerfile/python/Dockerfile`

---

**TP 2: WordPress + MySQL (Avec lien)**

Durée: 1h

```bash
# Ouvrir: TP_CORRIGES_ET_AVANCES.md [TP 2]
# Lancer MySQL
docker run -d --name wordpress-db \
  -e MYSQL_ROOT_PASSWORD=wordpress \
  mariadb

# Lancer WordPress
docker run -d --name wordpress \
  --link wordpress-db:mysql \
  -p 80:80 \
  -e WORDPRESS_DB_HOST=wordpress-db \
  wordpress

# Vérifier
curl http://localhost
```

**Concepts:** Networks, `--link`, environment variables

**Fichier de référence:** `docker-compose/docker-compose.yml`

---

**TP 3: Créer votre Image Dockerfile**

Durée: 1.5h

```bash
# 1. Créer un fichier app.py
cat > app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello Docker!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# 2. Créer requirements.txt
echo "Flask==2.3.0" > requirements.txt

# 3. Créer Dockerfile (basé sur le modèle du projet)
cat > Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
EOF

# 4. Builder
docker build -t my-app:1.0 .

# 5. Tester
docker run -p 5000:5000 my-app:1.0
curl http://localhost:5000
```

**Fichiers de référence:** `dockerfile/python/*`

---

### ⭐⭐ Intermédiaire (4-6h)

**TP 4: Docker Compose avec Volumes**

Durée: 2h

```bash
# Ouvrir: TP_CORRIGES_ET_AVANCES.md [TP 3]
# Ouvrir: TP_CORRIGES_ET_AVANCES.md [Docker Compose]
cd docker-compose
cp .env.example .env
docker-compose up -d
docker-compose ps
docker-compose logs wordpress
curl http://localhost
docker-compose down
```

**Concepts:** Volumes, `docker-compose.yml`, environment files

---

**TP 5: Multistage Build**

Durée: 2h

```bash
# Ouvrir: dockerfile/python/Dockerfile.Multistage
# Comparer les tailles:
docker build -f Dockerfile -t simple:1.0 .
docker build -f Dockerfile.Multistage -t multi:1.0 .

docker images | grep -E "simple|multi"
# multi devrait être beaucoup plus petit!

# Analyser les stages
docker history simple:1.0
docker history multi:1.0
```

**Concepts:** Multistage builds, optimisation taille

---

**TP 6: Traefik Reverse Proxy**

Durée: 2h

```bash
# Ouvrir: traefik/README.md
cd traefik
docker-compose up -d

# Accéder
curl http://whoami.localhost
curl http://localhost:8080  # Dashboard

# Ajouter votre service derrière Traefik
# (voir traefik/README.md pour les labels)
```

**Concepts:** Reverse proxy, routing, labels Docker

---

### ⭐⭐⭐ Avancé (6-8h+)

**TP 7: Projet Complet - Blog WordPress Production-Ready**

Durée: 4h

```bash
# Ouvrir: TP_CORRIGES_ET_AVANCES.md [Version Avancée]
# Créer structure:
mkdir -p wordpress-pro/{data,config,secrets,scripts}

# Copier et adapter le docker-compose-pro.yml
# du fichier TP_CORRIGES_ET_AVANCES.md

# Générer les secrets
openssl rand -base64 32 > secrets/db_root_password.txt

# Lancer
docker-compose -f docker-compose-pro.yml up -d

# Vérifier
docker-compose -f docker-compose-pro.yml ps
docker stats

# Faire un backup
./scripts/backup.sh
```

**Concepts:** Secrets, resources limits, backups, health checks, logging

---

**TP 8: Docker Swarm Cluster**

Durée: 3h

```bash
# Ouvrir: swarm/README.md
# Ouvrir: TP_CORRIGES_ET_AVANCES.md [Swarm]

# Initialiser Swarm
docker swarm init

# Déployer un stack
cd swarm
docker stack deploy -c nginx.yml myapp

# Voir les services
docker service ls
docker service ps myapp_nginx

# Scaler
docker service scale myapp_nginx=5

# Voir les logs
docker service logs myapp_nginx

# Cleanup
docker stack rm myapp
```

**Concepts:** Swarm, services, replicas, load balancing

---

## 🔄 Progression Suggérée

### Semaine 1 (Débutant)
```
Lundi: TP 1 (Nginx) + TP 2 (WordPress basique)
Mardi: TP 3 (Créer Dockerfile)
Mercredi: Révision + Questions
Jeudi: TP 1-3 Avancés (variantes)
Vendredi: Projet personnel - "Dockeriser votre app"
```

### Semaine 2 (Intermédiaire)
```
Lundi: TP 4 (Docker Compose) + Volumes
Mardi: TP 5 (Multistage) + Images optimisées
Mercredi: TP 6 (Traefik) + Routing
Jeudi: Projet - "WordPress derrière Traefik"
Vendredi: Questions + Révision
```

### Semaine 3+ (Avancé)
```
Lundi-Jeudi: TP 7 (Production-ready) + TP 8 (Swarm)
Vendredi: Projet final - "Infrastructure multi-conteneurs complète"
```

---

## 📚 Ressources Complémentaires

### Lectures Recommandées
- `AUDIT_DOCKER.md` → Comprendre les problèmes courants
- `PLAN_AMELIORATIONS.md` → Bonnes pratiques avancées
- `GUIDE_FORMATEURS.md` → Pédagogie Docker

### Fichiers à Explorer
- `dockerfile/python/Dockerfile` → Annotations pédagogiques
- `docker-compose/docker-compose.yml` → Structure simple
- `traefik/docker-compose.yml` → Patterns réalistes
- `swarm/nginx.yml` → Orchestration

### Documentation Externe
- [Docker Official Docs](https://docs.docker.com)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Security](https://docs.docker.com/engine/security/)

---

## ✅ Checklist d'Apprentissage

### Phase Débutant
- [ ] Lancer un conteneur simple (`docker run`)
- [ ] Comprendre les ports mapping (`-p`)
- [ ] Utiliser les volumes (`-v`)
- [ ] Créer un Dockerfile basique
- [ ] Faire communiquer 2 conteneurs

### Phase Intermédiaire
- [ ] Maîtriser docker-compose
- [ ] Optimiser les images (multistage)
- [ ] Utiliser un reverse proxy
- [ ] Gérer l'environnement (.env)
- [ ] Sauvegarder les données (volumes)

### Phase Avancée
- [ ] Implémenter la sécurité (secrets, non-root)
- [ ] Configurer health checks
- [ ] Limiter les ressources
- [ ] Utiliser Docker Swarm
- [ ] Automatiser les backups

---

## 🆘 Besoin d'Aide?

**Je veux:**

| Besoin | Ressource |
|--------|-----------|
| Lancer un conteneur | TP 1 + `docker run --help` |
| Créer une image | `dockerfile/python/Dockerfile` |
| Composer des services | `docker-compose/docker-compose.yml` |
| Routage HTTP | `traefik/docker-compose.yml` |
| Haute disponibilité | `swarm/nginx.yml` |
| Sécuriser mon app | `AUDIT_DOCKER.md` section Sécurité |
| Déboguer | `docker logs`, `docker exec`, `docker inspect` |

---

## 🎓 Pour les Formateurs

Voir `GUIDE_FORMATEURS.md` pour:
- Scénarios pédagogiques
- TP avec corrections
- Timing recommandé
- Conseils d'engagement

---

<div align="center">

**Prêt à apprendre Docker? 🚀**

Commencez par README.md → STRUCTURE.md → TP 1!

</div>
