#Créer le service (le fichier)
sudo vi /etc/systemd/system/portainer.service

#Ajouter le contenu du fichier portainer.service


#rafraichir le daemon systemd
sudo systemctl daemon-reload

#activer le service
sudo systemctl enable portainer.service

#demarrer le service
sudo systemctl start portainer.service
