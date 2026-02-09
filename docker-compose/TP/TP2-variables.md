# TP2: Variables d'Environnement - Gérer la Configuration

**Niveau:** ⭐⭐ Intermédiaire
**Durée:** 45 minutes
**Objectif:** Gérer les secrets et variables de configuration proprement

---

## 📚 Concepts Couverts

- Fichiers `.env`
- `environment:` vs `env_file:`
- Interpolation de variables
- Secrets sécurisés (ne pas committer)
- Fichiers `.example` pour documentation

---

## 🎯 Exercice 1: Examiner les Variables

### Étape 1: Voir le fichier avec variables

```bash
cd docker-compose
cat docker-compose-env.yml
```

### Étape 2: Comparer simple vs variables

```bash
# Version simple (variables en dur)
cat docker-compose.yml | grep -A 5 "environment:"

# Version avec variables (TP2)
cat docker-compose-env.yml | grep -A 5 "environment:"
```

### Questions:
1. Quelle est la différence?
2. Pourquoi utiliser des variables?
3. Où sont stockées les valeurs secrètes?

---

## 🔐 Exercice 2: Gérer les Secrets Proprement

### Étape 1: Voir le template

```bash
cat .env.example
```

### Étape 2: Créer votre fichier .env

```bash
# Créer depuis le template
cp .env.example .env

# Vérifier (NE PAS committer!)
cat .env

# Modifier les valeurs si nécessaire
# nano .env
```

### Étape 3: Vérifier qu'on ne commit pas les secrets

```bash
# Vérifier .gitignore
cat .gitignore | grep ".env"

# Doit contenir: /.env

# Ajouter si manquant
echo ".env" >> .gitignore
```

---

## 🚀 Exercice 3: Lancer avec Variables

### Étape 1: Lancer le stack

```bash
# docker-compose va automatiquement charger .env
docker-compose -f docker-compose-env.yml up -d
```

### Étape 2: Vérifier les variables injectées

```bash
# Voir la configuration avec variables interpolées
docker-compose -f docker-compose-env.yml config

# Voir uniquement les variables
docker-compose -f docker-compose-env.yml config | grep -A 10 "environment:"
```

### Étape 3: Tester les services

```bash
# Vérifier les logs
docker-compose -f docker-compose-env.yml logs db

# Tester WordPress
curl http://localhost

# Vérifier que MySQL a reçu les variables
docker-compose -f docker-compose-env.yml exec db mysql -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d= -f2) -e "SHOW DATABASES;"
```

---

## 🎯 Exercice 4: Modifier les Variables

### Étape 1: Changer un paramètre

```bash
# Éditer .env
# Exemple: changer WORDPRESS_DB_PASSWORD

# Voir l'ancienne valeur
grep WORDPRESS_DB_PASSWORD .env

# Modifier (attention: doit matcher le password MySQL!)
sed -i 's/WORDPRESS_DB_PASSWORD=.*/WORDPRESS_DB_PASSWORD=monpwd123/' .env

# Vérifier
cat .env | grep WORDPRESS_DB_PASSWORD
```

### Étape 2: Relancer pour appliquer

```bash
# Arrêter l'ancien stack
docker-compose -f docker-compose-env.yml down

# Modifier .env
# (vous l'avez déjà fait)

# Relancer
docker-compose -f docker-compose-env.yml up -d

# Vérifier les nouvelles variables
docker-compose -f docker-compose-env.yml config | grep WORDPRESS_DB_PASSWORD
```

---

## 📋 Exercice 5: Créer Votre Propre .env

### Étape 1: Cas pratique - Stack Production

