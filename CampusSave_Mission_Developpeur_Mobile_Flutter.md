# CAMPUSSAVE --- Cahier de mission du développeur Mobile (Flutter)

**Document à transmettre à Claude pour m'accompagner dans la réalisation
de ma partie Mobile.**\
**Projet :** CampusSave --- Plateforme intelligente de lutte contre le
gaspillage alimentaire\
**Formation :** 3ème année E-Business --- ESSECT\
**Date limite de dépôt :** 25 novembre 2026 à minuit\
**Mon rôle dans l'équipe :** Développeur de l'application Mobile avec
Flutter.

------------------------------------------------------------------------

## 1. Contexte du projet

CampusSave met en relation les étudiants universitaires avec les
restaurants et cafétérias situés à proximité de l'ESSECT. Les
commerçants publient leurs invendus alimentaires à prix réduits. Les
étudiants peuvent consulter les offres, réserver des produits, payer
électroniquement et récupérer leurs commandes en présentant un QR Code.

Le projet comprend deux applications clientes qui partagent les mêmes
données et le même backend :

-   **Application Web :** React.js --- développée par un autre membre de
    l'équipe.
-   **Application Mobile :** Flutter --- ma responsabilité.
-   **Backend commun :** Node.js / Express --- développé par un autre
    membre de l'équipe.
-   **Services Firebase :** Authentication, Firestore et Cloud
    Messaging.
-   **Paiement électronique :** solution telle que Konnect, en
    privilégiant le mode test.
-   **Gestion du code :** GitHub.

L'application mobile ne doit pas être un projet indépendant : elle doit
utiliser le même backend, les mêmes règles métier et les mêmes données
que l'application Web.

## 2. Ta mission en tant qu'assistant de développement

Agis comme un **développeur Flutter senior, pédagogue et patient**, qui
accompagne un étudiant de niveau intermédiaire.

Aide-moi à réaliser uniquement la partie Mobile, de la préparation du
projet jusqu'à sa livraison. Je veux apprendre et comprendre ce que je
fais, pas simplement recevoir un gros bloc de code.

### Règles de collaboration

1.  Avance étape par étape, dans l'ordre indiqué dans ce document.
2.  Ne passe pas à l'étape suivante tant que je n'ai pas confirmé que
    l'étape actuelle fonctionne.
3.  Pour chaque étape, explique brièvement son objectif et le résultat
    attendu.
4.  Donne les commandes exactes à exécuter dans le terminal et précise
    le dossier où les exécuter.
5.  Quand tu proposes du code, indique le chemin exact du fichier.
6.  Fournis le contenu complet des fichiers à créer ou à remplacer,
    plutôt que des fragments difficiles à assembler.
7.  Explique les parties importantes du code avec un langage adapté à un
    étudiant intermédiaire.
8.  Après chaque étape, donne une petite checklist de vérification.
9.  Si une erreur apparaît, demande-moi le message d'erreur complet et
    aide-moi à la corriger avant de continuer.
10. N'invente jamais les routes API, les champs de données, les clés ou
    les paramètres de paiement. Si une information manque, demande-moi
    ou propose un contrat provisoire clairement identifié comme tel.
11. Privilégie une solution simple, stable, lisible et réalisable dans
    le délai. Évite les architectures inutilement complexes.
12. Ne développe pas les fonctionnalités bonus avant que les
    fonctionnalités obligatoires soient terminées.

**Important :** commence par me poser uniquement les questions
indispensables pour connaître mon environnement actuel (Flutter installé
ou non, version, éditeur, appareil/émulateur disponible et état du dépôt
GitHub). Ensuite, commence la première étape. Ne me donne pas tout le
projet d'un seul coup.

------------------------------------------------------------------------

## 3. Fonctionnalités Mobile obligatoires

L'application Flutter doit permettre de couvrir les besoins des trois
acteurs du cahier des charges.

### A. Étudiant (Student)

-   Créer un compte et se connecter.
-   Se déconnecter.
-   Consulter et modifier les informations de son profil.
-   Consulter les offres alimentaires disponibles.
-   Voir les détails d'une offre : nom, description, photo, prix
    initial, prix réduit, quantité disponible et horaires de
    récupération.
-   Rechercher et filtrer les offres par produit, commerce, catégorie ou
    prix.
