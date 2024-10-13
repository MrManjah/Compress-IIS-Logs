# Vérification de l'installation de IIS 
# (Get-WindowsFeature -name Web-Server).InstallState

# Importation de l'assemblage pour la compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal

# Définition de l'emplacement des logs IIS
$logDir = "C:\inetpub\logs\LogFiles"

# Définition de l'emplacement des archives
$archiveDir = "C:\inetpub\logs\LogFiles\Archives\"

# Définition de l'emplacement de travail
$workDir = "C:\inetpub\logs\LogFiles\Temp\"

# Création du répertoire d'archives s'il n'existe pas
if (!(Test-Path $archiveDir)) {
    New-Item -Path $archiveDir -ItemType Directory
    Write-Host "Création du répertoire $($archiveDir)" -ForegroundColor Green
}

# Définition du délai de rétention (90 jours)
$logLimit = (Get-Date).AddDays(-90)

# Récupération des fichiers plus anciens que le délai de rétention
$logFiles = Get-ChildItem -Path $logDir -Filter *.log -Recurse | Where-Object { $_.LastWriteTime -lt $logLimit }
Write-Host "Nombre de fichiers à archiver : $($logFiles.Count)" -ForegroundColor Green

# Groupement des fichiers par mois et année
$groups = $logFiles | Group-Object { $_.LastWriteTime.ToString("MM-yyyy") }

foreach ($group in $groups) {
    # Création du répertoire de travail s'il n'existe pas
    if (!(Test-Path $workDir)) {
        New-Item -Path $workDir -ItemType Directory
        Write-Host "Création du répertoire $($workDir)" -ForegroundColor Green
    }

    # Génération du nom du fichier zip destination
    $zipFileName = Join-Path -Path $archiveDir -ChildPath "$($group.Name).zip"

    # Déplacement des fichiers dans le dossier de travail
    Write-Host "Archivage des fichiers dans $zipFileName" -ForegroundColor Green
    $group.Group | Move-Item -Destination $workDir -Force

    # Archivage des fichiers dans le fichier destination
    [System.IO.Compression.ZipFile]::CreateFromDirectory($workDir, $zipFileName, $compressionLevel, $false)

    # Suppression du répertoire de travail et de son contenu
    Write-Host "Suppression du répertoire $($workDir)" -ForegroundColor Green
    Remove-Item -Path $workDir -Recurse -Force -Confirm:$false
}

# Nettoyage : Si vous souhaitez supprimer le dossier de travail même s'il est vide
if (Test-Path $workDir) {
    Remove-Item -Path $workDir -Recurse -Force -Confirm:$false
}