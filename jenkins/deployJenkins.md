#Lancement de Jenkins
docker run -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock liatrio/jenkins-alpine

#accès par defaut
admin/admin