-   Choisir une quantité et réserver une offre.
-   Effectuer le paiement électronique via le parcours prévu avec
    Konnect en mode test.
-   Consulter ses commandes et leur statut.
-   Afficher le QR Code de récupération après confirmation effective du
    paiement.

### B. Commerçant (Merchant)

-   Créer un compte commerçant et se connecter.
-   Enregistrer les informations de son établissement.
-   Consulter le statut de validation de son commerce.
-   Consulter son tableau de bord.
-   Publier une offre avec photo, description, prix initial, prix
    réduit, quantité et horaires de récupération.
-   Modifier et supprimer ses propres offres.
-   Consulter et gérer les commandes liées à son commerce.
-   Scanner le QR Code présenté par l'étudiant.
-   Demander au backend de vérifier et valider la récupération d'une
    commande.

### C. Administrateur (Admin)

Le cahier des charges prévoit un espace administrateur permettant de
gérer les utilisateurs, valider les commerçants et superviser la
plateforme. Si l'équipe décide de rendre cet espace disponible sur
Mobile, prévoir les écrans correspondants :

-   Consulter les utilisateurs et les commerces.
-   Valider ou rejeter les inscriptions des commerçants.
-   Superviser les offres et les commandes.
-   Consulter des statistiques simples.

L'accès aux écrans et aux actions doit dépendre du rôle autorisé par le
backend. Ne jamais considérer qu'un simple contrôle d'interface suffit à
sécuriser une action.

------------------------------------------------------------------------

## 4. Technologies et packages

### Technologies imposées par le cahier des charges

-   Flutter / Dart pour l'application Mobile.
-   Node.js / Express pour le backend commun.
-   Firebase Authentication pour l'authentification.
-   Firebase Firestore pour la base de données.
-   Firebase Cloud Messaging pour les notifications.
-   GitHub pour le dépôt du code.

### Packages Flutter envisageables

Choisis des versions compatibles avec la version de Flutter installée.
N'ajoute que les packages réellement nécessaires.

-   `http` ou `dio` : communication avec l'API REST.
-   `firebase_core` : initialisation Firebase.
-   `firebase_auth` : authentification Firebase si le flux retenu
    l'utilise directement dans Flutter.
-   `firebase_messaging` : notifications push.
-   `provider` ou `flutter_riverpod` : gestion d'état simple ; choisir
    une seule solution.
-   `go_router` ou `Navigator` : navigation ; choisir une approche
    cohérente.
-   `image_picker` : sélection des photos d'offres.
-   `qr_flutter` : affichage du QR Code.
-   `mobile_scanner` : lecture du QR Code.
-   `shared_preferences` : uniquement pour les préférences non sensibles
    si nécessaire.

Ne stocke pas les mots de passe, les clés secrètes ou les secrets de
paiement dans l'application.

------------------------------------------------------------------------

## 5. Architecture et organisation du code Mobile

Commence avec une architecture claire mais adaptée à un projet étudiant.
Tu peux proposer des ajustements si tu les justifies.

Structure de départ suggérée :

``` text
mobile/
└── campus_save/
    ├── android/
    ├── assets/
    │   ├── images/
    │   └── icons/
    ├── lib/
    │   ├── main.dart
    │   ├── app.dart
    │   ├── config/
    │   │   ├── app_config.dart
    │   │   └── api_config.dart
    │   ├── models/
    │   │   ├── user_model.dart
    │   │   ├── restaurant_model.dart
    │   │   ├── offer_model.dart
    │   │   ├── order_model.dart
    │   │   └── payment_model.dart
    │   ├── services/
    │   │   ├── api_service.dart
    │   │   ├── auth_service.dart
    │   │   ├── offer_service.dart
    │   │   ├── order_service.dart
    │   │   └── payment_service.dart
    │   ├── providers/
    │   ├── screens/
    │   │   ├── splash/
    │   │   ├── auth/
    │   │   ├── student/
    │   │   ├── merchant/
    │   │   └── admin/
    │   ├── widgets/
    │   └── utils/
    ├── test/
    └── pubspec.yaml
```

Ne crée pas tous les fichiers vides dès le début. Construis cette
structure progressivement au moment où chaque fonctionnalité est
développée.

------------------------------------------------------------------------

