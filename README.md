<img title="42_cloud-1" alt="42_cloud-1" src="./utils/banner.png" width="100%">

<br>

## Index

- [Consigne](#consigne)
- [Architecture](#architecture)
- [Partie Ansible](#partie-ansible)
- [Partie Docker](#partie-docker)

<br>

## Consigne

- 42 ne fournit pas les serveurs nécessaires pour exécuter votre application. Tout votre code devra être hébergé sur des serveurs en dehors de l’école, que vous devrez obtenir (et payer) par vous-même.  
- Ce projet nécessite un accès à des ressources cloud. Plusieurs options sont possibles selon vos besoins et les opportunités disponibles.  
- Le déploiement de votre application doit être entièrement automatisé. Il est suggéré d’utiliser Ansible, mais vous êtes libre d’utiliser un autre outil si vous le souhaitez.  
- Il est impératif de fournir un site fonctionnel équivalent à celui obtenu avec Inception, uniquement grâce à votre script.  
- Vous devez installer un site WordPress simple sur une instance.  
- Vous devez vous assurer que :  
  • Votre site peut redémarrer automatiquement si le serveur redémarre.  
  • En cas de redémarrage, toutes les données du site sont conservées (images, comptes utilisateurs, articles, ...).  
  • Il est possible de déployer votre site sur plusieurs serveurs en parallèle.  
  • Le script doit pouvoir fonctionner de manière automatisée, en supposant uniquement que l’instance cible tourne sous Ubuntu 20.04 LTS (ou équivalent), avec un démon SSH actif et Python installé.  
  • Vos applications doivent s’exécuter dans des conteneurs séparés capables de communiquer entre eux (1 processus = 1 conteneur).  
  • L’accès public à votre serveur doit être limité et sécurisé (par exemple, il ne doit pas être possible de se connecter directement à la base de données depuis Internet).  
  • Les services à déployer sont les différents composants d’un WordPress que vous devez installer vous-même (par exemple : PhpMyAdmin, MySQL, ...).  
  • Vous devez avoir un fichier `docker-compose.yml`.  
  • Vous devez vérifier que votre base SQL fonctionne avec WordPress et PhpMyAdmin.  
  • Votre serveur doit pouvoir, si possible, utiliser TLS.  
  • Vous devez vous assurer que, selon l’URL demandée, votre serveur redirige vers le bon site.  

- Le rendu du projet se fait dans votre dépôt Git, comme d’habitude. Seuls les fichiers contenus dans ce dépôt seront évalués lors de la soutenance. Vérifiez bien les noms de vos dossiers et fichiers.  
- Aucun jeu bonus n’est demandé.  
- L’apparence du site ne sera pas jugée en détail : un WordPress de base suffit.  
- Un nom de domaine mémorable n’est pas obligatoire, mais apprécié, surtout s’il permet un accès HTTPS.

<br>

## Architecture

<table>
  <tr>
    <td rowspan="3" align="center" valign="middle">
      <img src="./utils/architecture.png" width="100%" alt="Architecture Diagram"/>
    </td>
    <td>
      <strong>1. Hôte Ansible (VM locale)</strong><br/>
      VM Debian 12.11 avec environnement LXQt, lancée sur Oracle VirtualBox.<br/>
      Elle agit comme machine de contrôle Ansible :<br/>
      - Contient tous les fichiers du projet (Ansible, Docker Compose, .env)<br/>
      - Accès sécurisé via Tailscale VPN<br/>
      - Git installé pour la version<br/>
      - UFW pour limiter les connexions<br/>
      Cette VM permet d’orchestrer le déploiement de manière isolée, sans exposer l’hôte physique.
    </td>
  </tr>
  <tr>
    <td>
      <strong>2. Azure VM (hôte cible)</strong><br/>
      Ubuntu Server 24.04 Amd64, node managée via Ansible.<br/>
      - Exécutée dans le cloud, sans IP publique par défaut<br/>
      - Connexion SSH sécurisée via Tailscale<br/>
      - Ports ouverts : 80 (HTTP) et 443 (HTTPS) uniquement<br/>
      - Stack Docker déployée automatiquement (WordPress, MariaDB, Nginx, PhpMyAdmin)<br/>
      - Certificats HTTPS Let’s Encrypt valides pour le domaine HTTPS, ou self-signed si pas de domaine<br/>
    </td>
  </tr>
  <tr>
    <td>
      <strong>3. Réseau privé et Internet</strong><br/>
      - Toutes les connexions entre la VM Ansible et la VM Azure passent par un tunnel VPN (Tailscale)<br/>
      - L’accès public au site WordPress est disponible uniquement en HTTPS<br/>
      - Aucun autre service exposé a part Nginx et PhpMyAdmin<br/>
      - Le déploiement est reproductible, sécurisé et sans ouverture de ports SSH vers Internet.
    </td>
  </tr>
</table>

<br>

## Dossier Ansible

Ce dossier contient tout le nécessaire pour déployer automatiquement l’application via Ansible.

- `playbook.yml` : Playbook principal. Enchaîne les différents rôles dans l’ordre logique du déploiement (préparation, installation, lancement…).
- `cleanup.yml` : Playbook secondaire pour nettoyer les machines (arrêt, suppression des conteneurs, images, volumes...).

### Inventaire

- `inventory/inventory.ini` : Définit les hôtes cibles du projet. Chaque serveur est classé dans un groupe `[nom-du-groupe]`.

### Variables globales

- `group_vars/all.yml` : Contient les variables communes à tous les hôtes (chemin local du projet, dossier distant, etc).

### Rôles

Chaque rôle est structuré avec ses propres tâches (`tasks/main.yml`) et respecte une séparation claire des responsabilités :

- `check_dependencies` : Vérifie la présence de paquets nécessaires sur la machine distante (python, curl, unzip…).
- `prepare_system` : Configure le système distant (UFW, création des répertoires, update du système, etc.).
- `ensure_docker` : Installe Docker et ses plugins (Compose v2), configure les dépôts officiels.
- `create_app_dir` : Crée le dossier d’application `cloud-1` sur le serveur, s’assure de sa propreté.
- `deploy_app_files` : Copie les fichiers depuis la machine Ansible vers la VM cible (`docker-compose.yml`, `.env`, volumes...).
- `check_app_config` : Vérifie la validité de la configuration `docker-compose` avant lancement.
- `launch_app` : Lance l’application avec `docker compose up -d`.
- `cleanup_app` : Contient plusieurs sous-tâches pour :
  - `stop.yml` : Arrêter les conteneurs
  - `stop_and_remove.yml` : Arrêt + suppression des volumes
  - `reset.yml` : Suppression complète (conteneurs, images, volumes, répertoire distant)

### Sécurité & bonnes pratiques

- Les fichiers `.env` sensibles sont chiffrés avec Ansible Vault et déployés dynamiquement selon le serveur.
- Aucun port SSH public n’est ouvert : la connexion passe uniquement via Tailscale VPN.
- Seuls les ports 80 (HTTP) et 443 (HTTPS) sont exposés côté VM cloud pour la publication de l’application.

### Makefile

Un Makefile est disponible à la racine du projet. Il simplifie l’utilisation d’Ansible.

Permet de lancer les commandes principales du déploiement sans avoir à retenir toute la syntaxe Ansible.

- `make` ou `make help` : Affiche la liste des commandes disponibles.
- `make init` : Prépare l’environnement (importe les secrets et certificats).
- `make deploy` : Lance le déploiement complet avec le playbook principal.
- `make stop` : Arrête les conteneurs, mais ne supprime rien.
- `make delete` : Arrête les conteneurs et supprime les volumes (les images restent).
- `make reset` : Supprime tout : conteneurs, images, volumes et le dossier distant.
- `make clean` : Backup les secrets du projet, et les supprimes (utile avant de push).

Chaque commande gère automatiquement les options nécessaires, comme le déchiffrement des fichiers sensibles (`--ask-vault-pass`) ou l’élévation des privilèges (`--ask-become-pass`).


<br>

## Partie Docker

L’application utilise Docker Compose pour orchestrer 4 services. Tous sont connectés au même réseau interne Docker.

### Nginx

- Sert de point d’entrée HTTPS pour l’application.
- Redirige le HTTP vers HTTPS.
- Injection automatique de variables dans le fichier de configuration via `envsubst`.
- Utilise des certificats SSL (Let’s Encrypt) ou self signed (selon SERVER_NAME definit dans l'env) montés depuis `nginx/ssl`.
- Logs stockés dans `logs/nginx`.
- Expose les ports 80 (HTTP) et 443 (HTTPS).

### WordPress

- Contient l’application WordPress.
- Se connecte à MariaDB avec les identifiants fournis en variables d’environnement.
- Expose uniquement le port 80 en interne (dans le réseau Docker).
- Volume persistant : `wordpress/`

### MariaDB

- Base de données MySQL utilisée par WordPress.
- Initialisée avec un mot de passe root et un utilisateur, via `.env`.
- Volume persistant dans `mariadb/`
- Logs dans `logs/mariadb/`
- Ne doit jamais être exposée à l’extérieur.

### PhpMyAdmin

- Interface de gestion MariaDB via navigateur.
- Reliée à `mariadb` automatiquement.
- Mot de passe root transmis via `.env`.
- Expose le port 8080 pour l’accès web depuis Internet.

### Réseau Docker

- Tous les services communiquent via un réseau privé Docker.
- Aucun conteneur (hors Nginx et PhpMyAdmin) n’est accessible directement de l’extérieur.
- VM Cloud configurable pour limiter les IPs autorisées à accéder aux ports exposés (comme PhpMyAdmin par ex.)

### Fichiers `.env`

- Un fichier `.env` principal contient les variables communes à tous les conteneurs.
- Chaque hôte défini dans l’inventaire Ansible doit également posséder son propre fichier `.env` chiffré (via Ansible Vault), utilisé pour configurer les éléments sensibles et spécifiques à l’environnement (certificats SSL, serveur name pour nginx)
