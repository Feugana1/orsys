# TP1: Traefik - Reverse Proxy Simple

**Niveau:** ⭐ Débutant
**Durée:** 45 minutes
**Objectif:** Lancer Traefik et le dashboard

---

## 📚 Concepts Couverts

- Traefik comme reverse proxy
- Configuration simple
- Docker labels
- Dashboard Traefik
- Service routing

---

## 🎯 Exercice 1: Examiner la Configuration

### Étape 1: Voir le fichier Compose

```bash
cd traefik
cat docker-compose.yml
```

### Questions:
1. Quels sont les services?
2. Quels ports expose Traefik?
3. Pourquoi `/var/run/docker.sock` est monté?

**Réponses:**
- Services: traefik, whoami (test)
- Ports: 80 (HTTP), 8080 (dashboard)
- docker.sock = Traefik lit les conteneurs Docker

---

## 🚀 Exercice 2: Lancer Traefik

### Étape 1: Démarrer les services

```bash
cd traefik
docker-compose up -d

# Attendre le démarrage
sleep 5

# Vérifier
docker-compose ps
```

**Résultat attendu:**
```
NAME              SERVICE    STATUS
traefik-traefik-1 traefik    Up 4s
traefik-whoami-1  whoami     Up 2s
```

### Étape 2: Vérifier les logs

```bash
# Logs Traefik
docker-compose logs traefik | tail -20
```

---

## 🌐 Exercice 3: Accéder au Dashboard

### Étape 1: Ouvrir le dashboard

```bash
# Dans le navigateur
open http://localhost:8080    # macOS
xdg-open http://localhost:8080 # Linux

# Ou CLI
curl http://localhost:8080 | head -20
```

### Étape 2: Explorer le dashboard

**Points à voir:**
- HTTP Routers (comment Traefik route les requêtes)
- Services (les conteneurs Docker)
- Status des routes

### Étape 3: Voir les API endpoints

```bash
# Liste des routers HTTP
curl http://localhost:8080/api/http/routers

# Liste des services
curl http://localhost:8080/api/http/services

# Voir la config complète
curl http://localhost:8080/api/overview
```

---

## 📡 Exercice 4: Router vers le Service de Test

### Étape 1: Tester le whoami service

```bash
# Depuis Traefik avec le hostname correct
curl -H "Host: whoami.localhost" http://localhost/

# Résultat attendu:
# Hostname=traefik-whoami-1
# IP=172.x.x.x
# RequestMethod=GET
# RequestPath=/
# RequestProtocol=HTTP/1.1
# RequestHost=whoami.localhost
# ...
```

### Étape 2: Voir la requête dans les logs

```bash
# Logs de Traefik
docker-compose logs traefik | grep "whoami"

# Doit montrer les requêtes HTTP
```

---

## 🔍 Exercice 5: Analyser le Routing

### Étape 1: Comprendre la règle

```bash
# Dans docker-compose.yml, voir la label:
cat docker-compose.yml | grep -A 2 "traefik.http.routers"

# Doit contenir: traefik.http.routers.whoami.rule=Host(`whoami.localhost`)
```

### Étape 2: Comment ça fonctionne?

```
Client → curl -H "Host: whoami.localhost" http://localhost/
         ↓
Traefik (port 80)
         ↓
Read label: Host(`whoami.localhost`)
         ↓
Match! Route vers le service whoami
         ↓
Whoami respond: "Hostname=traefik-whoami-1"
```

### Étape 3: Essayer d'autres hostnames

```bash
# Hostname non déclaré
curl -H "Host: notfound.localhost" http://localhost/ 2>&1
# Résultat: 404 Not Found

# Pas de hostname
curl http://localhost/ 2>&1
# Résultat: 404 (pas de Host header)

# Bon hostname
curl -H "Host: whoami.localhost" http://localhost/
# Résultat: Fonctionne!
```

---

## 📊 Exercice 6: Ajouter un Nouveau Service

### Étape 1: Créer un simple service

```bash
# Créer un service nginx
cat >> docker-compose.yml << 'EOF'

  nginx:
    image: nginx:alpine
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nginx.rule=Host(`nginx.localhost`)"
      - "traefik.http.routers.nginx.entrypoints=web"
      - "traefik.http.services.nginx.loadbalancer.server.port=80"
EOF
```

### Étape 2: Relancer avec le nouveau service

```bash
# Redémarrer
docker-compose down
docker-compose up -d

sleep 5

# Vérifier les 3 services
docker-compose ps
```

### Étape 3: Accéder au nouveau service

```bash
# Test nginx
curl -H "Host: nginx.localhost" http://localhost/

# Résultat: Page nginx par défaut

# Voir les routes dans le dashboard
curl http://localhost:8080/api/http/routers | jq '.'
```

---

## 🛑 Exercice 7: Arrêter et Nettoyer

### Étape 1: Arrêter les services

```bash
docker-compose down

# Tout est arrêté
docker-compose ps
```

### Étape 2: Relancer pour vérifier la persistance

```bash
docker-compose up -d

# Tous les services redémarrent
docker-compose ps

# Routes restent les mêmes
curl -H "Host: whoami.localhost" http://localhost/
```

---

## ✅ Validation - Checklist

- [ ] `docker-compose up -d` sans erreurs
- [ ] Services `Up` dans `docker-compose ps`
- [ ] Dashboard accessible à http://localhost:8080
- [ ] `curl -H "Host: whoami.localhost" http://localhost/` fonctionne
- [ ] Whoami service respond avec son hostname
- [ ] Dashboard montre "whoami" router
- [ ] API `http://localhost:8080/api/http/routers` retourne JSON

---

## 🎓 Points Clés à Retenir

1. **Traefik = Reverse Proxy Moderne**
   - Lit les labels Docker automatiquement
   - Pas besoin de fichier de config complexe
   - Dynamic routing

2. **Labels Docker**
   - `traefik.enable=true` = Expose via Traefik
   - `traefik.http.routers.*.rule` = Règle de routing
   - `traefik.http.services.*.loadbalancer.server.port` = Port du service

3. **Routing basique**
   - `Host(` hostname `)` = Router par hostname
   - Port 80 = HTTP endpoint
   - 8080 = Dashboard Traefik

4. **Communication**
   - Traefik sur le même network
   - Accès via hostname du conteneur
   - Automatic service discovery

---

## 🔗 Prochaine Étape

→ **TP2: Routing Multi-Services** - Routing par path, middlewares

## 💡 Commandes Essentielles

```bash
# Lancer
docker-compose up -d

# Logs
docker-compose logs -f traefik

# Test routing
curl -H "Host: servicename.localhost" http://localhost/

# API Traefik
curl http://localhost:8080/api/http/routers | jq

# Arrêter
docker-compose down
```

---

**Fin TP1** ✅