## 6. Démarche de réalisation --- étape par étape

Respecte cet ordre. Les dates sont indicatives et doivent être adaptées
à l'avancement réel de l'équipe.

### PHASE 1 --- Préparation Mobile

#### Étape 1 : Vérifier l'environnement

-   Vérifier Flutter avec `flutter --version`.
-   Vérifier Dart avec `dart --version`.
-   Exécuter `flutter doctor`.
-   Vérifier Android Studio et les outils Android.
-   Vérifier qu'un émulateur ou un téléphone Android est disponible.
-   Vérifier VS Code et ses extensions Flutter/Dart.

**Livrable :** environnement Flutter fonctionnel.

#### Étape 2 : Créer et lancer le projet

-   Se placer dans le dossier prévu pour le Mobile.
-   Créer le projet avec `flutter create campus_save`.
-   Ouvrir le projet dans l'éditeur.
-   Lancer l'application de départ.
-   Vérifier qu'elle fonctionne sur l'émulateur ou le téléphone.

**Livrable :** application Flutter de base qui démarre correctement.

#### Étape 3 : Préparer l'identité visuelle et la navigation

-   Définir les couleurs, typographies, boutons, champs et cartes.
-   Créer un thème global.
-   Préparer les écrans de navigation.
-   Prévoir une interface responsive adaptée aux téléphones.
-   Préparer les états de chargement, d'erreur et de liste vide.

**Livrable :** base UI cohérente et navigation initiale.

#### Étape 4 : Préparer Git et GitHub

-   Relier le dossier Mobile au dépôt de l'équipe.
-   Travailler dans une branche dédiée, par exemple `feature/mobile`.
-   Ajouter les fichiers nécessaires au `.gitignore`.
-   Faire un premier commit.
-   Ne jamais pousser de fichier contenant des secrets.

**Livrable :** partie Mobile versionnée sur GitHub.

### PHASE 2 --- Authentification et données

#### Étape 5 : Configurer Firebase dans Flutter

-   Créer ou récupérer le projet Firebase partagé par l'équipe.
-   Enregistrer l'application Android dans Firebase.
-   Configurer FlutterFire si nécessaire.
-   Ajouter `google-services.json` à l'emplacement Android prévu.
-   Initialiser Firebase dans `main.dart`.
-   Vérifier le démarrage sans erreur.

Ne crée pas un deuxième projet Firebase si l'équipe en possède déjà un.

**Livrable :** Flutter connecté au projet Firebase commun.

#### Étape 6 : Développer l'authentification

-   Construire les écrans Login et Register.
-   Ajouter les validations des formulaires.
-   Connecter Firebase Authentication selon le flux choisi par l'équipe.
-   Gérer la session et la déconnexion.
-   Récupérer le profil et le rôle de l'utilisateur.
-   Rediriger vers l'espace correspondant au rôle.

**Livrable :** connexion et navigation selon les rôles.

#### Étape 7 : Définir les modèles et connecter l'API

-   Créer les modèles Dart pour User, Restaurant, Offer, Order et
    Payment.
-   Définir la configuration de l'URL de base de l'API.
-   Créer le service HTTP.
-   Ajouter la gestion des erreurs et des délais d'attente.
-   Ajouter le Firebase ID Token dans les requêtes protégées si le
    backend utilise ce mécanisme.
-   Tester une première requête réelle.

**Livrable :** communication entre Flutter et le backend.

**Dépendance équipe :** demander au développeur Backend l'URL de l'API,
les routes, les formats JSON, les statuts HTTP et le mécanisme
d'authentification.

#### Étape 8 : Construire les écrans communs

-   Splash Screen.
-   Gestion des sessions.
-   Navigation selon le rôle.
-   Profil utilisateur.
-   Messages de succès et d'erreur.
-   Gestion des chargements.

**Livrable :** socle commun de l'application Mobile.

### PHASE 3 --- Fonctionnalités métier

#### Étape 9 : Développer l'espace Étudiant

-   Créer l'écran d'accueil.
-   Afficher les offres disponibles depuis l'API.
-   Créer les cartes d'offres avec photo, prix et réduction.
-   Ajouter les détails d'une offre.
-   Ajouter recherche et filtres.
-   Gérer les états : chargement, erreur, aucun résultat.
-   Actualiser les données après une action.

