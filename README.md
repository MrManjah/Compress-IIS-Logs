# Archive des Fichiers Journaux IIS

## Description
Ce script PowerShell archive les fichiers journaux IIS en les compressant dans des fichiers ZIP. Les fichiers sont regroupés par mois et année, et les anciens fichiers sont déplacés vers un répertoire d'archives selon un délai de conservation spécifié.

## Fonctionnalités
- Archive les fichiers journaux IIS plus anciens qu'un délai de conservation spécifié.
- Compresse les fichiers journaux dans des fichiers ZIP organisés par mois et année.
- Crée les répertoires nécessaires pour l'archivage et le stockage temporaire.
- Supprime les fichiers journaux après archivage pour libérer de l'espace disque.

## Paramètres
- **LogRetentionDays** : Délai de conservation des logs en jours. Les fichiers journaux plus anciens que ce délai seront archivés. Par défaut, la valeur est de 90 jours.

## Prérequis
- PowerShell version 4.0 ou ultérieure.
- IIS (Internet Information Services) installé sur le système.

## Exemple d'utilisation
Pour exécuter le script et archiver les fichiers journaux plus anciens que 90 jours, utilisez la commande suivante :

```powershell
.\Export-IISLogFiles.ps1 -LogRetentionDays 90
