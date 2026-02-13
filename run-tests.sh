#!/bin/bash

################################################################################
# Script d'exécution des tests unitaires pour projets multi-stack
# Détecte automatiquement le type de projet et exécute les tests appropriés
# Génère des rapports JUnit XML dans le répertoire test-results/
################################################################################

set -e  # Arrête le script en cas d'erreur (sauf gestion explicite)

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_RESULTS_DIR="${SCRIPT_DIR}/test-results"
ALL_TESTS_PASSED=true
declare -a TEST_RESULTS

################################################################################
# Fonctions utilitaires
################################################################################

print_header() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

################################################################################
# Fonction: setup_test_results_dir
# Description: Crée ou nettoie le répertoire des résultats de tests
################################################################################
setup_test_results_dir() {
    if [ -d "${TEST_RESULTS_DIR}" ]; then
        rm -rf "${TEST_RESULTS_DIR}"
    fi
    mkdir -p "${TEST_RESULTS_DIR}"
    print_success "Répertoire test-results créé: ${TEST_RESULTS_DIR}"
}

################################################################################
# Fonction: detect_project_type
# Description: Détecte le type de projet en fonction des fichiers présents
# Arguments: $1 - Chemin du répertoire du projet
# Retour: "gradle", "maven", "npm" ou "unknown"
################################################################################
detect_project_type() {
    local project_dir="$1"
    
    if [ -f "${project_dir}/build.gradle" ] || [ -f "${project_dir}/build.gradle.kts" ]; then
        echo "gradle"
    elif [ -f "${project_dir}/pom.xml" ]; then
        echo "maven"
    elif [ -f "${project_dir}/package.json" ]; then
        echo "npm"
    else
        echo "unknown"
    fi
}

