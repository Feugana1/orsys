# TP2: Traefik - Routing Avancé (Path-based, Middlewares)

**Niveau:** ⭐⭐ Intermédiaire | **Durée:** 1.5h | **Objectif:** Path-based routing et middlewares

## 🎯 Concepts

- Routing par path (`Path(/api)`)
- Middlewares (authentification, rate limiting)
- Path stripping
- Load balancing

## 🚀 Exercice 1: Path-Based Routing

```bash
cd traefik

# Ajouter à docker-compose.yml:
cat >> docker-compose.yml << 'EOF'

  api:
    image: python:3.11
    command: python -m http.server 8000
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=PathPrefix(`/api`)"
      - "traefik.http.routers.api.service=api"
      - "traefik.http.services.api.loadbalancer.server.port=8000"
      - "traefik.http.middlewares.api-strip.stripprefix.prefixes=/api"
      - "traefik.http.routers.api.middlewares=api-strip"
EOF

docker-compose down && docker-compose up -d
sleep 5

# Test path-based routing
curl http://localhost/api/
# Doit répondre avec HTTP server listing
```

## 🔐 Exercice 2: Middleware - Basic Auth

```bash
# Créer credentials
echo -n "user:password" | openssl dgst -md5 -hex

# Ajouter au docker-compose.yml
cat >> docker-compose.yml << 'EOF'

  secure:
    image: nginx:alpine
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.secure.rule=Host(`secure.localhost`)"
      - "traefik.http.routers.secure.middlewares=auth"
      - "traefik.http.middlewares.auth.basicauth.users=user:hash_mdici"
EOF

docker-compose restart

# Sans auth
curl -H "Host: secure.localhost" http://localhost/
# 401 Unauthorized

# Avec auth
curl -u user:password -H "Host: secure.localhost" http://localhost/
# Fonctionne!
```

## 🚦 Exercice 3: Rate Limiting

```bash
# Ajouter rate limiting
cat >> docker-compose.yml << 'EOF'
      - "traefik.http.middlewares.ratelimit.ratelimit.average=10"
      - "traefik.http.middlewares.ratelimit.ratelimit.period=1s"
      - "traefik.http.middlewares.ratelimit.ratelimit.burst=20"
EOF

docker-compose restart

# Faire bcp de requêtes
for i in {1..30}; do
  curl -H "Host: whoami.localhost" http://localhost/ 2>&1 | grep -i "rate\|429"
done
# Quelques requêtes doivent être bloquées (429)
```

## ✅ Checklist

- [ ] API service accessible via `/api`
- [ ] Path stripping fonctionne
- [ ] Basic auth demande credentials
- [ ] Rate limiting bloque après N requêtes
- [ ] Dashboard montre les routers

---

**Fin TP2** ✅