**Livrable :** étudiant capable de découvrir les offres.

#### Étape 10 : Développer la réservation et les commandes

-   Permettre de choisir une quantité.
-   Vérifier la disponibilité affichée.
-   Envoyer la demande de réservation au backend.
-   Afficher le résultat de la réservation.
-   Créer l'écran Mes commandes.
-   Afficher les statuts de commande.
-   Gérer les erreurs de stock et les réservations refusées.

Le backend reste responsable de la vérification finale du stock, du
calcul du montant et de la création fiable de la commande.

**Livrable :** étudiant capable de réserver et de suivre une commande.

#### Étape 11 : Développer le paiement côté Mobile

-   Créer l'écran de récapitulatif de commande.
-   Afficher le montant fourni ou confirmé par le backend.
-   Demander au backend de créer une session de paiement.
-   Ouvrir le lien de paiement officiel retourné par le backend, selon
    la méthode validée par l'équipe.
-   Afficher un écran de retour après le paiement.
-   Actualiser le statut auprès du backend.

Ne mets jamais la clé secrète Konnect dans Flutter. Ne considère jamais
une redirection de succès comme une preuve de paiement : seul le backend
doit confirmer le paiement.

**Livrable :** parcours de paiement de test utilisable depuis Mobile.

#### Étape 12 : Développer l'espace Commerçant

-   Afficher le tableau de bord commerçant.
-   Afficher ses propres offres.
-   Créer une offre.
-   Sélectionner une photo.
-   Saisir titre, description, catégorie, prix initial, prix réduit,
    quantité et horaires de récupération.
-   Modifier et supprimer ses propres offres.
-   Afficher les commandes de son commerce.
-   Afficher les détails et le statut des commandes.

**Livrable :** commerçant capable de gérer ses offres et de suivre les
commandes.

#### Étape 13 : Générer et scanner les QR Codes

-   Afficher le QR Code de la commande uniquement après confirmation du
    paiement par le backend.
-   Utiliser le token ou identifiant sécurisé fourni par le backend.
-   Ajouter un écran de scan pour le commerçant.
-   Lire le QR Code avec la caméra.
-   Envoyer le contenu au backend pour vérification.
-   Afficher le résultat de validation.
-   Gérer les QR Codes invalides, expirés ou déjà utilisés.

Le QR Code ne doit pas contenir de données personnelles sensibles ni
être accepté comme preuve autonome. Le backend doit contrôler le
paiement et empêcher une double récupération.

**Livrable :** parcours de récupération par QR Code.

#### Étape 14 : Ajouter les fonctions complémentaires obligatoires restantes

-   Ajouter les tableaux de bord simples pour les rôles concernés.
-   Intégrer les notifications Firebase Cloud Messaging si le backend
    les prend en charge.
-   Vérifier les validations des formulaires.
-   Vérifier les autorisations et les états d'erreur.
-   Vérifier que l'interface est utilisable sur différentes tailles
    d'écran.

**Livrable :** fonctionnalités Mobile prévues par le cahier des charges
intégrées.

### PHASE 4 --- Tests et livraison

#### Étape 15 : Tester l'application Mobile

Effectuer au minimum les tests suivants :

-   Inscription et connexion.
-   Déconnexion et reprise de session.
-   Navigation selon le rôle.
-   Affichage des offres.
-   Recherche et filtres.
-   Création et modification d'offre par un commerçant.
-   Réservation d'une quantité disponible.
-   Refus d'une réservation lorsque le stock est insuffisant.
-   Paiement de test réussi et échoué.
-   Affichage du QR Code après confirmation réelle.
-   Scan et validation d'une commande.
-   Refus d'un QR Code déjà utilisé.
-   Gestion des erreurs réseau.
-   Vérification des autorisations.

Tester sur émulateur et, si possible, sur un vrai téléphone Android.

#### Étape 16 : Finaliser et livrer la partie Mobile

-   Corriger les bugs bloquants.
-   Vérifier les noms et l'organisation des fichiers.
-   Retirer les données de test inutiles.
-   Vérifier qu'aucune clé secrète n'est présente dans le dépôt.
-   Vérifier que l'application se lance depuis une installation propre.
-   Mettre à jour les instructions Mobile du README.
-   Faire les commits et pousser la branche sur GitHub.
-   Préparer une démonstration du parcours étudiant et commerçant.
-   Remettre le code source Flutter à l'équipe.

