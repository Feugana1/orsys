# TP3: Production-Grade - 3 Services Interconnectés

**Niveau:** ⭐⭐⭐ Avancé
**Durée:** 2 heures
**Objectif:** Déployer un stack WordPress + MySQL + phpMyAdmin production-ready

---

## 📚 Concepts Couverts

- 3+ services interdépendants
- Health checks
- Networking avancé
- Depends_on
- Resource limits
- Logging
- Backup strategies

---

## 🎯 Exercice 1: Analyser le Compose Avancé

### Étape 1: Examiner le fichier 3-services

```bash
cd docker-compose
cat docker-compose-phpmyAdmin.yml
```

### Questions:
1. Quels sont les 3 services?
2. Comment communiquent-ils?
3. Quelles sont les dépendances?
4. Comment les données sont-elles persistées?

**Réponses attendues:**
- Services: wordpress, db, phpmyadmin
- Communication via réseau `wordpress_default`
- phpmyadmin accède à db via hostname `db`
- Volumes pour data persistance

---

## 🚀 Exercice 2: Lancer le Stack Complet

### Étape 1: Préparer l'environnement

```bash
cd docker-compose
cp .env.example .env

# Vérifier les variables
cat .env
```

### Étape 2: Lancer les 3 services

```bash
docker-compose -f docker-compose-phpmyAdmin.yml up -d

# Attendre le démarrage
sleep 15

# Vérifier tous les services
docker-compose -f docker-compose-phpmyAdmin.yml ps
```

**Résultat attendu:**
```
NAME                 SERVICE      STATUS      PORTS
phpmyadmin-db-1      db           Up 14s      3306/tcp
phpmyadmin-wp-1      wordpress    Up 10s      0.0.0.0:80->80/tcp
phpmyadmin-phpmyadmin-1 phpmyadmin Up 8s      0.0.0.0:8081->80/tcp
```

---

## 🌐 Exercice 3: Accéder aux Services

### Étape 1: WordPress

```bash
# Navigateur
open http://localhost          # macOS
xdg-open http://localhost      # Linux

# Ou CLI
curl http://localhost | head -20
```

### Étape 2: phpMyAdmin

```bash
# Navigateur
open http://localhost:8081     # macOS

# Ou curl (voir le formulaire)
curl http://localhost:8081 | grep -i "login" | head -5
```

**Connexion phpMyAdmin:**
- User: `root`
- Password: La valeur de `MYSQL_ROOT_PASSWORD` dans .env
- Server: `db` (hostname du conteneur)

### Étape 3: Se connecter

```bash
# Dans phpMyAdmin:
# 1. Aller à http://localhost:8081
# 2. Entrer user: root
# 3. Entrer password (depuis .env)
# 4. Cliquer "Go"
# 5. Voir les bases de données
```

---

## 🔗 Exercice 4: Vérifier les Dépendances

### Étape 1: Voir l'ordre de démarrage

```bash
# Vérifier les logs dans l'ordre
docker-compose -f docker-compose-phpmyAdmin.yml logs db | head -10
docker-compose -f docker-compose-phpmyAdmin.yml logs wordpress | head -10
docker-compose -f docker-compose-phpmyAdmin.yml logs phpmyadmin | head -10
```

### Étape 2: Tester la communication inter-services

```bash
# Depuis WordPress, vérifier la connexion à la DB
docker-compose -f docker-compose-phpmyAdmin.yml exec wordpress \
  mysql -h db -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d= -f2) -e "SELECT VERSION();"

# Depuis phpMyAdmin, tester aussi
docker-compose -f docker-compose-phpmyAdmin.yml exec phpmyadmin \
  curl http://db:3306 2>&1 | head -1
```

---

## 📊 Exercice 5: Monitoring et Logs

### Étape 1: Logs en temps réel

```bash
# Tous les logs
docker-compose -f docker-compose-phpmyAdmin.yml logs -f

# Logs d'un service spécifique
docker-compose -f docker-compose-phpmyAdmin.yml logs -f db

# Derniers N lignes
docker-compose -f docker-compose-phpmyAdmin.yml logs --tail 50 wordpress
```

### Étape 2: Inspection des services

```bash
# Voir les variables d'environnement
docker-compose -f docker-compose-phpmyAdmin.yml exec wordpress env | grep WORDPRESS

# Voir les ports
docker-compose -f docker-compose-phpmyAdmin.yml port wordpress 80
docker-compose -f docker-compose-phpmyAdmin.yml port phpmyadmin 80
```

### Étape 3: Ressources utilisées

