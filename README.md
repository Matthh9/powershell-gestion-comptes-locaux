# powershell-gestion-comptes-locaux
Sujet :

Création d’un script personnalisé pour gérer les comptes locaux :

1. Concevoir un script personnalisé proposant des questions incluant tous les choix possibles pour les utilisateurs et groupes locaux, en fonction de l’ensemble des commandes disponibles dans le module système (prévoir si possible un algorithme pour orienter les questions).

Ex. de questions : Ajouter, Modifier ou Supprimer un utilisateur ? Saisir le nom : etc.
Activation ou Désactivation du compte (O/N) ? Ajout d’un mot de passe (O/N) ?
Ajouter dans un Nouveau groupe (N) ou groupe Existant (E) ?

Rappel : pour afficher les commandes disponibles de gestion des comptes locaux : Get-Command -Module Microsoft.PowerShell.LocalAccounts

2. Ajouter une option test de vérification du niveau de complexité du mot de passe, indiquant une indication du niveau pour chaque compte.
Ex. : niveau de complexité FORT-MOYEN-FAIBLE

Facultatif : si vous souhaitez aller plus loin, proposer aux niveaux faible et moyen un générateur de mots de passe complexes ...
