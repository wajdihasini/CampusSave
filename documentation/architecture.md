# CampusSave — Architecture, Schéma Firestore Réel et API REST

## 1. Collections Cloud Firestore (`campussave`, région `eur3`)
- `users/{uid}` : `name`, `email`, `role` (`student` | `merchant` | `admin`), `blocked` (bool), `createdAt` (int64 ms), `fcmToken` (optionnel)
- `shops/{shopId}` : `ownerId`, `name`, `address`, `phone`, `description`, `approved` (bool), `createdAt` (int64 ms)
- `offers/{offerId}` : `shopId`, `title`, `category`, `originalPrice`, `price`, `quantity`, `pickupFrom`, `pickupTo`, `photo`, `createdAt` (int64 ms)
- `orders/{orderId}` : `offerId`, `shopId`, `studentId`, `studentName`, `title`, `quantity`, `total`, `originalTotal`, `status` (`reserved` | `paid` | `collected` | `cancelled` | `expired`), `createdAt`, `expiresAt`, `releasedAt`, `paymentRef`, `qrToken`, `qrDataUrl`

## 2. Organisation de l'application Mobile Flutter (`mobile/lib/`)
- `config/app_config.dart` : URL du backend Express (`http://10.0.2.2:5000/api`) et configuration Firebase Android.
- `models/models.dart` : Modèles `AppUser`, `Shop`, `Offer`, `CampusOrder` alignés 100 % sur Firestore.
- `services/auth_service.dart` : Authentification Firebase Auth + création/lecture profil `users/{uid}` + token FCM.
- `services/api_service.dart` : Appels REST sécurisés (Bearer Firebase ID Token) vers le backend Express.
- `providers/app_provider.dart` : Gestion d'état (`ChangeNotifier`) pour les 3 rôles.
- `screens/` : `login_screen.dart`, `student_home_screen.dart`, `offer_detail_screen.dart`, `merchant_home_screen.dart`, `admin_home_screen.dart`.
- `widgets/offer_card.dart` : Carte d'offre réutilisable.

## 3. Organisation du dépôt
- `web/` : React + Vite + Tailwind. `server.ts` + `server/` forment un **serveur de démo** (données dans `.data/`, auth locale, QR et Konnect simulables) pour travailler sans Firebase.
- `backend/` : API de production (Firebase Auth + Firestore), port 5000, préfixe `/api`.
- `mobile/` : Flutter, appelle `backend/` avec le Firebase ID Token (`Authorization: Bearer`).
- `documentation/mobile-commercant-admin/` : écrans Flutter commerçant/admin et `AppProvider` à intégrer dans `mobile/lib/` (non branchés pour ne pas modifier le package du collègue).

## 4. Routes REST de `backend/` (préfixe `/api`)
| Méthode | Route | Rôle |
|---|---|---|
| GET | `/health` | public |
| GET | `/me` | tout utilisateur connecté (renvoie `role`) |
| GET / POST | `/shops` | public / commerçant |
| GET / POST | `/offers` | public / commerçant |
| PUT / DELETE | `/offers/:id` | commerçant (DELETE : + admin) |
| GET | `/orders/my` | étudiant |
| GET | `/orders/merchant` | commerçant |
| POST | `/orders/reserve` | étudiant |
| POST | `/orders/:id/cancel` | étudiant |
| POST | `/payments/konnect/init` · `/verify` | étudiant |
| POST | `/orders/validate-qr` | commerçant, admin |
| GET | `/admin/users` · `/admin/orders` | admin |
| PATCH | `/admin/users/:id/block` · `/admin/shops/:id/approve` | admin |
