# TP3: Traefik - HTTPS et Let's Encrypt

**Niveau:** ⭐⭐⭐ Avancé | **Durée:** 1.5h | **Objectif:** Certificats SSL auto avec Let's Encrypt

## 🎯 Concepts

- HTTPS/TLS
- Let's Encrypt (ACME)
- Certificats auto-renew
- Entrypoints sécurisés

## 🏗️ Exercice 1: Configuration HTTPS

```bash
cd traefik

# Créer traefik.yml
cat > traefik.yml << 'EOF'
api:
  insecure: false
  dashboard: true

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entrypoint:
          to: websecure
          scheme: https

  websecure:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"

certificatesResolvers:
  letsencrypt:
    acme:
      email: admin@example.com
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web

      # Utiliser staging pour tests (limite de rate)
      # caServer: https://acme-staging-v02.api.letsencrypt.org/directory
EOF

# Créer volume pour certificats
mkdir -p letsencrypt

# Mettre à jour docker-compose.yml
cat >> docker-compose.yml << 'EOF'
      - "./traefik.yml:/traefik.yml"
      - "./letsencrypt:/letsencrypt"
      - "443:443"
EOF

docker-compose restart
```

## 🔒 Exercice 2: Services avec HTTPS

```bash
# Ajouter labels pour HTTPS
cat >> docker-compose.yml << 'EOF'

  https-service:
    image: nginx:alpine
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.https.rule=Host(`example.com`)"
      - "traefik.http.routers.https.entrypoints=websecure"
      - "traefik.http.routers.https.tls.certresolver=letsencrypt"
      - "traefik.http.routers.https.tls.domains[0].main=example.com"
      - "traefik.http.routers.https.tls.domains[0].sans=www.example.com"
EOF

docker-compose restart
```

## 📋 Exercice 3: Valider les Certificats

```bash
# Voir les certificats stockés
ls -la letsencrypt/

# Inspecter les certificats (pour les vrais domaines)
openssl s_client -connect example.com:443 -tls1_2

# Vérifier la chaîne
curl -vI https://example.com 2>&1 | grep "SSL"
```

## ⏰ Exercice 4: Auto-Renewal

Let's Encrypt renouvelle automatiquement 30j avant expiration.

```bash
# Check logs pour les renewals
docker-compose logs traefik | grep -i "acme\|certificate"

# Les certificats sont persistés dans letsencrypt/acme.json
# Traefik les renouvelle automatiquement
```

## ✅ Checklist

- [ ] traefik.yml créé avec ACME config
- [ ] Port 443 (HTTPS) exposé
- [ ] Services ont labels TLS
- [ ] Certificats stockés dans letsencrypt/
- [ ] Redirect HTTP → HTTPS automatique
- [ ] Auto-renewal configuré

## 💡 Pour Production

1. Utiliser Let's Encrypt production (pas staging)
2. Configurer email valide pour renouvellements
3. Tester d'abord en staging
4. Monitoring des certificats expiration
5. Backup acme.json

---

**Fin TP3** ✅
