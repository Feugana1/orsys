# 🐋 Docker Swarm - TP Progressifs

Progression complète de débutant à expert en Docker Swarm.

---

## 📚 Structure des TP

### ⭐ Débutant (30 min)
**TP1: Initialisation Simple**
- Swarm init sur 1 nœud local
- Services et scaling basique
- Load balancing
- Premiers concepts (Manager, Service, Replica)

### ⭐⭐ Intermédiaire (1h)
**TP2: Services & Stacks**
- Stack multi-services (WordPress + MySQL)
- Déploiement déclaratif
- Rolling updates
- Networking et volumes

### ⭐⭐⭐ Avancé (1.5h)
**TP3: Cluster Multi-Nœuds**
- Créer un cluster 3 nœuds
- Managers vs Workers
- Node labels et constraints
- Placement strategies
- Monitoring et résilience

### ⭐⭐⭐⭐ Expert (Voir swarm-team.md)
**TP4-7: Cas Complexes**
- TP4: Mises à jour et rollback
- TP5: Haute disponibilité & quorum Raft
- TP6: Supervision avec Portainer
- TP7: Projet final 3-tier

---

## 🎯 Parcours Recommandé

### Jour 1 - Fondamentaux (2 heures)
```
09:00 - Lire: 00_LIRE_EN_PREMIER.md (10 min)
09:10 - Lire: swarm/README.md (10 min)
09:20 - TP1: Initialisation (50 min)
10:10 - Break (10 min)
10:20 - TP2: Services & Stacks (70 min)
```

### Jour 2 - Cluster (2-3 heures)
```
09:00 - TP3: Cluster Multi-Nœuds (90 min)
10:30 - Break (15 min)
10:45 - TP4-7: Voir swarm-team.md (60-90 min selon progression)
```

---

## 📝 Fichiers

| TP | Fichier | Concepts | Durée |
|----|---------|----------|-------|
| 1 | TP1-init-simple.md | Service, Replica, Scaling | 30 min |
| 2 | TP2-services-stacks.md | Stack, Multi-service, Updates | 1h |
| 3 | TP3-cluster-multinode.md | Cluster 3 nœuds, Labels, HA | 1.5h |
| 4-7 | swarm-team.md | Updates, HA avancée, Portainer | 2h+ |

---

## 🚀 Démarrage Rapide

### Checker que Swarm n'est pas actif

```bash
docker info | grep "Swarm: inactive"
# Doit afficher: Swarm: inactive
```

### Commencer TP1

```bash
# Lire le TP
cat TP1-init-simple.md

# Suivre les exercices
docker swarm init
docker service create --name web -p 8080:80 nginx
docker service ps web
```

---

## 💡 Progression Pédagogique

### TP1: Single Node (Local Development)
**Focus:** Concepts fondamentaux
- ✅ Facile à tester sur laptop
- ✅ Pas de réseau complexe
- ✅ Déjà Swarm mode, juste 1 nœud
- ⚠️ Pas de haute disponibilité vraie

### TP2: Multi-Service (Application Réelle)
**Focus:** Stack complet
- ✅ WordPress + MySQL
- ✅ Networking interne
- ✅ Persistence (volumes)
- ⚠️ Toujours sur 1 nœud

### TP3: Multi-Node (Production Ready)
**Focus:** Cluster distribué
- ✅ 3 nœuds (même localhost)
- ✅ Manager vs Worker
- ✅ Placement constraints
- ✅ Résilience réelle

### TP4-7: Advanced Patterns
**Focus:** Production complexe
- ✅ Rolling updates avancées
- ✅ Haute disponibilité Raft
- ✅ Supervision UI (Portainer)
- ✅ Projet complet 3-tier

---

## 🔄 Relation avec TP_CORRIGES_ET_AVANCES.md

**TP_CORRIGES_ET_AVANCES.md:** 8 TP génériques Docker (containers, images, compose)
**swarm/TP/:** Progression spécifique Swarm

Complémentaires:
- Faire d'abord TP_CORRIGES_ET_AVANCES (concepts Docker)
- Puis swarm/TP/ (orchestration avancée)

---

## 🎯 Objectifs par TP

