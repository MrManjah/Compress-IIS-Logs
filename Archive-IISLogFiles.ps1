#requires -version 5
<#
.SYNOPSIS
  Archive les fichiers journaux IIS en les compressant dans des fichiers ZIP.
.DESCRIPTION
  Ce script PowerShell archive les fichiers journaux IIS qui sont plus anciens qu'un certain délai de conservation. Les fichiers sont compressés par mois et année, et les anciens fichiers sont déplacés vers un répertoire d'archives.
.PARAMETER LogRetentionDays
  Délai de conservation des logs en jours. Les fichiers journaux plus anciens que ce délai seront archivés.
.INPUTS
  Aucune
.OUTPUTS
  Fichiers ZIP contenant les fichiers journaux archivés.
.NOTES
  Version:        1.0
  Author:         MrManjah
  Creation Date:  14/10/2024
  Purpose/Change: Initial script development
.EXAMPLE
  .\Export-IISLogFiles.ps1 -LogRetentionDays 90
  
  Cette commande exécutera le script pour archiver les fichiers journaux IIS plus anciens que 90 jours.
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
    [int]$LogRetentionDays = 90  # Délai de conservation des logs en jours
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

# Import Modules & Snap-ins
Add-Type -AssemblyName System.IO.Compression.FileSystem

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Any Global Declarations go here
$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
$logDir = "C:\inetpub\logs\LogFiles"
$archiveDir = "C:\inetpub\logs\LogFiles\Archives\"
$workDir = "C:\inetpub\logs\LogFiles\Temp\"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Export-IISLogFiles {
    Param (
        [int]$LogRetentionDays
    )
  
    Begin {
        Write-Host "Initialisation de l'archivage des fichiers journaux IIS..."
    }

    Process {
        # Création des répertoires si nécessaire
        if (!(Test-Path $archiveDir)) {
            New-Item -Path $archiveDir -ItemType Directory
            Write-Host "Création du répertoire $($archiveDir)" -ForegroundColor Green
        }

        if (!(Test-Path $workDir)) {
            New-Item -Path $workDir -ItemType Directory
            Write-Host "Création du répertoire $($workDir)" -ForegroundColor Green
        }

        # Définition du délai de rétention
        $logLimit = (Get-Date).AddDays(-$LogRetentionDays)

        # Récupération des fichiers plus anciens que le délai de rétention
        $logFiles = Get-ChildItem -Path $logDir -Filter *.log -Recurse | Where-Object { $_.LastWriteTime -lt $logLimit }
        Write-Host "Nombre de fichiers à archiver : $($logFiles.Count)" -ForegroundColor Green

        # Groupement des fichiers par mois et année
        $groups = $logFiles | Group-Object { $_.LastWriteTime.ToString("MM-yyyy") }

        foreach ($group in $groups) {
            # Génération du nom du fichier zip destination
            $zipFileName = Join-Path -Path $archiveDir -ChildPath "$($group.Name).zip"

            # Déplacement des fichiers dans le dossier de travail
            Write-Host "Archivage des fichiers dans $zipFileName" -ForegroundColor Green
            $group.Group | Move-Item -Destination $workDir -Force

            # Archivage des fichiers dans le fichier destination
            [System.IO.Compression.ZipFile]::CreateFromDirectory($workDir, $zipFileName, $compressionLevel, $false)

            # Suppression du répertoire de travail
            Write-Host "Suppression du répertoire $($workDir)" -ForegroundColor Green
            Remove-Item -Path $workDir -Recurse -Force -Confirm:$false
        }

        # Nettoyage : Si vous souhaitez supprimer le dossier de travail même s'il est vide
        if (Test-Path $workDir) {
            Remove-Item -Path $workDir -Recurse -Force -Confirm:$false
        }
    }

    End {
        If ($?) {
            Write-Host 'Archivage terminé avec succès.' -ForegroundColor Green
            Write-Host ' '
        }
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Appel de la fonction d'archivage
Export-IISLogFiles -LogRetentionDays $LogRetentionDays