################################################################################
# Fonction: run_gradle_tests
# Description: Exécute les tests pour un projet Gradle
# Arguments: $1 - Chemin du projet, $2 - Nom du projet
# Retour: 0 si succès, 1 si échec
################################################################################
run_gradle_tests() {
    local project_dir="$1"
    local project_name="$2"
    
    print_header "🧪 Exécution des tests Gradle pour: ${project_name}"
    
    cd "${project_dir}"
    
    # Détermine la commande gradlew selon l'OS
    local gradlew="./gradlew"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        gradlew="./gradlew.bat"
    fi
    
    # Rend le script exécutable si nécessaire (Unix-like)
    if [ -f "./gradlew" ]; then
        chmod +x ./gradlew 2>/dev/null || true
    fi
    
    # Exécute les tests
    if ${gradlew} clean test --info; then
        local test_result=0
    else
        local test_result=1
    fi
    
    # Copie les rapports de test
    local source_dir="${project_dir}/build/test-results/test"
    if [ -d "${source_dir}" ]; then
        local dest_dir="${TEST_RESULTS_DIR}/${project_name}"
        mkdir -p "${dest_dir}"
        
        if ls "${source_dir}"/*.xml 1> /dev/null 2>&1; then
            cp "${source_dir}"/*.xml "${dest_dir}/"
            print_success "Rapports JUnit XML copiés dans: ${dest_dir}"
        else
            print_warning "Aucun fichier XML trouvé dans: ${source_dir}"
        fi
    else
        print_warning "Aucun rapport de test trouvé dans: ${source_dir}"
    fi
    
    if [ ${test_result} -eq 0 ]; then
        print_success "Tests ${project_name} réussis!"
        return 0
    else
        print_error "Tests ${project_name} échoués!"
        return 1
    fi
}

################################################################################
# Fonction: run_npm_tests
# Description: Exécute les tests pour un projet npm/Angular
# Arguments: $1 - Chemin du projet, $2 - Nom du projet
# Retour: 0 si succès, 1 si échec
################################################################################
run_npm_tests() {
    local project_dir="$1"
    local project_name="$2"
    
    print_header "🧪 Exécution des tests npm pour: ${project_name}"
    
    cd "${project_dir}"
    
    # Vérifie si node_modules existe
    if [ ! -d "${project_dir}/node_modules" ]; then
        print_info "Installation des dépendances npm..."
        if npm ci --prefer-offline 2>/dev/null; then
            print_success "Dépendances installées avec npm ci"
        else
            print_warning "npm ci a échoué, tentative avec npm install..."
            npm install
        fi
    fi
    
    # Exécute les tests
    if npm test -- --watch=false --code-coverage=false; then
        local test_result=0
    else
        local test_result=1
    fi
    
    # Copie les rapports de test
    local source_dir="${project_dir}/reports"
    if [ -d "${source_dir}" ]; then
        local dest_dir="${TEST_RESULTS_DIR}/${project_name}"
        mkdir -p "${dest_dir}"
        
        # Copie tous les fichiers XML trouvés
        local xml_found=false
        while IFS= read -r -d '' xml_file; do
            cp "${xml_file}" "${dest_dir}/"
            print_success "Rapport copié: $(basename "${xml_file}")"
            xml_found=true
        done < <(find "${source_dir}" -name "*.xml" -type f -print0)
        
        if [ "${xml_found}" = true ]; then
            print_success "Rapports JUnit XML disponibles dans: ${dest_dir}"
        else
            print_warning "Aucun fichier XML trouvé dans: ${source_dir}"
        fi
    else
        print_warning "Aucun rapport de test trouvé dans: ${source_dir}"
    fi
    
    if [ ${test_result} -eq 0 ]; then
        print_success "Tests ${project_name} réussis!"
        return 0
    else
        print_error "Tests ${project_name} échoués!"
        return 1
    fi
}

################################################################################
# Fonction: run_tests_for_project
# Description: Exécute les tests pour un projet spécifique
# Arguments: $1 - Chemin du projet
################################################################################
run_tests_for_project() {
    local project_dir="$1"
    local project_name="$(basename "${project_dir}")"
    local project_type=$(detect_project_type "${project_dir}")
    
    case "${project_type}" in
        gradle)
            if run_gradle_tests "${project_dir}" "${project_name}"; then
                TEST_RESULTS+=("${project_name}:SUCCESS")
            else
                TEST_RESULTS+=("${project_name}:FAILURE")
                ALL_TESTS_PASSED=false
            fi
            ;;
        npm)
            if run_npm_tests "${project_dir}" "${project_name}"; then
                TEST_RESULTS+=("${project_name}:SUCCESS")
            else
                TEST_RESULTS+=("${project_name}:FAILURE")
                ALL_TESTS_PASSED=false
            fi
            ;;
        maven)
            print_warning "Type de projet Maven détecté mais non implémenté pour: ${project_name}"
            TEST_RESULTS+=("${project_name}:SKIPPED")
            ALL_TESTS_PASSED=false
            ;;
        *)
            print_warning "Type de projet inconnu pour: ${project_name}"
            TEST_RESULTS+=("${project_name}:UNKNOWN")
            ;;
    esac
}

################################################################################
# Fonction: discover_and_run_tests
# Description: Découvre et exécute les tests pour tous les projets
################################################################################
discover_and_run_tests() {
    print_info "Recherche des projets avec tests..."
    
    local projects_found=0
    declare -a projects_to_test
    
    # Recherche dans les sous-dossiers directs
    for item in "${SCRIPT_DIR}"/*; do
        if [ -d "${item}" ] && [[ "$(basename "${item}")" != .* ]]; then
            local project_type=$(detect_project_type "${item}")
            if [ "${project_type}" != "unknown" ]; then
                projects_to_test+=("${item}")
                print_success "Projet trouvé: $(basename "${item}") (Type: ${project_type})"
                ((projects_found++))
            fi
        fi
    done
    
    if [ ${projects_found} -eq 0 ]; then
        print_error "Aucun projet avec tests détecté!"
        return 1
    fi
    
    echo ""
    print_info "${projects_found} projet(s) détecté(s)"
    echo ""
    
    # Prépare le répertoire des résultats
    setup_test_results_dir
    echo ""
    
    # Exécute les tests pour chaque projet
    local original_dir="$(pwd)"
    for project_dir in "${projects_to_test[@]}"; do
        run_tests_for_project "${project_dir}"
        cd "${original_dir}"
        echo ""
    done
    
    # Affiche le résumé
    print_header "📊 RÉSUMÉ DES TESTS"
    
    for result in "${TEST_RESULTS[@]}"; do
        local project_name="${result%%:*}"
        local status="${result##*:}"
        
        case "${status}" in
            SUCCESS)
                echo -e "${GREEN}✅ RÉUSSI${NC} - ${project_name}"
                ;;
            FAILURE)
                echo -e "${RED}❌ ÉCHOUÉ${NC} - ${project_name}"
                ;;
            SKIPPED)
                echo -e "${YELLOW}⊘ IGNORÉ${NC} - ${project_name}"
                ;;
            *)
                echo -e "${YELLOW}? INCONNU${NC} - ${project_name}"
                ;;
        esac
    done
    
    echo ""
    print_info "Rapports JUnit XML disponibles dans: ${TEST_RESULTS_DIR}"
    print_header ""
}

################################################################################
# Point d'entrée principal
################################################################################
main() {
    echo -e "${BLUE}🚀 Démarrage de l'exécution des tests automatiques${NC}"
    echo ""
    
    discover_and_run_tests
    
    if [ "${ALL_TESTS_PASSED}" = true ]; then
        exit 0
    else
        exit 1
    fi
}

# Exécution du script
main "$@"
