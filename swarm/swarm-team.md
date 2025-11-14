````markdown

 🧩 TP1 – Création et découverte du cluster Swarm

# 🎯 Objectif
Créer un cluster Swarm à 3 nœuds et comprendre le rôle des managers et workers.

# 🧪 Étapes

1. Création de 3 nœuds :
   - `node1`
   - `node2`
   - `node3`

3. Initialisation du cluster sur `node1` :
   ```bash
   docker swarm init --advertise-addr 192.168.0.8
````

Exemple de sortie :

```
Swarm initialized: current node (y2srabgt1kvi4ystgnhnkumnl) is now a manager.
```

4. Ajout des workers (node2 et node3) :

   ```bash
   docker swarm join --token <token_worker> 192.168.0.8:2377
   ```

   Exemple :

   ```
   This node joined a swarm as a worker.
   ```

5. Vérification des nœuds depuis le manager :

   ```bash
   docker node ls
   ```

6. Labelisation des nœuds :

   ```bash
   docker node update --label-add mylabel=web node2
   docker node update --label-add mylabel=bdd node3
   ```

7. Promotion et rétrogradation d’un nœud :

   ```bash
   docker node promote node2
   docker node demote node2
   ```

# ✅ Validation

* Le cluster affiche 3 nœuds dont un manager.
* Les labels sont correctement appliqués :

  ```bash
  docker node inspect node2 --pretty
  ```

---

 🧩 TP2 – Déploiement et gestion de services

# 🎯 Objectif

Créer, répliquer et supprimer des services Swarm.

# 🧪 Étapes

1. Créer un service simple :

   ```bash
   docker service create --replicas 1 --name infinite-loop nginx
   ```

2. Lister les services :

   ```bash
   docker service ls
   ```

3. Observer le déploiement :

   ```bash
   docker service ps infinite-loop
   ```

4. Mettre à l’échelle :

   ```bash
   docker service scale infinite-loop=5
   ```

5. Réduire à 3 réplicas :

   ```bash
   docker service scale infinite-loop=3
   ```

6. Supprimer le service :

   ```bash
   docker service rm infinite-loop
   ```

7. Déployer un service sur un nœud précis (selon label) :

   ```bash
   docker service create --name web --constraint 'node.labels.mylabel == web' nginx
   docker service create --name db --constraint 'node.labels.mylabel == bdd' nginx
   ```

# ✅ Validation

* Les services s’exécutent sur les nœuds correspondant à leur label.
* Vérification :

  ```bash
  docker service ps web
  ```

---

 🧩 TP3 – Déploiement multi-services avec stack

# 🎯 Objectif

Déployer une application composée de plusieurs services avec un seul fichier `stack.yml`.

# 🧪 Étapes

1. Créer le fichier `stack.yml` :

   ```yaml
   version: "3"
   services:
     web:
       image: nginx
       deploy:
         replicas: 3
         placement:
           constraints:
             - node.labels.mylabel == web
       ports:
         - "8080:80"

     db:
       image: mysql:5.7
       environment:
         MYSQL_ROOT_PASSWORD: root
       deploy:
         placement:
           constraints:
             - node.labels.mylabel == bdd
   ```

2. Déployer la stack :

   ```bash
   docker stack deploy -c stack.yml mystack
   ```

3. Vérifier les services :

   ```bash
   docker stack services mystack
   docker stack ps mystack
   ```

4. Supprimer la stack :

   ```bash
   docker stack rm mystack
   ```

# ✅ Validation

* 3 réplicas du service web sont actifs.
* Le service MySQL tourne uniquement sur le nœud `bdd`.

---

 🧩 TP4 – Mises à jour et rollback

# 🎯 Objectif

Découvrir les stratégies de mise à jour continue et rollback automatique.

# 🧪 Étapes

1. Déployer une version initiale :

   ```bash
   docker service create --name webapp --replicas 3 nginx:1.21
   ```

2. Mettre à jour la version :

   ```bash
   docker service update --image nginx:1.23 webapp
   ```

3. Déploiement progressif :

   ```bash
   docker service update \
     --update-parallelism 1 \
     --update-delay 10s \
     --image nginx:1.24 webapp
   ```

4. Simuler une erreur et rollback :

   ```bash
   docker service update --image nginx:doesnotexist webapp
   docker service rollback webapp
   ```

# ✅ Validation

* La commande `docker service ps webapp` montre les différentes versions successives.
* Le rollback restaure la version stable.

---

 🧩 TP5 – Haute disponibilité et switchover

# 🎯 Objectif

Observer la tolérance de panne, le consensus Raft et le comportement du cluster en cas de défaillance.

# 🧪 Étapes

1. Promouvoir tous les nœuds managers :

   ```bash
   docker node promote node2
   docker node promote node3
   ```

2. Vérifier le quorum :

   ```bash
   docker node ls
   docker info | grep "Is Manager"
   ```

3. Simuler une panne du leader :

   * Stopper le manager principal :

     ```bash
     docker node demote node1
     ```
   * Vérifier le nouveau leader :

     ```bash
     docker node ls
     ```

4. Supprimer un nœud et observer la redistribution :

   ```bash
   docker node rm node3 --force
   docker service ps webapp
   ```

# ✅ Validation

* Le leadership est réattribué automatiquement.
* Les conteneurs sont reprogrammés sur les nœuds disponibles.

---

 🧩 TP6 – Supervision et gestion avancée

# 🎯 Objectif

Utiliser les commandes de supervision et visualiser le cluster avec une interface graphique.

# 🧪 Étapes

1. Afficher les logs d’un service :

   ```bash
   docker service logs webapp
   ```

2. Inspecter un nœud :

   ```bash
   docker node inspect node2 --pretty
   ```

3. Lister les services et conteneurs actifs :

   ```bash
   docker service ps webapp
   docker node ls
   ```

4. Installer Portainer :

   ```bash
   docker service create \
     --name portainer \
     --publish 9000:9000 \
     --constraint 'node.role == manager' \
     --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
     portainer/portainer-ce
   ```

5. Accéder à l’interface :

   * URL : `http://<IP_MANAGER>:9000`
   * Créer un utilisateur administrateur

# ✅ Validation

* L’interface Portainer montre les services, stacks et nœuds du cluster.

---

 🚀 TP7 – Projet final : mini application complète

# 🎯 Objectif

Déployer une application 3-tier (front, backend, base de données) avec un load balancer.

# 🧪 Étapes

1. Créer un fichier `stack-final.yml` :

   ```yaml
   version: "3.8"
   services:
     frontend:
       image: nginx
       ports:
         - "8080:80"
       deploy:
         replicas: 2
         placement:
           constraints: [node.labels.mylabel == web]

     backend:
       image: node:18-alpine
       command: sh -c "npx http-server -p 3000"
       ports:
         - "3000:3000"
       deploy:
         replicas: 2

     db:
       image: postgres
       environment:
         POSTGRES_PASSWORD: example
       deploy:
         placement:
           constraints: [node.labels.mylabel == bdd]
   ```

2. Déployer :

   ```bash
   docker stack deploy -c stack-final.yml app
   ```

3. Vérifier :

   ```bash
   docker stack ps app
   docker stack services app
   ```

4. Simuler une panne et observer la redondance :

   ```bash
   docker stop <container_id>
   docker service ps app_frontend
   ```

---

 🏁 Conclusion

À l’issue de ce parcours, vous maîtrisez :

* La création et gestion d’un cluster Swarm
* Le déploiement de services répliqués
* Les mises à jour et rollback
* La haute disponibilité et la résilience
* La supervision graphique via Portainer

