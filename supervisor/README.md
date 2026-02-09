# 👁️ Supervisor - Gestion Multi-Processus (Anti-Pattern Pédagogique)

Comprendre pourquoi faire tourner plusieurs processus dans un conteneur est une mauvaise pratique.

## ⚠️ Important: C'est un Anti-Pattern!

Supervisor est inclus **à titre pédagogique** pour comprendre pourquoi:
- ❌ Un conteneur = Un processus (philosophie Docker)
- ❌ Logging devient complexe
- ❌ Monitoring difficile
- ❌ Scalabilité compromise

## 📚 Contenu

Ce module démontre comment Supervisor gère plusieurs processus et **pourquoi ce n'est pas la bonne approche en Docker**.

### ⭐ Basique
- `Dockerfile` - Image avec Supervisor
- `supervisord.conf` - Configuration multi-processus
- Concepts: supervisor, processus multiples, logging
- Cas d'usage: legacy apps, compréhension pédagogique

## 🚀 Démarrage Rapide

### 1. Examiner la Configuration

```bash
cd supervisor
cat Dockerfile           # Voir comment supervisor s'installe
cat supervisord.conf    # Configuration
```

### 2. Construire l'Image

```bash
docker build -t supervisor-demo:1.0 .
```

### 3. Lancer le Conteneur

```bash
docker run -d --name supervisor-demo supervisor-demo:1.0

# Voir les logs
docker logs supervisor-demo

# Accéder au conteneur
docker exec -it supervisor-demo bash

# Vérifier les processus
docker exec supervisor-demo ps aux
```

### 4. Nettoyer

```bash
docker stop supervisor-demo
docker rm supervisor-demo
```

## 📖 Fichiers

| Fichier | Description | Rôle |
|---------|-------------|------|
| `Dockerfile` | Installation et config Supervisor | Configuration |
| `supervisord.conf` | Programmes gérés (nginx, ssh, etc) | Configuration |

## 💡 Pourquoi c'est un Anti-Pattern

### ❌ Problème 1: Logging

```bash
# Avec Supervisor - logs dans le conteneur
docker logs supervisor-demo          # Logs incomplets
docker exec supervisor-demo cat logs # Accès manuel complexe

# ✅ Solution Docker: 1 processus = 1 conteneur
# STDOUT automatiquement capturé
docker logs my-nginx                 # Tous les logs
docker logs my-ssh                   # Logs séparés
```

### ❌ Problème 2: Restart Policy

```bash
# Avec Supervisor
docker run ... supervisor-demo
# Supervisor redémarre les processus
# Mais le conteneur continue même si tout crash

# ✅ Solution Docker
docker run --restart=unless-stopped my-app
# Si le processus crash → conteneur redémarré
# Si le conteneur crash → Docker le relance
```

### ❌ Problème 3: Scalabilité

```bash
# Avec Supervisor - 1 conteneur = N processus fixes
docker run -d supervisor-demo    # 1 instance

# ✅ Solution Docker - Orchestrer facilement
docker-compose scale myapp=3     # 3 instances
docker service scale myapp=5     # 5 réplicas Swarm
```

## 🎓 TP: Comprendre l'Anti-Pattern

### Exercice 1: Observer les Processus

```bash
# Lancer avec Supervisor
docker run -d --name supervisored myapp-supervisor
docker exec supervisored ps aux

# Lancer la version Docker-native
docker run -d --name nginx-native nginx
docker run -d --name ssh-native my-ssh-image
docker ps

# Comparer les approches
echo "Supervisor: 1 conteneur"
echo "Native: 2 conteneurs indépendants"
```

### Exercice 2: Résilience

```bash
# Tuer un processus avec Supervisor
docker exec supervisored killall nginx
sleep 2
docker exec supervisored ps aux     # nginx redémarré par Supervisor

# Tuer un processus Docker-native
docker kill nginx-native
docker ps                           # Container arrêté
docker start nginx-native           # Redémarrer manuellement

# La vraie solution: --restart policy
docker run --restart=unless-stopped -d nginx
docker kill nginx
docker ps                           # Docker l'a automatiquement redémarré!
```

## 🔗 Lire Aussi

- [TP_CORRIGES_ET_AVANCES.md](../TP_CORRIGES_ET_AVANCES.md) - Approche correcte
- [STRUCTURE.md](../STRUCTURE.md) - Architecture complète
- [PLAN_AMELIORATIONS.md](../PLAN_AMELIORATIONS.md) - Bonnes pratiques

## 📚 Ressources

- [Supervisor Documentation](http://supervisord.org/)
- [Docker Best Practices - One Process](https://docs.docker.com/config/containers/multi-service_container/)
- [Docker Restart Policies](https://docs.docker.com/config/containers/start-containers-automatically/)

## ✅ Apprentissage

Après ce module, vous comprendrez:
- [ ] Pourquoi un conteneur = un processus
- [ ] Comment Docker gère la résilience automatiquement
- [ ] Quand utiliser Supervisor (legacy seulement)
- [ ] Comment scalabiliser proprement

## 🆘 Troubleshooting

| Problème | Solution |
|----------|----------|
| "Cannot find supervisord" | Vérifier Dockerfile RUN apt-get install |
| "Process won't start" | Vérifier supervisord.conf syntax |
| "Logging issues" | Supervisor logs ≠ docker logs - c'est le problème! |

---

**Important:** Ce module est pédagogique. Pour la production, utilisez **un processus par conteneur** + orchestration Docker.

Voir docker-compose/README.md ou swarm/README.md pour la bonne approche →
