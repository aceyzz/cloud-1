#!/bin/bash

# jaime bien les couleurs
C_GRAY="\033[1;30m"
C_GREEN="\033[0;32m"
C_RED="\033[0;31m"
C_YELLOW="\033[0;33m"
C_RESET="\033[0m"

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
SECRETS_SRC="/home/cedmulle/Desktop/.secrets"
LIST_FILE="$SCRIPT_DIR/list_secrets"

# prompt emplacement
read -rp "$(echo -e "${C_YELLOW}[?]${C_RESET} Chemin vers la racine du dépôt Git (défaut: ~/Desktop/cloud-1): ")" user_input
REPO_ROOT="$(realpath "${user_input:-$HOME/Desktop/cloud-1}")"

echo -e "${C_GRAY}[i]${C_RESET} Source secrets : $SECRETS_SRC"
echo -e "${C_GRAY}[i]${C_RESET} Destination     : $REPO_ROOT/project"

# check list
if [[ ! -f "$LIST_FILE" ]]; then
  echo -e "${C_RED}[✘ ]${C_RESET} Fichier list_secrets introuvable : $LIST_FILE"
  exit 1
fi

# copy secrets
while IFS= read -r rel_path || [[ -n "$rel_path" ]]; do
  src="$SECRETS_SRC/$rel_path"
  dest="$REPO_ROOT/project/$rel_path"

  if [[ ! -f "$src" ]]; then
    echo -e "${C_RED}[!]${C_RESET} Fichier absent : $src"
    continue
  fi

  echo -e "${C_GREEN}[+]${C_RESET} Copy $rel_path → $dest"
  mkdir -p "$(dirname "$dest")"
  cp -p "$src" "$dest"
done < "$LIST_FILE"

echo -e "${C_GREEN}[✔ ]${C_RESET} Initialisation des secrets terminée."
