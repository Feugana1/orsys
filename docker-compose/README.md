# 🐳 Docker Compose - Orchestrer Multi-Conteneurs

Apprenez à orchestrer plusieurs conteneurs avec Docker Compose.

## 📚 Contenu

Docker Compose simplifie le lancement et la gestion de plusieurs conteneurs interconnectés avec un seul fichier YAML.

### ⭐ Basique
- `docker-compose.yml` - WordPress + MySQL simple
- Concepts: services, volumes, networks, ports
- Parfait pour démarrer avec Compose

### ⭐⭐ Intermédiaire
- `docker-compose-env.yml` - Gestion des variables d'environnement
- `.env.example` - Template sécurisé (sans credentials en dur)
- Concepts: environment variables, fichier .env, bonnes pratiques

### ⭐⭐⭐ Avancé
- `docker-compose-phpmyadmin.yml` - 3 services interconnectés (WordPress + MySQL + phpMyAdmin)
- Concepts: dépendances, health checks, logging, networks personnalisés
- Patterns production-ready

## 🚀 Démarrage Rapide

### 1. Examiner la Structure

```bash
cd docker-compose
cat docker-compose.yml          # Version simple
cat docker-compose-env.yml      # Avec variables
cat .env.example                # Template de configuration
```

### 2. Lancer un Compose Simple

```bash
# Copier le template d'environnement
cp .env.example .env

# Lancer les services
docker-compose up -d

# Vérifier le status
docker-compose ps

# Voir les logs
docker-compose logs -f wordpress
```

### 3. Accéder aux Services

```bash
# WordPress
curl http://localhost

# Arrêter
docker-compose down

# Arrêter et supprimer les volumes
docker-compose down -v
```

## 📖 Fichiers

| Fichier | Description | Services | Niveau |
|---------|-------------|----------|--------|
| `docker-compose.yml` | WordPress + MySQL | 2 | ⭐ |
| `docker-compose-env.yml` | + Variables d'env | 2 | ⭐⭐ |
| `docker-compose-phpmyadmin.yml` | + phpMyAdmin | 3 | ⭐⭐ |
| `.env.example` | Template de variables | - | Important! |

## 🎓 TP Recommandés

### 1. **TP1 (⭐):** Lancer WordPress Basique
   - Durée: 30 min
   - Démarrer docker-compose.yml
   - Accéder à WordPress
   - Voir: TP/TP1-basique.md

### 2. **TP2 (⭐⭐):** Variables d'Environnement
   - Durée: 45 min
   - Gérer .env correctement
   - Modifier configuration
   - Voir: TP/TP2-variables.md

### 3. **TP3 (⭐⭐⭐):** Production-Grade
   - Durée: 2h
   - 3 services interconnectés
   - Health checks et volumes
   - Voir: TP/TP3-production.md

## 💡 Concepts Clés

### Structure Basique
```yaml
version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - ./data:/var/www/html
    depends_on:
      - db

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: wordpress
    volumes:
      - mysql-data:/var/lib/mysql

volumes:
  mysql-data:
```

### Gestion d'Environnement Sécurisée
```bash
# ❌ Mauvais: Secrets en dur dans le fichier
environment:
  DB_PASSWORD: "mon_password_secret"

# ✅ Bon: Depuis un fichier .env
# docker-compose-env.yml
environment:
  DB_PASSWORD: ${DB_PASSWORD}

# .env (ne pas committer!)
DB_PASSWORD=mon_password_secret
```

### Networks et Communications
```yaml
services:
  web:
    image: nginx
    networks:
      - frontend

  api:
    image: myapp
    networks:
      - frontend
      - backend

  db:
    image: postgres
    networks:
      - backend

networks:
  frontend:
  backend:
```

## 🔧 Commandes Essentielles

```bash
# Lancer les services
docker-compose up -d

# Voir les logs
docker-compose logs -f [service]

# Entrer dans un conteneur
docker-compose exec [service] bash

# Redémarrer
docker-compose restart

# Arrêter
docker-compose stop

# Arrêter et supprimer
docker-compose down

# Supprimer aussi les volumes
docker-compose down -v

# Rebuild les images
docker-compose up -d --build
```

## 🔗 Lire Aussi

- [TP_CORRIGES_ET_AVANCES.md](../TP_CORRIGES_ET_AVANCES.md) - Tous les TP avec solutions
- [STRUCTURE.md](../STRUCTURE.md) - Architecture du projet
- [PLAN_AMELIORATIONS.md](../PLAN_AMELIORATIONS.md) - Patterns avancés

## 📚 Ressources Externes

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [Environment Variables](https://docs.docker.com/compose/environment-variables/)

## ✅ Progression Pédagogique

```
⭐ Basique (Semaine 1)
  ├─ Lancer wordpress simple
  ├─ Comprendre services
  └─ Gérer volumes & ports

⭐⭐ Intermédiaire (Semaine 2)
  ├─ Variables d'environnement
  ├─ Networks personnalisés
  └─ Gestion des dépendances

⭐⭐⭐ Avancé (Semaine 3)
  ├─ Health checks
  ├─ Logging avancé
  ├─ Secrets management
  └─ Production patterns
```

## 🆘 Troubleshooting

| Problème | Solution |
|----------|----------|
| "can't reach database" | Vérifier `depends_on` et networks |
| ".env not found" | `cp .env.example .env` |
| "port already in use" | Changer port dans compose ou `docker-compose down -v` |
| "slow startup" | Ajouter health checks, vérifier `depends_on` |

---

**Prêt à orchestrer?** 🚀

Commencez par `TP/TP1-basique.md` →