```bash
mkdir -p my-stack
cd my-stack

# Créer docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    image: nginx:latest
    ports:
      - "${WEB_PORT}:80"
    environment:
      - NGINX_HOST=${NGINX_HOST}
      - NGINX_PORT=${NGINX_PORT}
    volumes:
      - ./html:/usr/share/nginx/html:ro
    networks:
      - app-network

  app:
    image: python:3.11-slim
    environment:
      - APP_ENV=${APP_ENV}
      - APP_DEBUG=${APP_DEBUG}
      - DATABASE_URL=${DATABASE_URL}
    networks:
      - app-network

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=${DB_NAME}
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - app-network

networks:
  app-network:

volumes:
  db_data:
EOF

# Créer .env.example (sans secrets!)
cat > .env.example << 'EOF'
# Web Server
WEB_PORT=8080
NGINX_HOST=localhost
NGINX_PORT=80

# Application
APP_ENV=production
APP_DEBUG=false

# Database
DB_NAME=myapp
DB_USER=appuser
DB_PASSWORD=CHANGE_ME_IN_PRODUCTION

# Database connection string
DATABASE_URL=postgresql://appuser:CHANGE_ME_IN_PRODUCTION@db:5432/myapp
EOF

# Créer .env (avec valeurs réelles)
cat > .env << 'EOF'
WEB_PORT=8080
NGINX_HOST=localhost
NGINX_PORT=80

APP_ENV=development
APP_DEBUG=true

DB_NAME=myapp
DB_USER=appuser
DB_PASSWORD=secure_dev_password_123

DATABASE_URL=postgresql://appuser:secure_dev_password_123@db:5432/myapp
EOF

# Ajouter à .gitignore
echo ".env" >> .gitignore
```

### Étape 2: Vérifier et lancer

```bash
# Voir la configuration
docker-compose config

# Lancer
docker-compose up -d

# Vérifier
docker-compose ps
docker-compose logs db
```

---

## 🔄 Exercice 6: Différents Fichiers .env

### Étape 1: Créer des versions pour différents environnements

```bash
# .env.dev - Pour développement
cat > .env.dev << 'EOF'
APP_ENV=development
APP_DEBUG=true
DB_PASSWORD=dev_password
EOF

# .env.prod - Pour production
cat > .env.prod << 'EOF'
APP_ENV=production
APP_DEBUG=false
DB_PASSWORD=prod_secure_password_xyz
EOF

# .env.test - Pour tests
cat > .env.test << 'EOF'
APP_ENV=test
APP_DEBUG=false
DB_PASSWORD=test_password
EOF
```

### Étape 2: Lancer avec différents fichiers

```bash
# Développement
docker-compose --env-file .env.dev config | grep APP_ENV

# Production (ATTENTION: ne pas exposer les secrets!)
docker-compose --env-file .env.prod config | grep APP_ENV

# Tests
docker-compose --env-file .env.test config | grep APP_ENV
```

---

## ✅ Validation - Checklist

- [ ] `.env.example` existe et documente les variables
- [ ] `.env` existe mais n'est pas committé
- [ ] `.env` contient les valeurs réelles
- [ ] `.gitignore` contient `.env`
- [ ] `docker-compose config` montre les variables interpolées
- [ ] Services démarrent avec les bonnes variables
- [ ] Plusieurs fichiers `.env.*` peuvent coexister
- [ ] `--env-file` permet de changer l'environnement

---

## 🎓 Points Clés à Retenir

1. **`.env` = Secrets locaux**
   - Jamais committer
   - `.env.example` documente la structure

2. **Interpolation Compose**
   - `${VARIABLE_NAME}` remplacé automatiquement
   - `docker-compose config` montre le résultat

3. **Sécurité:**
   - Pas de secrets dans git
   - .env ignoré par .gitignore
   - Chaque environnement peut avoir ses secrets

4. **Flexibilité:**
   - `.env` par défaut
   - `--env-file` pour en spécifier une autre
   - Utile pour dev/test/prod

5. **Documentation:**
   - `.env.example` montre les clés requises
   - Commentaires explicatifs
   - Valeurs d'exemple safe

---

## 🔗 Prochaine Étape

→ **TP3: Production-Grade** - 3 services interconnectés (WordPress + MySQL + phpMyAdmin)

## 💡 Bonnes Pratiques

```bash
# À FAIRE ✅
1. Créer .env.example et l'ajouter au git
2. Ajouter .env à .gitignore
3. Documenter chaque variable
4. Utiliser des mots de passe forts
5. Rotation des secrets régulièrement

# À ÉVITER ❌
1. Secrets en dur dans docker-compose.yml
2. Committer .env
3. Utiliser "password" comme password
4. Variables non documentées
5. Même password pour tous les environnements
```

---

**Fin TP2** ✅
