# 🚀 Guide - Créer un Repository Git Unique

## Structure Actuelle
```
Projet 6/
├── back/          # Backend Java/Gradle
├── front/         # Frontend Angular
├── .github/
│   └── workflows/
│       └── ci.yml # Workflow CI/CD
├── run-tests.sh   # Script de tests
├── run-tests.ps1  # Script PowerShell
├── run-tests.py   # Script Python
└── .gitignore     # Fichier Git global
```

## 📋 Étapes pour GitHub

### 1. Initialiser le repository Git (si pas déjà fait)
```bash
cd "C:\Users\Cyprien\Desktop\OpenClassrooms\Projet 6 - Automatisez les tests et le release continus avec Docker"
git init
```

### 2. Ajouter tous les fichiers
```bash
git add .
```

### 3. Vérifier ce qui sera commit
```bash
git status
```

### 4. Créer le premier commit
```bash
git commit -m "Initial commit: Backend + Frontend + CI/CD"
```

### 5. Créer un repository sur GitHub
1. Allez sur https://github.com/new
2. Nom suggéré: `oc-projet6-cicd-docker`
3. Description: "Projet 6 OpenClassrooms - CI/CD avec Docker"
4. **Public** ou **Private** selon votre préférence
5. ❌ Ne pas initialiser avec README, .gitignore, ou license (déjà créés localement)
6. Cliquez sur "Create repository"

### 6. Lier votre repo local à GitHub
```bash
# Remplacez VOTRE_USERNAME par votre nom d'utilisateur GitHub
git remote add origin https://github.com/VOTRE_USERNAME/oc-projet6-cicd-docker.git

# Ou avec SSH (si configuré)
git remote add origin git@github.com:VOTRE_USERNAME/oc-projet6-cicd-docker.git
```

### 7. Renommer la branche en main (si nécessaire)
```bash
git branch -M main
```

### 8. Pousser votre code
```bash
git push -u origin main
```

## ✅ Vérifications

Une fois poussé, vérifiez sur GitHub :
- ✅ Les dossiers `back/` et `front/` sont présents
- ✅ Les workflows dans `.github/workflows/` sont détectés
- ✅ Onglet "Actions" est actif et montre le workflow CI
- ✅ Les fichiers `node_modules/` et `build/` sont ignorés

## 🔄 Workflow Automatique

Dès que vous pushez, GitHub Actions va automatiquement :
1. Exécuter les tests Backend (Gradle)
2. Exécuter les tests Frontend (npm)
3. Générer les rapports JUnit
4. Builder les deux applications
5. Afficher les résultats dans l'onglet "Actions"

## 🛠️ Commandes PowerShell (Windows)

Si vous préférez PowerShell :
```powershell
# Navigation
cd "C:\Users\Cyprien\Desktop\OpenClassrooms\Projet 6 - Automatisez les tests et le release continus avec Docker"

# Git init et premier commit
git init
git add .
git commit -m "Initial commit: Backend + Frontend + CI/CD"

# Ajout du remote (après création sur GitHub)
git remote add origin https://github.com/VOTRE_USERNAME/oc-projet6-cicd-docker.git
git branch -M main
git push -u origin main
```

## 📊 Résultat Final

Votre repository GitHub contiendra :
```
Repository: oc-projet6-cicd-docker
│
├── back/                    # Application Backend
│   ├── src/
│   ├── build.gradle
│   └── ...
│
├── front/                   # Application Frontend  
│   ├── src/
│   ├── package.json
│   └── ...
│
├── .github/workflows/       # CI/CD
│   └── ci.yml              # Pipeline automatique
│
├── Scripts de tests
│   ├── run-tests.sh
│   ├── run-tests.ps1
│   └── run-tests.py
│
└── Documentation
    ├── GUIDE-TESTS.md
    └── TESTS-README.md
```

## 🎯 Prochaines Étapes

Après le push :
1. Allez dans l'onglet **Actions** sur GitHub
2. Vous verrez le workflow "CI - Build & Test" s'exécuter
3. Cliquez dessus pour voir les logs en temps réel
4. Les rapports de tests seront disponibles en artifacts

## 🔐 Tokens et Secrets

Si vous avez des secrets (tokens GitLab, etc.) :
1. Allez dans Settings → Secrets and variables → Actions
2. Ajoutez vos secrets :
   - `GITLAB_PROJECT_ID`
   - `GITLAB_TOKEN`
   - Etc.

## ⚠️ Important

- Le fichier `token.txt` est ignoré par Git (dans .gitignore)
- Les dossiers `node_modules/` et `build/` sont ignorés
- Les résultats de tests (`test-results/`) sont ignorés

---

**Besoin d'aide ?** Vérifiez que vous avez Git installé avec `git --version`
