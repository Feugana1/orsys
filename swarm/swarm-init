
---

## 🧭 Introduction
Docker Swarm est l’orchestrateur natif de Docker.  
Il permet de regrouper plusieurs hôtes Docker (nœuds) en un **cluster**, d’y exécuter des **services répliqués**, et d’assurer **la tolérance de panne et la montée en charge**.

---

## ⚙️ Pré-requis
- Compte [Docker Hub](https://hub.docker.com/)
- Accès à [https://labs.play-with-docker.com](https://labs.play-with-docker.com)
- Notions de base en Docker : images, conteneurs, réseaux
- Navigateur Chrome/Firefox recommandé

---

## 🧩 TP1 – Création et découverte du cluster Swarm

### 🎯 Objectif
Créer un cluster Swarm à 3 nœuds et comprendre le rôle des managers et workers.

### 🧪 Étapes

1. **Connexion à l’environnement :**  
   Accéder à [https://labs.play-with-docker.com](https://labs.play-with-docker.com) et se connecter avec son compte Docker Hub.

2. **Création de 3 nœuds :**
   - `node1`
   - `node2`
   - `node3`

3. **Initialisation du cluster sur `node1` :**
   ```bash
   docker swarm init --advertise-addr 192.168.0.8
