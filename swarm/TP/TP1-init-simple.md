# TP1: Docker Swarm - Initialisation Simple

**Niveau:** ⭐ Débutant
**Durée:** 30 minutes
**Objectif:** Initialiser Swarm et comprendre les concepts de base sur un seul nœud local

---

## 📚 Concepts Couverts

- Swarm mode vs Compose
- Initialiser un cluster
- Manager role
- Services vs Containers
- Load balancing basique

---

## 🎯 Exercice 1: Vérifier que Docker est prêt

### Étape 1: Vérifier la version

```bash
docker --version
# Docker version 20.10+ nécessaire

docker ps
# Doit fonctionner sans erreurs
```

### Étape 2: Vérifier qu'on n'est pas déjà en Swarm

```bash
docker info | grep "Swarm"
# Doit afficher: "Swarm: inactive"
```

---

## 🚀 Exercice 2: Initialiser Swarm

### Étape 1: Activer Swarm mode

```bash
docker swarm init
```

**Résultat attendu:**
```
Swarm initialized: current node (abc1234...) is now a manager.

To add a worker to this swarm, run the following command:
    docker swarm join --token SWMTKN-1-5abc... 192.168.x.x:2377

To add a manager to this swarm, run the following command:
    docker swarm manage --token SWMTKN-1-4xyz... 192.168.x.x:2377
```

### Étape 2: Vérifier le status

```bash
docker info | grep "Swarm"
# Doit afficher: "Swarm: active"

docker node ls
# Doit afficher: 1 node avec STATUS "Ready" et ROLE "manager"
```

---

## 🏗️ Exercice 3: Créer un Service Simple

### Étape 1: Différence Compose vs Swarm

**Docker Compose:**
```bash
docker-compose up -d
# Lance des containers liés (development)
```

**Docker Swarm:**
```bash
docker service create ...
# Crée un service géré par le cluster (production)
```

### Étape 2: Créer un service nginx

```bash
# Créer un service avec 1 réplica
docker service create \
  --name web \
  --publish 8080:80 \
  nginx:latest

# Vérifier la création
docker service ls
```

**Résultat attendu:**
```
ID             NAME   MODE        REPLICAS   IMAGE
xyz123...      web    replicated  1/1        nginx:latest
```

### Étape 3: Voir les détails du service

```bash
# Voir où le service tourne
docker service ps web

# Voir les logs
docker service logs web

# Inspecter le service
docker service inspect web
```

---

## 📊 Exercice 4: Scaler le Service

### Étape 1: Augmenter les réplicas

```bash
# Passer de 1 à 3 réplicas
docker service scale web=3

# Vérifier
docker service ps web
```

**Résultat attendu:**
```
ID      NAME    IMAGE          NODE    STATUS
abc...  web.1   nginx:latest   node1   Running
def...  web.2   nginx:latest   node1   Running
ghi...  web.3   nginx:latest   node1   Running
```

### Étape 2: Tester le load balancing

```bash
# Accéder au service (toutes les réplicas répondent)
curl http://localhost:8080

# Faire plusieurs requêtes
for i in {1..10}; do curl -s http://localhost:8080 | grep -i "server" | head -1; done
```

### Étape 3: Réduire les réplicas

```bash
# Réduire à 1
docker service scale web=1

# Vérifier
docker service ps web
```

---

## 🔄 Exercice 5: Mettre à Jour un Service

### Étape 1: Mettre à jour l'image

```bash
# Lancer 3 réplicas pour tester
docker service scale web=3

# Mettre à jour vers nginx alpine (plus léger)
docker service update --image nginx:alpine web

# Observer les mises à jour progressives
docker service ps web --no-trunc
```

**Observation:**
- Docker met à jour progressivement (rolling update)
- Anciens conteneurs remplacés par de nouveaux
- Service reste disponible pendant la mise à jour

### Étape 2: Voir l'historique

```bash
# Voir les versions du service
docker service inspect web | jq '.UpdateStatus'
```

---

## 🛑 Exercice 6: Arrêter et Supprimer

### Étape 1: Supprimer le service

```bash
# Supprimer le service (pas les données, juste le gestionnaire)
docker service rm web

# Vérifier que c'est supprimé
docker service ls
# Doit être vide

# Les conteneurs aussi sont arrêtés
docker ps
```

### Étape 2: Vérifier les conteneurs

```bash
# Voir tous les conteneurs (y compris arrêtés)
docker ps -a

# Nettoyer les conteneurs arrêtés
docker container prune -f
```

---

## 🎯 Exercice 7: Multi-Service Simple

### Étape 1: Créer 2 services

```bash
# Service web (nginx)
docker service create \
  --name frontend \
  --publish 8080:80 \
  nginx:latest

# Service API (simple Python HTTP server)
docker service create \
  --name api \
  --publish 8000:8000 \
  python:3.11-slim \
  python -m http.server 8000

# Vérifier
docker service ls
```

### Étape 2: Accéder aux services

```bash
# Frontend
curl http://localhost:8080

# API
curl http://localhost:8000

# Voir les conteneurs
docker ps

# Voir les services
docker service ps frontend
docker service ps api
```

### Étape 3: Nettoyer

```bash
docker service rm frontend api
docker service ls
# Doit être vide
```

---

## 🌐 Exercice 8: Communication Entre Services

### Étape 1: Services sur le même réseau

```bash
# Par défaut, les services communiquent via leur nom de service

# Créer un service qui teste la communication
docker service create \
  --name test-app \
  alpine:latest \
  ping -c 5 localhost

# Voir les logs
docker service logs test-app

# Nettoyer
docker service rm test-app
```

### Étape 2: DNS interne

```bash
# Les services se découvrent automatiquement par hostname
# Créer un service avec curl
docker service create \
  --name tester \
  --mode global \
  curlimages/curl:latest \
  sleep 1000

# Entrer dans le service
docker exec $(docker ps -q -f label=com.docker.swarm.service.name=tester | head -1) \
  curl http://frontend:80
```

---

## ✅ Validation - Checklist

- [ ] `docker swarm init` réussit
- [ ] `docker node ls` montre 1 manager
- [ ] Service `web` créé et accessible
- [ ] Scaling à 3 réplicas fonctionne
- [ ] Mise à jour d'image fonctionne (rolling update)
- [ ] Services multiples communicent
- [ ] Suppression de services fonctionne

---

## 🎓 Points Clés à Retenir

1. **Swarm mode = Production-grade**
   - Géré par le cluster, pas juste un conteneur
   - Ré-lancé automatiquement si crash
   - Load balancing intégré

2. **Manager role**
   - Gère l'état du cluster
   - Prend les décisions (scheduling)
   - Sur 1 nœud = Manager seul

3. **Services vs Containers**
   - Container = Instance unique
   - Service = Description (peut avoir N réplicas)
   - Scaling = Augmenter/Réduire les réplicas

4. **Networking**
   - Services sur le même réseau automatiquement
   - DNS par nom de service
   - Load balancing transparent

5. **Rolling Updates**
   - Mises à jour sans downtime
   - Progressives (1 à la fois par défaut)
   - Ancienne version garde les connexions existantes

---

## 🔗 Prochaine Étape

→ **TP2: Services & Scaling** - Avancer vers des cas plus complexes

## 💡 Commandes Essentielles

```bash
# Swarm
docker swarm init
docker swarm leave --force

# Services
docker service create --name web -p 8080:80 nginx
docker service ls
docker service ps web
docker service scale web=3
docker service update --image nginx:alpine web
docker service rm web
docker service logs web
docker service inspect web

# Nœuds
docker node ls
docker node inspect node1
```

---

**Fin TP1** ✅
