# Archive-IISLogFiles

Ce script PowerShell est conçu pour archiver les fichiers journaux IIS (Internet Information Services) en les compressant dans des fichiers ZIP, tout en gérant les fichiers plus anciens que 90 jours.

## Fonctionnalités principales

- **Vérification de l'installation d'IIS :** Le script inclut un contrôle de l'installation d'IIS, bien que ce contrôle soit commenté par défaut.
- **Gestion des répertoires :** 
  - Création d'un répertoire d'archives pour stocker les fichiers ZIP générés, s'il n'existe pas déjà.
  - Création d'un répertoire temporaire pour déplacer les fichiers journaux avant compression.
- **Filtrage des fichiers :** Le script recherche tous les fichiers journaux (`*.log`) dans le répertoire de logs IIS qui ont été modifiés il y a plus de 90 jours.
- **Groupement par date :** Les fichiers journaux sont regroupés par mois et année, facilitant l'organisation et la gestion des archives.
- **Compression :** Les fichiers de chaque groupe sont déplacés vers un répertoire temporaire, puis compressés en un fichier ZIP, avec un niveau de compression optimal.
- **Nettoyage :** Après l'archivage, le script supprime le répertoire temporaire utilisé pour le stockage des fichiers avant compression.

## Utilisation

Ce script est idéal pour les administrateurs système souhaitant gérer efficacement l'espace de stockage en archivant les anciens fichiers journaux IIS. Il contribue à maintenir un environnement de serveur propre et organisé tout en permettant un accès facile aux fichiers journaux archivés.
