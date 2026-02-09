# TP1: Docker Compose - Basique (WordPress + MySQL)

**Niveau:** ⭐ Débutant
**Durée:** 30-45 minutes
**Objectif:** Lancer votre premier stack multi-conteneurs

---

## 📚 Concepts Couverts

- Fichier `docker-compose.yml`
- Services
- Ports mapping
- Volumes pour persistence
- Networks automatiques
- `docker-compose` commands

---

## 🎯 Exercice 1: Examiner le Compose File

### Étape 1: Lire le fichier

```bash
cd docker-compose
cat docker-compose.yml
```

### Questions:
1. Combien de services y a-t-il?
2. Quels ports sont exposés?
3. Quels volumes sont définis?
4. Comment communiquent les services?

**Réponses attendues:**
- 2 services: `wordpress` et `db`
- Ports: 80:80 pour WordPress
- Volumes: Pour data MySQL et WordPress
- Communication: Via le réseau `wordpress_default` (auto-créé)

---

## 🚀 Exercice 2: Lancer le Stack

### Étape 1: Préparer l'environnement

```bash
cd docker-compose

# Vérifier le fichier .env
cat .env.example

# Copier le template (IMPORTANT!)
cp .env.example .env
cat .env
```

### Étape 2: Lancer les services

```bash
# Lancer en arrière-plan
docker-compose up -d

# Vérifier le statut
docker-compose ps
```

**Résultat attendu:**
```
NAME              SERVICE   STATUS      PORTS
wordpress-db-1    db        Up 2 min    3306/tcp
wordpress-wp-1    wordpress Up 1 min    0.0.0.0:80->80/tcp
```

### Étape 3: Attendre le démarrage

```bash
# MySQL prend du temps à démarrer
sleep 10

# Vérifier les logs
docker-compose logs db
docker-compose logs wordpress
```

---

## 🌐 Exercice 3: Accéder aux Services

### Étape 1: Test WordPress

```bash
# Vérifier l'accès
curl http://localhost

# Ou dans le navigateur
open http://localhost    # macOS
xdg-open http://localhost  # Linux
start http://localhost   # Windows
```

**Résultat attendu:** Page d'installation WordPress

### Étape 2: Vérifier la base de données

```bash
# Entrer dans le conteneur MySQL
docker-compose exec db mysql -u root -p wordpress -e "SHOW TABLES;"

# Lors du prompt password, utiliser le password du .env
# (par défaut "wordpress" si vous n'avez pas modifié .env)
```

---

## 🔍 Exercice 4: Explorer le Network

### Étape 1: Voir les networks

```bash
# Lister les networks
docker network ls | grep wordpress

# Inspecter le network
docker network inspect wordpress_default
```

**Réponses:**
- Les 2 conteneurs sont sur le même network
- Ils peuvent communiquer par hostname: `db` → Service db

### Étape 2: Tester la communication

```bash
# Depuis WordPress, tenter de joindre MySQL
docker-compose exec wordpress bash

# À l'intérieur du conteneur WordPress:
curl http://db:3306   # Doit répondre (ou timeout gracieux)
exit
```

---

## 📊 Exercice 5: Analyser la Persistence

### Étape 1: Modifier WordPress

Depuis le navigateur, complétez l'installation WordPress:
- Site Title: "Mon Blog Test"
- Admin Username: "admin"
- Admin Password: "password123"
- Admin Email: "test@example.com"

### Étape 2: Vérifier les volumes

```bash
# Voir les volumes
docker volume ls | grep wordpress

# Inspecter un volume
docker volume inspect wordpress_wordpress_data

# Voir le contenu
docker run --rm -v wordpress_wordpress_data:/data -v $(pwd):/host \
  alpine ls -la /data/wp-content/
```

### Étape 3: Arrêter et relancer

