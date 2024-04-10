#!/bin/bash

# Vérification des paramètres
if [ $# -ne 3 ]; then
    echo "Usage: $0 <chemin_vers_Dockerfile> <nom_de_l_image> <tag>"
    exit 1
fi

DOCKERFILE_PATH=$1
IMAGE_NAME=$2
TAG=$3

# Vérification de l'existence du fichier Dockerfile
if [ ! -f "$DOCKERFILE_PATH" ]; then
    echo "Le fichier Dockerfile n'existe pas : $DOCKERFILE_PATH"
    exit 1
fi

# Construction de l'image Docker
docker build -t "$IMAGE_NAME:$TAG" -f "$DOCKERFILE_PATH" .
