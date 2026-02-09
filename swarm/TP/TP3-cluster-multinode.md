# TP3: Swarm Cluster Multi-Nœuds

**Niveau:** ⭐⭐⭐ Avancé
**Durée:** 1.5 heures
**Objectif:** Créer un cluster Swarm avec 3 nœuds (VMs ou Docker Desktop)

---

## 📚 Concepts Couverts

- Manager vs Worker roles
- Token de jointure
- Node labels et constraints
- Quorum et consensus Raft
- Health checks

---

## 🎯 Exercice 1: Préparer 3 Nœuds

### Option A: Avec Docker Desktop + Docker in Docker

```bash
# Créer 3 conteneurs pour simuler 3 nœuds
docker run -d --name node1 --privileged -it docker:dind
docker run -d --name node2 --privileged -it docker:dind
docker run -d --name node3 --privileged -it docker:dind

# Vérifier
docker ps | grep node
```

### Option B: Avec Docker en réseau

```bash
# Créer un network
docker network create --driver bridge swarm-net

# Lancer 3 conteneurs connectés
docker run -d --name node1 --network swarm-net --privileged docker:dind
docker run -d --name node2 --network swarm-net --privileged docker:dind
docker run -d --name node3 --network swarm-net --privileged docker:dind
```

### Option C: Avec 3 VMs (VirtualBox, Hyper-V)

```bash
# Créer 3 VMs avec Docker installé
# Ubuntu 20.04 + Docker Engine
# node1: 192.168.0.10
# node2: 192.168.0.11
# node3: 192.168.0.12
```

---

## 🚀 Exercice 2: Initialiser le Cluster

### Étape 1: Initialiser le manager (node1)

```bash
# Sur node1
docker swarm init --advertise-addr <IP_node1>

# Résultat:
# Swarm initialized: current node (xyz123...) is now a manager.
```

### Étape 2: Récupérer les tokens

```bash
# Token worker (sur node1)
docker swarm join-token worker
# SWMTKN-1-5abc...

# Token manager (sur node1)
docker swarm join-token manager
# SWMTKN-1-4xyz...
```

### Étape 3: Ajouter les workers

```bash
# Sur node2
docker swarm join --token SWMTKN-1-5abc... <IP_node1>:2377

# Sur node3
docker swarm join --token SWMTKN-1-5abc... <IP_node1>:2377

# Résultat sur chaque:
# This node joined a swarm as a worker.
```

### Étape 4: Vérifier le cluster

```bash
# Sur node1 (manager)
docker node ls

# Résultat:
# ID          HOSTNAME    STATUS    AVAILABILITY    MANAGER STATUS
# xyz123*     node1       Ready     Active           Leader
# abc456      node2       Ready     Active
# def789      node3       Ready     Active
```

---

## 🏷️ Exercice 3: Labéliser les Nœuds

### Étape 1: Ajouter des labels

```bash
# Sur node1 (manager)
docker node update --label-add role=web node2
docker node update --label-add role=db node3
docker node update --label-add role=manager node1

# Vérifier
docker node inspect node2 --pretty | grep -A 5 "Labels"
```

### Étape 2: Utiliser les labels pour le placement

```bash
# Créer une stack avec constraints
cat > stack-multinode.yml << 'EOF'
version: '3.8'

services:
  frontend:
    image: nginx:latest
    ports:
      - "8080:80"
    deploy:
      replicas: 2
      placement:
        constraints: [node.labels.role == web]
    networks:
      - webnet

  database:
    image: postgres:14
    environment:
      POSTGRES_PASSWORD: password123
    deploy:
      replicas: 1
      placement:
        constraints: [node.labels.role == db]
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - webnet

networks:
  webnet:

volumes:
  db_data:
EOF

# Déployer
docker stack deploy -c stack-multinode.yml mystack

# Vérifier le placement
docker stack ps mystack
# frontend doit être sur node2
# database doit être sur node3
```

---

## 👔 Exercice 4: Managers et Workers

### Étape 1: Promouvoir un worker en manager

```bash
# Sur node1 (manager)
docker node promote node2

# Vérifier
docker node ls
# node2 doit avoir MANAGER STATUS = "Reachable"
```

### Étape 2: Observer le quorum Raft

```bash
# Voir l'état du cluster
docker info | grep -A 20 "Swarm"

# Nombre de managers
docker node ls | grep -i "manager\|leader" | wc -l
```

### Étape 3: Rétrograder un manager