**Livrable final :** application Mobile Flutter fonctionnelle, code
source sur GitHub et instructions d'exécution.

------------------------------------------------------------------------

## 7. Contrats à obtenir auprès des autres membres de l'équipe

Pour éviter les blocages, je dois demander ces informations aux autres
développeurs.

### Au développeur Backend

-   URL de base de l'API (locale puis hébergée).
-   Liste des routes et méthodes HTTP.
-   Exemples de requêtes et réponses JSON.
-   Format des erreurs.
-   Méthode de vérification des Firebase ID Tokens.
-   Règles et valeurs possibles des rôles.
-   Champs et statuts des offres, commandes et paiements.
-   Route de création de paiement et mécanisme de vérification.
-   Route de validation du QR Code.

### Au développeur Web / responsable UI-UX

-   Maquettes Figma.
-   Logo et couleurs de CampusSave.
-   Noms et descriptions des écrans.
-   Règles de navigation.
-   Comportements attendus des composants communs.

### À toute l'équipe

-   Nom du projet Firebase partagé.
-   Convention de nommage des champs et des statuts.
-   Organisation du dépôt GitHub.
-   Répartition des responsabilités.
-   Procédure de fusion des branches.

Si ces informations ne sont pas encore disponibles, aide-moi à préparer
une proposition de contrat API à faire valider par l'équipe. Ne
développe pas une intégration définitive sur des hypothèses non
confirmées.

------------------------------------------------------------------------

## 8. Priorités en cas de manque de temps

La date limite est proche. Il faut privilégier une application
réellement fonctionnelle plutôt qu'une application avec beaucoup
d'écrans incomplets.

### Priorité 1 --- Indispensable

1.  Application Flutter qui démarre.
2.  Authentification et rôles.
3.  Affichage des offres.
4.  Création et gestion des offres par le commerçant.
5.  Réservation et consultation des commandes.
6.  Connexion au backend commun.

### Priorité 2 --- Fonctionnalités métier essentielles

7.  Paiement Konnect en mode test.
8.  QR Code après confirmation du paiement.
9.  Scan et validation de récupération.
10. Tableaux de bord simples.

### Priorité 3 --- Finition

11. Notifications.
12. Amélioration graphique.
13. Tests complémentaires.
14. Optimisation et documentation.

Les fonctionnalités bonus (Campus Radar, Surprise Basket, EcoPoints et
Impact Dashboard) ne doivent être envisagées qu'après la réalisation des
fonctionnalités obligatoires.

------------------------------------------------------------------------

## 9. Critères de réussite de ma partie Mobile

Ma partie est considérée comme prête lorsque :

-   [ ] Le projet Flutter s'exécute sans erreur bloquante.
-   [ ] L'utilisateur peut se connecter et accéder à son espace.
-   [ ] Les données affichées proviennent du backend commun.
-   [ ] L'étudiant peut consulter les offres et réserver.
-   [ ] Le commerçant peut gérer ses offres et ses commandes.
-   [ ] Le parcours de paiement de test est intégré.
-   [ ] Le QR Code n'apparaît qu'après confirmation du paiement.
-   [ ] Le commerçant peut scanner et valider une commande.
-   [ ] Les rôles et les autorisations sont respectés.
-   [ ] Les données sont cohérentes avec l'application Web.
-   [ ] Le code est poussé sur GitHub.
-   [ ] Les instructions d'installation et d'exécution sont documentées.

------------------------------------------------------------------------

## 10. Première réponse attendue de Claude

Commence par :

1.  Résumer ma mission Mobile en quelques lignes.
2.  Me demander les informations indispensables sur mon environnement
    Flutter et mon dépôt GitHub.
3.  Me dire exactement quels outils et logiciels vérifier.
4.  Me guider dans l'étape 1, sans sauter directement au développement
    des écrans.
5.  Attendre mes retours et vérifier chaque résultat avant de continuer.

**Rappel :** je suis étudiant en 3ème année E-Business à l'ESSECT, avec
un niveau intermédiaire. Je souhaite un accompagnement pratique,
progressif et professionnel, avec des explications simples, des
commandes exactes et du code prêt à tester.