```bash
# Arrêter les services (data préservée!)
docker-compose down

# Relancer
docker-compose up -d

# Vérifier que WordPress se souvient des données
docker-compose logs wordpress | grep "WordA" || echo "Wordpress en cours de démarrage..."

sleep 10
curl http://localhost/wp-admin/
```

---

## 🛑 Exercice 6: Arrêter et Nettoyer

### Étape 1: Arrêter sans supprimer

```bash
# Arrêter les services (data préservée)
docker-compose stop

# Vérifier que tout est arrêté
docker-compose ps

# Relancer
docker-compose start

# Vérifier
docker-compose ps
```

### Étape 2: Arrêter ET supprimer les conteneurs

```bash
# Arrêter et supprimer les conteneurs (data préservée dans volumes)
docker-compose down

# Les volumes existent toujours
docker volume ls | grep wordpress

# Relancer crée de nouveaux conteneurs, mais avec les mêmes volumes
docker-compose up -d
docker-compose ps
```

### Étape 3: Supprimer TOUT (données incluses)

```bash
# ⚠️ ATTENTION: Cela supprime aussi les données!
docker-compose down -v

# Les volumes sont supprimés
docker volume ls | grep wordpress
# Doit être vide
```

---

## 🐛 Exercice 7: Troubleshooting

### Problème: "can't connect to db"

```bash
# Solution 1: Vérifier les logs
docker-compose logs db
docker-compose logs wordpress

# Solution 2: Vérifier le network
docker network inspect wordpress_default

# Solution 3: Vérifier les variables d'env
docker-compose config | grep WORDPRESS_DB
```

### Problème: "Port 80 déjà utilisé"

```bash
# Solution: Changer le port dans docker-compose.yml
# Modifier: ports: - "8080:80"
docker-compose down
# Éditer docker-compose.yml
docker-compose up -d

# Puis accéder: curl http://localhost:8080
```

### Problème: "Database not initialized"

```bash
# MySQL peut prendre du temps
# Attendre 30 secondes et vérifier les logs
sleep 30
docker-compose logs db | tail -20

# Si toujours pas prêt, rebuild
docker-compose down -v
docker-compose up -d
sleep 30
docker-compose ps
```

---

## ✅ Validation - Checklist

- [ ] `docker-compose up -d` lance sans erreurs
- [ ] `docker-compose ps` montre 2 services `Up`
- [ ] `curl http://localhost` retourne HTML WordPress
- [ ] `docker-compose exec db` peut se connecter à MySQL
- [ ] Installation WordPress complétée
- [ ] `docker-compose down` puis `up` préserve les données
- [ ] `docker-compose down -v` supprime volumes complètement

---

## 🎓 Points Clés à Retenir

1. **docker-compose.yml = Infrastructure as Code**
   - Définit tout le stack en un fichier
   - Reproductible et versionable

2. **.env = Secrets sécurisés**
   - Jamais committer `.env`
   - `.env.example` montre la structure

3. **Networks auto**
   - Services sur le même réseau par défaut
   - Communication par hostname

4. **Volumes = Persistence**
   - `down` sans `-v` = data préservée
   - `down -v` = data supprimée

5. **Logs = Debugging**
   - `docker-compose logs service_name`
   - `docker-compose logs -f` = suivre en temps réel

---

## 🔗 Prochaine Étape

→ **TP2: Variables d'Environnement** - Gérer la configuration proprement

## 💡 Commandes Essentielles

```bash
# Lancer
docker-compose up -d

# Voir les logs
docker-compose logs -f [service]

# Entrer dans un conteneur
docker-compose exec [service] bash

# Redémarrer un service
docker-compose restart [service]

# Arrêter
docker-compose stop

# Arrêter et supprimer conteneurs
docker-compose down

# Arrêter et supprimer tout (y compris volumes)
docker-compose down -v

# Rebuild les images
docker-compose up -d --build

# Voir la configuration complète (avec interpolation des variables)
docker-compose config
```

---

**Fin TP1** ✅
