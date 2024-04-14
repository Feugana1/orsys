#Créer une stack1
% docker stack deploy -c nginx.yml stack1

# Lister les services de la stack
% docker stack services stack1
        ID             NAME               MODE         REPLICAS   IMAGE             PORTS
        5jh2cijlqa3j   stack1_db      replicated   0/1        postgres:latest
        nes48iw27twe   stack1_nginx   replicated   5/5        nginx:latest

# Lister containers qui tournent
% docker ps
        CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS     NAMES
        3627a97a436d   nginx:latest   "/docker-entrypoint.…"   32 seconds ago   Up 31 seconds   80/tcp    stack1_nginx.1.dxh3ch2rtek5xjx1iqkxiiwjo
        f141ed384267   nginx:latest   "/docker-entrypoint.…"   32 seconds ago   Up 31 seconds   80/tcp    stack1_nginx.5.qy7d1aba0sk7ayk62v7uyl0rq
        6386d2af93f8   nginx:latest   "/docker-entrypoint.…"   32 seconds ago   Up 31 seconds   80/tcp    stack1_nginx.3.92zbknoex5v1syzf8tg8hxe1n
        40825b8c7ffb   nginx:latest   "/docker-entrypoint.…"   33 seconds ago   Up 32 seconds   80/tcp    stack1_nginx.4.fqekcp7lxd1ejty9iplkbs0bt
        09434d8188a4   nginx:latest   "/docker-entrypoint.…"   34 seconds ago   Up 33 seconds   80/tcp    stack1_nginx.2.gwgtrpky5gbn35vrtvjzkml77

# afficher des logs d'un service de la stack
% docker logs stack1_nginx.1.dxh3ch2rtek5xjx1iqkxiiwjo

docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
        /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
        10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
        10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
        /docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
        /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
        /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.shell

Tout simplement parce qu'on n'a pas indiqué de ports (decommenter les lignes en commentaire et faisons une mise à jour du deploiement)

# Déploiement d'une nouvelle stack
% docker service deploy -c nginx.yml stack1

# Mise à jour de la stack
docker service update --replicas=1 stack1_nginx
        stack1_nginx
        overall progress: 1 out of 1 tasks
        1/1: running   [==================================================>]
        verify: Service converged
