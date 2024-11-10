<img src="git_utils/cloud1_banner.webp" alt="logo" style="width: 100%">
<img src="git_utils/cloud1_logo.png" alt="logo" style="width: 100%">

<br>

# CLOUD-1
Ce projet implémente un environnement WordPress complet en utilisant Docker Compose sur une infrastructure Azure avec des configurations de sécurité et de persistance des données. Il est conçu pour une gestion et un déploiement automatisés avec Ansible, offrant un environnement prêt à l'emploi pour un site WordPress sécurisé et scalable.

## Consignes :
> Le projet consiste à créer un environnement WordPress complet en utilisant des conteneurs Docker pour WordPress, MariaDB, phpMyAdmin, et Nginx, le tout déployé sur une VM Azure. Les conteneurs sont orchestrés avec Docker Compose et automatisés via Ansible pour le déploiement et la configuration. L'environnement utilise des certificats SSL pour sécuriser les connexions, et assure la persistance des données pour MariaDB et WordPress.

<br>

---

### Déploiement de l'environnement :
Le projet utilise Ansible pour automatiser l'installation et la configuration de l'environnement sur la VM Azure :
- Installe Docker et Docker Compose.
- Déploie les conteneurs WordPress, MariaDB, Nginx, et phpMyAdmin avec Docker Compose.
- Configure SSL avec des certificats pour sécuriser les connexions.

### Configuration des conteneurs :
Chaque conteneur est configuré pour un rôle spécifique :
- **MariaDB** : Fournit la base de données pour WordPress avec persistance des données.
- **WordPress** : L'application de gestion de contenu, accessible via Nginx.
- **Nginx** : Fonctionne en tant que serveur proxy et gère la sécurité SSL.
- **phpMyAdmin** : Permet la gestion de la base de données via une interface web.

### Synchronisation des données :
Les données de MariaDB et WordPress sont persistantes pour garantir la conservation des données après le redémarrage des conteneurs. Un fichier `.env` sécurisé est généré à partir de variables stockées avec Ansible Vault.

### Arrêt de l'environnement :
Un playbook Ansible dédié permet d'arrêter tous les conteneurs de manière sécurisée en exécutant la commande `docker-compose down` sur la VM.

## Résultat
L'environnement WordPress est accessible sur un domaine sécurisé et est entièrement fonctionnel pour des déploiements en production ou des environnements de test.

## Grade
> en cours...

## Licence
Accessible **[ici](./LICENSE)**.
