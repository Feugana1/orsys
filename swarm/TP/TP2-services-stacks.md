# TP2: Swarm Services & Stacks - Cas Réaliste

**Niveau:** ⭐⭐ Intermédiaire
**Durée:** 1 heure
**Objectif:** Déployer une stack multi-services (WordPress + MySQL)

---

## 📚 Concepts Couverts

- Stack vs Service
- Fichier `docker-compose.yml` en Swarm
- Déploiement orchestré
- Constraints et placements
- Health checks

---

## 🎯 Exercice 1: Créer une Stack Swarm

### Étape 1: Préparer le fichier stack

```bash
cd swarm

# Créer un stack.yml
cat > stack.yml << 'EOF'
version: '3.8'

services:
  web:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress123
    deploy:
      replicas: 2
      update_config:
        parallelism: 1
        delay: 10s
    networks:
      - webnet

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress123
    deploy:
      replicas: 1
      placement:
        constraints: [node.role == manager]
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - webnet

networks:
  webnet:

volumes:
  db_data:
EOF

cat stack.yml
```

### Étape 2: Déployer la stack

```bash
# Déployer
docker stack deploy -c stack.yml wordpress

# Vérifier la stack
docker stack ls
```

### Étape 3: Voir les services

```bash
# Services de la stack
docker stack services wordpress

# Voir tous les conteneurs de la stack
docker stack ps wordpress

# Logs
docker service logs wordpress_web
docker service logs wordpress_db
```

---

## 🌐 Exercice 2: Accéder à l'Application

### Étape 1: Attendre le démarrage

```bash
# MySQL prend du temps à démarrer
sleep 30

# Vérifier les logs
docker service logs wordpress_db | tail -20
```

### Étape 2: Tester WordPress

```bash
# Accéder à WordPress
curl http://localhost:8080 | head -20

# Ou dans le navigateur
open http://localhost:8080
```

### Étape 3: Vérifier la base de données

```bash
# Entrer dans un conteneur MySQL
docker exec $(docker ps -q -f label=com.docker.swarm.service.name=wordpress_db | head -1) \
  mysql -u wordpress -pwordpress123 wordpress -e "SHOW TABLES;"
```

---

## 📊 Exercice 3: Scaler et Mettre à Jour

### Étape 1: Augmenter les réplicas

```bash
# Augmenter les réplicas WordPress
docker service scale wordpress_web=3

# Vérifier
docker stack ps wordpress | grep web
```

### Étape 2: Mettre à jour l'image

```bash
# Mettre à jour vers une version spécifique
docker service update \
  --image wordpress:6.0 \
  wordpress_web

# Observer la mise à jour progressive
docker service ps wordpress_web --no-trunc
```

### Étape 3: Réduire les réplicas

```bash
# Réduire à 1
docker service scale wordpress_web=1

# Vérifier
docker stack ps wordpress
```

---

## 🔄 Exercice 4: Modifier et Redéployer la Stack

### Étape 1: Modifier le fichier

```bash
# Éditer stack.yml - par exemple, changer les réplicas
sed -i 's/replicas: 2/replicas: 3/' stack.yml

# Vérifier la modification
grep "replicas:" stack.yml
```

### Étape 2: Redéployer

```bash
# Redéployer (update automatique)
docker stack deploy -c stack.yml wordpress

# Vérifier
docker service ps wordpress_web | wc -l
# Doit montrer 3 réplicas
```

---

## 🛑 Exercice 5: Arrêter et Nettoyer

### Étape 1: Supprimer la stack

```bash
# Supprimer la stack (services et networks)
docker stack rm wordpress

# Vérifier
docker stack ls
docker service ls
```

### Étape 2: Vérifier que tout est nettoyé

```bash
# Services supprimés
docker service ls

# Conteneurs arrêtés
docker ps | grep wordpress
# Doit être vide

# Networks supprimés
docker network ls | grep wordpress
# Doit être vide
```

---

## 🎯 Exercice 6: Constraints et Placement

### Étape 1: Ajouter des constraints

```bash
# Créer une stack avec constraints
cat > stack-constraints.yml << 'EOF'
version: '3.8'

services:
  nginx:
    image: nginx:latest
    ports:
      - "8080:80"
    deploy:
      replicas: 2
      constraints:
        - node.role == manager  # Seulement sur manager
    networks:
      - webnet

  app:
    image: python:3.11-slim
    command: python -m http.server 8000
    ports:
      - "8000:8000"
    deploy:
      replicas: 1
    networks:
      - webnet

networks:
  webnet:
EOF

# Déployer
docker stack deploy -c stack-constraints.yml myapp

# Vérifier le placement
docker stack ps myapp
# Tous les services doivent être sur le node manager
```

### Étape 2: Nettoyer

```bash
docker stack rm myapp
```

---

## 💾 Exercice 7: Persistence avec Volumes

### Étape 1: Voir les volumes créés

```bash
# Lancer la stack WordPress à nouveau
docker stack deploy -c stack.yml wordpress

# Voir les volumes
docker volume ls | grep wordpress

# Inspecter un volume
docker volume inspect wordpress_db_data
```

### Étape 2: Vérifier la persistence

```bash
# Attendre le démarrage
sleep 30

# Accéder à WordPress et créer du contenu (via UI ou API)

# Arrêter la stack
docker stack rm wordpress

# Redéployer
docker stack deploy -c stack.yml wordpress

# Les données persistent
docker service logs wordpress_db | grep -i "recovering"
```

---

## ✅ Validation - Checklist

- [ ] Stack déployée: `docker stack ls` montre wordpress
- [ ] Services créés: `docker stack services wordpress`
- [ ] WordPress accessible: http://localhost:8080
- [ ] 2 réplicas WordPress au démarrage
- [ ] Scaling à 3 réplicas fonctionne
- [ ] Mise à jour d'image sans downtime
- [ ] Stack supprimée complètement
- [ ] Volumes créés et persistants

---

## 🎓 Points Clés à Retenir

1. **Stack = Infrastructure Complète**
   - Services interconnectés
   - Networks automatiques
   - Volumes déclarés
   - Un seul `docker stack deploy`

2. **Déploiement Déclaratif**
   - Fichier YAML = Source of Truth
   - `docker stack deploy` applique l'état désiré
   - Redéployer update (pas supprime et recrée)

3. **Rolling Updates**
   - parallelism = combien de réplicas à la fois
   - delay = pause entre mises à jour
   - Pas de downtime

4. **Networking Auto**
   - Tous les services sur le même network
   - Service discovery par DNS
   - Load balancing interne

5. **Volumes = State**
   - Persistent même si conteneurs redémarrent
   - Shared entre réplicas (avec care!)
   - Supprimer stack ≠ supprimer volumes

---

## 🔗 Prochaine Étape

→ **TP3: Haute Disponibilité** - Cluster multi-nœuds

## 💡 Commandes Stack

```bash
# Déployer
docker stack deploy -c stack.yml name

# Voir
docker stack ls
docker stack services name
docker stack ps name

# Logs
docker service logs name_service

# Mettre à jour
docker stack deploy -c stack.yml name  # Apply changes

# Supprimer
docker stack rm name
```

---

**Fin TP2** ✅
