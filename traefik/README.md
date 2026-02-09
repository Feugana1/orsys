# 🌐 Traefik - Reverse Proxy et Routing

Apprenez à configurer Traefik pour router le trafic HTTP/HTTPS vers vos services Docker.

## 📚 Contenu

Traefik est un reverse proxy moderne spécialement conçu pour Docker et Kubernetes.

### ⭐ Basique
- `docker-compose.yml` - Traefik + whoami (service de test)
- Concepts: reverse proxy, routing basique, dashboard
- Parfait pour comprendre les bases

### ⭐⭐ Intermédiaire
- `wp/` - WordPress derrière Traefik
- Concepts: routing par hostname, volumes, sécurité basique
- Exemple réaliste avec application web

### ⭐⭐⭐ Avancé
- Configuration complète avec HTTPS/Let's Encrypt
- Concepts: SSL/TLS, middleware, load balancing, monitoring
- Production-ready

## 🚀 Démarrage Rapide

### 1. Examiner la Configuration

```bash
cd traefik
cat docker-compose.yml        # Configuration simple
ls -la wp/                    # Exemple WordPress
```

### 2. Lancer Traefik Simple

```bash
# Lancer Traefik + whoami
docker-compose up -d

# Voir la status
docker-compose ps
```

### 3. Accéder aux Services

```bash
# Service de test (whoami)
curl -H "Host: whoami.localhost" http://localhost/

# Dashboard Traefik
curl http://localhost:8080

# Ou dans le navigateur: http://localhost:8080
```

### 4. Arrêter

```bash
docker-compose down
```

## 📖 Fichiers

| Fichier | Description | Niveau |
|---------|-------------|--------|
| `docker-compose.yml` | Traefik + whoami | ⭐ |
| `wp/docker-compose.yml` | WordPress + Traefik | ⭐⭐ |
| `traefik.yml` (NEW) | Configuration Traefik complète | ⭐⭐⭐ |

## 🎓 TP Recommandés

### 1. **TP1 (⭐):** Traefik Simple
   - Durée: 45 min
   - Lancer Traefik + whoami
   - Accéder au dashboard
   - Voir: TP/TP1-basique.md

### 2. **TP2 (⭐⭐):** Routing Multi-Services
   - Durée: 1.5h
   - Router vers plusieurs services
   - Utiliser des labels Docker
   - Voir: TP/TP2-routing.md

### 3. **TP3 (⭐⭐⭐):** HTTPS et Let's Encrypt
   - Durée: 2h
   - Configuration HTTPS
   - Certificats auto (Let's Encrypt)
   - Voir: TP/TP3-https.md

## 💡 Concepts Clés

### Reverse Proxy Basique
```yaml
# Traefik reçoit les requêtes et les route vers le bon service
Client → Traefik (port 80/443)
            ├─→ whoami.localhost → Service whoami
            ├─→ wordpress.localhost → Service WordPress
            └─→ api.localhost → Service API
```

### Labels Docker (Routing)
```yaml
services:
  wordpress:
    image: wordpress
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.wordpress.rule=Host(`wordpress.localhost`)"
      - "traefik.http.services.wordpress.loadbalancer.server.port=80"
```

### Middleware (Modifications)
```yaml
# Authentification basique
labels:
  - "traefik.http.routers.api.middlewares=auth@docker"
  - "traefik.http.middlewares.auth.basicauth.users=user:password"

# Rate limiting
labels:
  - "traefik.http.routers.web.middlewares=ratelimit@docker"
  - "traefik.http.middlewares.ratelimit.ratelimit.average=100"
```

## 🔧 Commandes Essentielles

```bash
# Lancer Traefik
cd traefik
docker-compose up -d

# Voir les logs
docker-compose logs -f traefik

# Voir les routes actives
curl http://localhost:8080/api/http/routers

# Entrer dans le conteneur
docker-compose exec traefik sh

# Arrêter
docker-compose down
```

## 🔗 Lire Aussi

- [TP_CORRIGES_ET_AVANCES.md](../TP_CORRIGES_ET_AVANCES.md) - Tous les TP avec solutions
- [STRUCTURE.md](../STRUCTURE.md) - Architecture du projet
- [docker-compose/README.md](../docker-compose/README.md) - Docker Compose basics

## 📚 Ressources Externes

- [Traefik Documentation](https://doc.traefik.io/)
- [Traefik & Docker](https://doc.traefik.io/traefik/providers/docker/)
- [Let's Encrypt Integration](https://doc.traefik.io/traefik/https/acme/)

## ✅ Progression Pédagogique

```
⭐ Basique (Semaine 1)
  ├─ Comprendre reverse proxy
  ├─ Lancer Traefik
  └─ Dashboard & whoami

⭐⭐ Intermédiaire (Semaine 2)
  ├─ Routing par hostname
  ├─ Docker labels
  └─ Multiples services

⭐⭐⭐ Avancé (Semaine 3)
  ├─ HTTPS & Let's Encrypt
  ├─ Middleware
  ├─ Load balancing
  └─ Monitoring & métriques
```

## 🆘 Troubleshooting

| Problème | Solution |
|----------|----------|
| "Host not found" | Vérifier labels Docker et règles Traefik |
| "502 Bad Gateway" | Vérifier connectivité entre Traefik et service |
| "Port 80 already in use" | Vérifier `docker ps` et arrêter les conflits |
| "HTTPS not working" | Vérifier certificats et configuration ACME |

## 🏗️ Architecture Typique

```
Internet
   ↓
Traefik (Port 80/443)
   ├─ whoami.localhost
   ├─ wordpress.localhost
   ├─ api.localhost
   └─ admin.localhost
```

---

**Prêt à router du trafic?** 🚀

Commencez par `TP/TP1-basique.md` →
