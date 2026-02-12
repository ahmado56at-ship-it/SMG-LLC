# Script d'import vers GitHub
# Usage: ouvrir PowerShell dans le dossier racine du projet puis :
# .\import-to-github.ps1 -RemoteUrl 'https://github.com/ahmado56at-ship-it/SMG-LLC'
param(
    [string]$RemoteUrl
)
if (-not $RemoteUrl) {
    Write-Error "Veuillez fournir le paramètre -RemoteUrl"
    exit 1
}

# Vérifier git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git n'est pas installé ou n'est pas dans le PATH."
    exit 1
}

# Créer .gitignore si absent
if (-not (Test-Path .gitignore)) {
    @".env
node_modules/
uploads/
backups/
railway-variables.env
render-env-variables.txt
"@ | Out-File -Encoding UTF8 .gitignore
    Write-Output ".gitignore créé"
}

# Initialiser git si nécessaire
if (-not (Test-Path .git)) {
    git init
    git checkout -b main
}

# Ajouter tous les fichiers (respecte .gitignore)
git add .

git commit -m "Import initial du projet" -a --allow-empty || Write-Output "Rien à commit"

# Ajouter remote (remplace si existe)
if (git remote | Select-String origin) {
    git remote remove origin
}

git remote add origin $RemoteUrl

# Push (nécessite droits et auth configurée)
try {
    git push -u origin main --force
    Write-Output "Push complété vers $RemoteUrl"
} catch {
    Write-Error "Échec du push. Vérifiez vos droits GitHub et l'authentification."
}
