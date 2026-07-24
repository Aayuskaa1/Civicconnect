# CivicConnect

Apartment / building resident app for reporting issues, tracking status, and getting in-app help.

## Project structure

```
Civicconnect/
├── backend/     # Node.js + Express + MongoDB API
├── frontend/    # Flutter mobile app
├── scripts/     # iOS build helpers
└── README.md
```

## Features

- Register / login / profile update (with photo)
- Submit building issues with photo
- Reports list + filters + detail + admin status update
- Ask AI (local apartment assistant)
- Sensors:
  - **Light** — detects dark areas and suggests a Lighting report
  - **Accelerometer** — shake to open Report an issue; hard bump can suggest Safety
- Shared REST API design with CivicConnect Web (`/api/v1/auth`, `/api/v1/complaints`, `/api/v1/ai`)

## Prerequisites

- Node.js 20+
- MongoDB running locally
- Flutter SDK
- Xcode (for iOS)

## Backend setup

```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

API base: `http://127.0.0.1:3000/api/v1/`

### Shared API endpoints (mobile + web)

| Action | Method + path |
|--------|----------------|
| Register | `POST /api/v1/auth/register` |
| Login | `POST /api/v1/auth/login` |
| Profile | `GET /api/v1/auth/whoami` |
| Update profile | `PUT /api/v1/auth/update` |
| Create complaint | `POST /api/v1/complaints` |
| My complaints | `GET /api/v1/complaints/me` |
| Complaint detail | `GET /api/v1/complaints/:id` |
| Admin update | `PATCH /api/v1/complaints/:id/admin` |
| AI chat | `POST /api/v1/ai/chat` |

## Flutter app setup

```bash
cd frontend
flutter pub get
```

### iOS Simulator

```bash
bash scripts/setup_ios_build_dir.sh
flutter run --dart-define=USE_LAN=false
```

### Physical iPhone (same Wi‑Fi as Mac)

```bash
bash scripts/setup_ios_build_dir.sh
flutter run -d <device-id> \
  --dart-define=USE_LAN=true \
  --dart-define=LAN_HOST=<your-mac-ip>
```

Example:

```bash
flutter run -d 00008110-00094D521A0B801E \
  --dart-define=USE_LAN=true \
  --dart-define=LAN_HOST=192.168.1.70
```

Open Xcode with **`ios/Runner.xcworkspace`** (not `.xcodeproj`), choose **Runner** + your iPhone, then Run.

## Demo checklist

1. Register / login  
2. Submit a report with photo  
3. View it under Reports and Profile  
4. Ask AI a question about reporting  
5. Home → tap **Sensors · tap to check** → Test low light / shake  
6. (Phone) cover light sensor or shake device  

## Notes for markers

- Mobile and Web use **separate backends**, but the **same API paths** for shared features.
- Do not commit `.env` or uploaded media files.
- iOS builds from the Documents folder should use `scripts/setup_ios_build_dir.sh` first (avoids macOS File Provider build errors).
