1.Créer le service (le fichier)
sudo vi /etc/systemd/system/portainer.service

2.Ajouter le contenu du fichier portainer.service

3.rafraichir le daemon systemd
sudo systemctl daemon-reload

4. activer le service
sudo systemctl enable portainer.service

5. demarrer le service
sudo systemctl start portainer.service