```bash
# Sur node1 (manager)
docker node demote node2

# Vérifier
docker node ls
# node2 doit revenir à MANAGER STATUS vide
```

---

## 🌐 Exercice 5: Communication Inter-Nœuds

### Étape 1: Voir le networking

```bash
# Sur node1
docker network ls | grep webnet

# Voir le network Swarm
docker network inspect webnet_webnet

# Tous les nœuds doivent voir les services
docker service ps mystack
# Services répartis sur node1, node2, node3
```

### Étape 2: Test de connectivité

```bash
# Sur node1, accéder à un service sur node3
curl http://localhost:8080

# Les requests sont distribuées
for i in {1..10}; do
  curl -s http://localhost:8080 | grep "Server:" | head -1
done
```

---

## 📊 Exercice 6: Monitoring et Logs

### Étape 1: Logs distribuées

```bash
# Voir les logs du service depuis n'importe quel nœud
docker service logs mystack_database

# Logs d'un conteneur spécifique
docker service ps mystack_frontend
docker logs <container_id>
```

### Étape 2: Health check

```bash
# Les services sont monitored automatiquement
docker service ps mystack

# Voir l'état de chaque réplica
# Si un conteneur crash, Swarm le relance
```

---

## 🛠️ Exercice 7: Mises à Jour en Cluster

### Étape 1: Rolling update

```bash
# Mettre à jour l'image
docker service update \
  --image nginx:alpine \
  mystack_frontend

# Observer les mises à jour
docker service ps mystack_frontend --no-trunc

# Les updates progressent: node à node
```

### Étape 2: Contrôler la vitesse

```bash
# Mise à jour lente (1 à la fois, délai 30s)
docker service update \
  --update-parallelism 1 \
  --update-delay 30s \
  --image nginx:1.25 \
  mystack_frontend
```

---

## ⚠️ Exercice 8: Résilience - Simuler une Panne

### Étape 1: Arrêter un worker

```bash
# Sur node2, arrêter Docker
docker stop <container_if_dind>  # Si utilisant dind

# Ou sur VM: systemctl stop docker
```

### Étape 2: Observer la redistribution

```bash
# Sur node1 (manager)
docker service ps mystack

# Les conteneurs de node2 devraient être relancés sur node3
# Le cluster se rééquilibre automatiquement
```

### Étape 3: Redémarrer le nœud

```bash
# Redémarrer docker sur node2
# Les conteneurs qui avaient crashé peuvent être redéployés

# Vérifier le status
docker node ls
# node2 revient à "Ready"
```

---

## ✅ Validation - Checklist

- [ ] 3 nœuds créés et connectés en réseau
- [ ] Cluster Swarm initialisé
- [ ] `docker node ls` montre 3 nœuds
- [ ] Labels appliqués correctement
- [ ] Stack déployée avec constraints
- [ ] Services placés sur les bons nœuds
- [ ] Manager promotion/demotion fonctionne
- [ ] Quorum visible: `docker info`
- [ ] Logs accessibles de n'importe quel nœud
- [ ] Rolling updates sans downtime

---

## 🎓 Points Clés à Retenir

1. **Architecture Multi-Nœud**
   - Managers: Décisionnaires (min 1)
   - Workers: Exécutants
   - Quorum Raft: Consensus automatique

2. **Node Labels**
   - Placement des services
   - Constraints flexibles
   - Infrastructure as Code

3. **Résilience Automatique**
   - Détection de pannes
   - Rééquilibrage automatique
   - Services relancés ailleurs

4. **Networking Overlay**
   - Services communiquent partout
   - Load balancing transparent
   - DNS fonctionnement sur tous les nœuds

5. **Rolling Updates**
   - Zéro downtime
   - Contrôle de la vitesse
   - Version précédente peut rollback

---

## 🔗 Prochaine Étape

→ **TP4-7: Cas Avancés** - HA, Rollback, Production patterns (voir swarm/swarm-team.md)

## 💡 Cluster Management

```bash
# Nodes
docker node ls
docker node inspect node1
docker node update --label-add key=value node1
docker node promote node2
docker node demote node2

# Swarm
docker swarm init
docker swarm join-token worker
docker swarm join-token manager
docker swarm leave --force

# Services clustering
docker service create --placement-pref role=manager ...
docker service update --image new:version service-name
```

---

**Fin TP3** ✅

**Prochaines étapes dans swarm-team.md:**
- TP4: Mises à jour et rollback
- TP5: Haute disponibilité
- TP6: Supervision (Portainer)
- TP7: Projet final 3-tier