### TP1 Validation
```
[x] Swarm init sur 1 nœud
[x] Créer un service
[x] Scaler à 3 réplicas
[x] Accéder au service
[x] Mettre à jour l'image
```

### TP2 Validation
```
[x] Stack multi-service déployée
[x] WordPress fonctionnel
[x] MySQL connectée
[x] Scaling WordPress
[x] Persistence des données
```

### TP3 Validation
```
[x] 3 nœuds dans le cluster
[x] Labels appliqués
[x] Placement constraints fonctionnent
[x] Services répartis correctement
[x] Résilience testée
```

### TP4-7 Validation
Voir swarm-team.md pour les objectives spécifiques.

---

## ⚙️ Configurations Recommandées

### Tester localement (le plus simple)

```bash
# Déjà en Swarm mode (TP1-2)
docker swarm init

# Cluster local avec Docker Desktop
# (TP3 peut utiliser docker:dind ou VMs locales)
```

### 3 VMs pour TP3+

```bash
# VirtualBox/KVM/Hyper-V
VM1: Ubuntu 20.04 + Docker Engine  (192.168.0.10) = node1 (manager)
VM2: Ubuntu 20.04 + Docker Engine  (192.168.0.11) = node2 (worker)
VM3: Ubuntu 20.04 + Docker Engine  (192.168.0.12) = node3 (worker)
```

### Docker in Docker (Alternative pour TP3)

```bash
# Plus facile que VMs, pour testing
docker run -d --name node1 --privileged docker:dind
docker run -d --name node2 --privileged docker:dind
docker run -d --name node3 --privileged docker:dind
```

---

## 📚 Ressources Complémentaires

- **TP_CORRIGES_ET_AVANCES.md:** TP 1-3 Docker basics
- **swarm-team.md:** TP 4-7 avancés (déjà préparés!)
- **swarm/README.md:** Vue d'ensemble Swarm
- **swarm/GUIDE_DEPLOIEMENT_STACK.md:** Guide déploiement basique

---

## 🔍 Troubleshooting

### "Swarm: inactive"
→ Faire `docker swarm init`

### "node ls" ne fonctionne pas
→ Swarm n'est pas actif, faire init

### Services ne démarrent pas
→ Voir les logs: `docker service logs <service_name>`
→ Vérifier les constraints: `docker service inspect <service_name>`

### Port déjà utilisé
→ Changer le port dans docker-compose ou docker service create
→ Example: `-p 8081:80` au lieu de `-p 8080:80`

---

## ✅ Checklist d'Apprentissage Complète

### Après TP1
- [ ] Comprendre Manager role
- [ ] Scaler un service
- [ ] Rolling update fonctionne
- [ ] Load balancing compris

### Après TP2
- [ ] Stack multi-service déployée
- [ ] Volumes et persistence
- [ ] Services communiquent
- [ ] Networking interne

### Après TP3
- [ ] Cluster 3 nœuds
- [ ] Node labels et constraints
- [ ] Placement strategies
- [ ] Résilience testée
- [ ] Rolling updates HA

### Après TP4-7
- [ ] Mises à jour avancées
- [ ] Rollback automatique
- [ ] Quorum Raft compris
- [ ] Portainer utilisé
- [ ] Projet 3-tier complètement testé

---

## 🎓 Points Clés Finaux

1. **Progression TP1 → TP3 → TP4-7**
   - Simple → Réaliste → Production
   - Fondamentaux → Architecture → Patterns avancés

2. **TP1-3 sont progressifs et contiennent tout**
   - Chacun peut être fait sur votre laptop
   - Pas besoin d'infrastructure complexe
   - Concepts appliqués progressivement

3. **TP4-7 (dans swarm-team.md) sont déjà préparés**
   - Cas d'usage avancés
   - Patterns production
   - Ré-utiliser la base de TP1-3

4. **Best Practice**
   - Faire TP1 seul (30 min)
   - Puis TP2 seul (1h)
   - Puis TP3 avec VMs/dind (1.5h)
   - Puis explorer TP4-7 graduellement

---

## 🚀 Prêt?

**Commencer:** `cat TP1-init-simple.md`

Bon apprentissage Swarm! 🐳

---

**Version:** TP Progressifs v1.0
**Dernier Update:** 2024
**Compatibilité:** Docker 20.10+, Swarm mode
