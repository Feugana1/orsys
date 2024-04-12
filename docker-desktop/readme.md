1. Docker
   
  Set up the repository

    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

  Install docker && Docker-compose
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  Install the latest docker desktop version
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  or you can simply use : curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh ./get-docker.sh --dry-run

2. Docker desktop
   Download the package
     curl https://desktop.docker.com/linux/main/amd64/145265/docker-desktop-4.29.0-x86_64.rpm?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64 -o docker-desktop-4.29.0-x86_64.rpm

   Install
     sudo dnf install ./docker-desktop-4.29.0-x86_64.rpm

   Activate the service
     systemctl --user enable docker-desktop

   Run docker desktop
     systemctl --user start docker-desktop
