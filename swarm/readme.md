 🐳 Apprentissage de Docker Swarm – Déploiement d’une stack sur son poste personnel

1. Initialiser le mode Swarm

Avant toute chose, assure-toi que ton moteur Docker est en mode Swarm :

```bash
docker swarm init
```

Cette commande transforme ton hôte Docker local en manager Swarm, ce qui te permet de déployer des stacks et de gérer plusieurs services.

---

2. Déployer une première stack

Crée un fichier `nginx.yml` (exemple minimal) :

```yaml
version: "3.8"

services:
  nginx:
    image: nginx:latest
    deploy:
      replicas: 5
      restart_policy:
        condition: on-failure
    ports:
      - "8080:80"

  db:
    image: postgres:latest
    environment:
      POSTGRES_PASSWORD: example
    deploy:
      replicas: 1
```

Ensuite, déploie ta stack :

```bash
docker stack deploy -c nginx.yml stack1
```

---

3. Lister les services de la stack

```bash
docker stack services stack1
```

Exemple de sortie :

```
ID             NAME               MODE         REPLICAS   IMAGE             PORTS
5jh2cijlqa3j   stack1_db          replicated   1/1        postgres:latest
nes48iw27twe   stack1_nginx       replicated   5/5        nginx:latest      *:8080->80/tcp
```

---

4. Vérifier les conteneurs en cours d’exécution

```bash
docker ps
```

Exemple :

```
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS     NAMES
3627a97a436d   nginx:latest   "/docker-entrypoint.…"   32 seconds ago   Up 31 seconds   80/tcp    stack1_nginx.1.dxh3ch2rtek5xjx1iqkxiiwjo
...
```

Chaque conteneur correspond à une réplica du service `stack1_nginx`.

---

5. Consulter les logs d’un service

Pour voir les logs d’un conteneur en particulier :

```bash
docker logs stack1_nginx.1.dxh3ch2rtek5xjx1iqkxiiwjo
```

Exemple de sortie :

```
docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
...
```

---

6. Mettre à jour la stack

Si tu modifies le fichier `nginx.yml` (par exemple en changeant le nombre de replicas), tu peux mettre à jour le déploiement :

```bash
docker stack deploy -c nginx.yml stack1
```

> ⚠️ `docker service deploy` n’existe pas.
> Pour mettre à jour un service individuel, utilise plutôt `docker service update`.

Exemple : réduire à une seule instance de Nginx :

```bash
docker service update --replicas=1 stack1_nginx
```

Sortie :

```
stack1_nginx
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
```

---

7. Supprimer la stack

Lorsque tu as terminé :

```bash
docker stack rm stack1
```

---

✅ Résumé des commandes principales

| Action                   | Commande                                            |
| ------------------------ | --------------------------------------------------- |
| Initialiser Swarm        | `docker swarm init`                                 |
| Déployer une stack       | `docker stack deploy -c nginx.yml stack1`           |
| Lister les stacks        | `docker stack ls`                                   |
| Lister les services      | `docker stack services stack1`                      |
| Voir les conteneurs      | `docker ps`                                         |
| Mettre à jour un service | `docker service update --replicas=N nom_du_service` |
| Supprimer la stack       | `docker stack rm stack1`                            |
