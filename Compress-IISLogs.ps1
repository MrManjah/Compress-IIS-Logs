# Vérification de l'installation de IIS
# (Get-WindowsFeature -name Web-Server).InstallState

# Import et définition des paramètres d'archivage
Add-Type -Assembly System.IO.Compression.FileSystem
$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal

# Définition de l'emaplacement des logs IIS
$logDir = "C:\inetpub\logs\LogFiles"

# Définition de l'emaplacement des archives
$ArchiveDir = "C:\inetpub\logs\LogFiles\Archives\"

# Définition de l'emaplacement de travail
$WorkDir = "C:\inetpub\logs\LogFiles\Temp\"

if (!(Test-Path $ArchiveDir)) {
    New-Item $ArchiveDir -type directory
    Write-Host "Création du répertoire $($ArchiveDir)" -ForegroundColor Green
}

# Définition du délai de rétention
$logLimit = (Get-Date).AddDays(-90)

# Récupération des fichiers plus anciens que le délai de rétention
$LogFiles = Get-ChildItem -Path $logDir -Filter *.log -Recurse | Where-Object { $_.LastWriteTime -lt $logLimit }
Write-Host "Nombre de fichier à archiver $($LogFiles.Count)" -ForegroundColor Green

# Grouper les fichiers par mois et année
$Groups = $LogFiles | Group-Object { $_.LastWriteTime.ToString("MM-yyyy") }

foreach ($Group in $Groups) {
    if (!(Test-Path $WorkDir)) {
        New-Item $WorkDir -type directory
        Write-Host "Création du répertoire $($WorkDir)" -ForegroundColor Green
    }
    # Génération du nom du fichier zip destination
    $zipfilename = $ArchiveDir + $Group.Name + ".zip"
    # Déplacement des fichiers dans le dossier de travail
    Write-Host "Archivage des fichiers dans $zipfilename" -ForegroundColor Green
    $Group.Group | Move-Item -Destination $WorkDir -Force
    # Archivage des fichiers dans le fichier destination
    [System.IO.Compression.ZipFile]::CreateFromDirectory($WorkDir, $zipfilename, $compressionLevel, $false)
    # Suppression du répertoire de travail
    Write-Host "Suppression du répertoire $($WorkDir)" -ForegroundColor Green
    $WorkDir | Remove-Item -Recurse -Force -Confirm:$false
}