```bash
# Voir l'utilisation CPU/RAM
docker stats

# Pour un service spécifique
docker stats phpmyadmin-db-1
```

---

## 💾 Exercice 6: Backup et Restoration

### Étape 1: Créer un backup de la DB

```bash
# Dumper la base de données
docker-compose -f docker-compose-phpmyAdmin.yml exec db \
  mysqldump -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d= -f2) \
  --all-databases > backup_$(date +%Y%m%d_%H%M%S).sql

# Voir le backup
ls -lh backup_*.sql
file backup_*.sql
```

### Étape 2: Tester la restauration

```bash
# Obtenir le nom du fichier de backup
BACKUP_FILE=$(ls -t backup_*.sql | head -1)

# Stopper le stack (data préservée dans volumes!)
docker-compose -f docker-compose-phpmyAdmin.yml down

# Relancer
docker-compose -f docker-compose-phpmyAdmin.yml up -d

# Attendre MySQL
sleep 10

# Restaurer
docker-compose -f docker-compose-phpmyAdmin.yml exec -T db \
  mysql -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d= -f2) \
  < ${BACKUP_FILE}

# Vérifier
docker-compose -f docker-compose-phpmyAdmin.yml exec db \
  mysql -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d= -f2) \
  -e "SHOW DATABASES;"
```

---

## 🔄 Exercice 7: Scaling et Résilience

### Étape 1: Simuler une panne

```bash
# Arrêter WordPress
docker-compose -f docker-compose-phpmyAdmin.yml pause wordpress

# WordPress n'est pas accessible
curl http://localhost 2>&1 | head -5

# Redémarrer
docker-compose -f docker-compose-phpmyAdmin.yml unpause wordpress

# Fonctionnel à nouveau
sleep 2
curl http://localhost | head -5
```

### Étape 2: Redémarrage automatique

```bash
# Arrêter et tuer un conteneur
docker kill phpmyadmin-wordpress-1

# Voir comment compose le redémarre (optionnel, dépend de restart_policy)
sleep 5
docker-compose -f docker-compose-phpmyAdmin.yml ps
```

### Étape 3: Voir l'impact sur les données

```bash
# Les données persistent même après les arrêts/redémarrages
docker-compose -f docker-compose-phpmyAdmin.yml logs db | grep -i "ready"
```

---

## 🔒 Exercice 8: Sécurité en Production

### Étape 1: Vérifier les non-root users

```bash
# WordPress
docker-compose -f docker-compose-phpmyAdmin.yml exec wordpress whoami
# Doit montrer un user, pas root

# MySQL
docker-compose -f docker-compose-phpmyAdmin.yml exec db whoami
# Doit montrer un user, pas root
```

### Étape 2: Secrets dans docker-compose

```bash
# Voir si y a des secrets en dur (il ne devrait pas y en avoir!)
docker-compose -f docker-compose-phpmyAdmin.yml config | grep -i "password"
# Doit être interpolé depuis .env, pas en dur

# Vérifier qu'on ne commit pas les secrets
cat .gitignore | grep ".env"
```

---

## ✅ Validation - Checklist

- [ ] 3 services `Up` dans `docker-compose ps`
- [ ] WordPress accessible à http://localhost
- [ ] phpMyAdmin accessible à http://localhost:8081
- [ ] Connexion phpMyAdmin fonctionne
- [ ] Backup créé avec mysqldump
- [ ] Restauration du backup fonctionne
- [ ] Données persistent après down/up
- [ ] Pas de root user visible dans le conteneur

---

## 🎓 Points Clés à Retenir

1. **Multi-Service Architecture**
   - Chaque service = un rôle
   - Communication via networks
   - Dépendances gérées par compose

2. **Persistence**
   - Volumes préservent les données
   - `down` sans `-v` = data safe
   - Backups réguliers = safety net

3. **Production Readiness**
   - Health checks (si implémentés)
   - Resource limits
   - Logging centralisé
   - Secrets en .env

4. **Monitoring**
   - `docker logs` = debugging
   - `docker stats` = ressources
   - `docker-compose exec` = accès direct

5. **Automation**
   - Backups cron-scheduled
   - Monitoring alertes
   - Auto-restart policies

---

## 🔗 Prochaine Étape

→ **Traefik** - Ajouter un reverse proxy professionnel

## 💡 Produksjonspsjekk

```bash
# Avant d'aller en production, vérifier:
1. Tous les services Up
2. Health checks passent
3. Backups fonctionnent
4. Logs accessibles
5. Scaling testée
6. Secrets sécurisés
7. Restauration testée
```

---

**Fin TP3** ✅
