#!/bin/bash

# je t'ai dis, jaime bien les couleurs
C_GRAY="\033[1;30m"
C_GREEN="\033[0;32m"
C_RED="\033[0;31m"
C_YELLOW="\033[0;33m"
C_RESET="\033[0m"

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
LIST_FILE="$SCRIPT_DIR/list_secrets"

# prompt emplacement repo
read -rp "$(echo -e "${C_YELLOW}[?]${C_RESET} Chemin vers la racine du dépôt Git (défaut: ~/Desktop/cloud-1): ")" repo_input
REPO_ROOT="$(realpath "${repo_input:-$HOME/Desktop/cloud-1}")"

# prompt emplacement secrets
read -rp "$(echo -e "${C_YELLOW}[?]${C_RESET} Chemin vers le dossier .secrets (défaut: ~/Desktop/.secrets): ")" secrets_input
DEST="$(realpath "${secrets_input:-$HOME/Desktop/.secrets}")"

echo -e "${C_GRAY}[i]${C_RESET} Repo root  : $REPO_ROOT"
echo -e "${C_GRAY}[i]${C_RESET} Destination : $DEST"

mkdir -p "$DEST"

if [[ ! -f "$LIST_FILE" ]]; then
  echo -e "${C_RED}[✘]${C_RESET} Fichier list_secrets introuvable : $LIST_FILE"
  exit 1
fi

copied_files=()

# copy secrets
while IFS= read -r rel_path || [[ -n "$rel_path" ]]; do
  src="$REPO_ROOT/project/$rel_path"
  dest_path="$DEST/$rel_path"

  if [[ ! -f "$src" ]]; then
    echo -e "${C_RED}[!]${C_RESET} Fichier absent : $src"
    continue
  fi

  echo -e "${C_GREEN}[+]${C_RESET} Copy $rel_path → $dest_path"
  mkdir -p "$(dirname "$dest_path")"
  cp -p "$src" "$dest_path"

  copied_files+=("$src")
done < "$LIST_FILE"
echo -e "${C_GREEN}[✔]${C_RESET} Extraction des secrets terminée."

# prompt delete
read -rp "$(echo -e "${C_YELLOW}[?]${C_RESET} Supprimer les secrets dans le dossier source ? [y/N] ")" confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  for file in "${copied_files[@]}"; do
    echo -e "${C_RED}[-]${C_RESET} Suppression : $file"
    rm -f "$file"
  done
  echo -e "${C_GREEN}[✔ ]${C_RESET} Fichiers sources supprimés."
else
  echo -e "${C_GRAY}[i]${C_RESET} Aucun fichier supprimé."
fi
