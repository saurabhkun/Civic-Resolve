# 🏛️ CivicResolve
### *Smart Municipal Complaint & Resolution Intelligence Platform*

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Database%20%26%20Auth-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Gemini 1.5 Flash](https://img.shields.io/badge/Gemini_AI-Multimodal_Triage-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)
[![Leaflet Dark Matter](https://img.shields.io/badge/CartoDB-Dark_Command_Center-10B981?style=for-the-badge&logo=leaflet&logoColor=white)](https://leafletjs.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

---

## 📌 Executive Summary

**CivicResolve** is an enterprise-grade municipal intelligence ecosystem designed to bridge the gap between citizen grievance reporting and local governance accountability. By pairing a high-performance **Flutter Citizen Mobile App** with a dark **GovTech Command Center Web Portal**, the platform automates issue triage using **Google Gemini Multimodal AI** and enforces SLA-backed contractor accountability. With proximity-based duplicate suppression (200m radius) and green citizen credit gamification, CivicResolve transforms reactive municipal bureaucracy into proactive, data-driven smart city management.

---

## 🏗️ System Architecture

```
                                  ┌───────────────────────────────┐
                                  │   Citizen Mobile App (Flutter)│
                                  │  • AI Photo Triage Camera     │
                                  │  • Proximity Duplicate Alert  │
                                  │  • Plant Nursery Rewards Hub  │
                                  └───────────────┬───────────────┘
                                                  │ (REST / WebSockets)
                                                  ▼
┌──────────────────────────────┐         ┌───────────────────────────────┐
│ Web Command Center (GovTech) │ ◄─────► │  Supabase Backend (PostgreSQL)│
│ • Dark Matter Leaflet Map    │ (Auth & │  • 7-Step Lifecycle Engine    │
│ • Live Split-View Feed       │  Sync)  │  • PostGIS Geo-Proximity (200m│
│ • Before/After Photo Modal   │         │  • Token Credits & Ledger     │
│ • Municipal AI Copilot Drawer│         └───────────────┬───────────────┘
└──────────────────────────────┘                         │
                                                         │ (Image & Text Payloads)
                                                         ▼
                                         ┌───────────────────────────────┐
                                         │  Google Gemini 1.5 Flash AI   │
                                         │  • Dual Visual Disaster Triage│
                                         │  • Automated Priority Grading │
                                         │  • Grounded Intelligence Chat │
                                         └───────────────────────────────┘
```

---

## 📂 Enterprise Monorepo Structure

```
CivicResolve/
├── apps/
│   ├── mobile/                    # Citizen Mobile Client (Flutter)
│   │   ├── lib/                   # Screen controllers, services & widgets
│   │   ├── assets/images/         # App icons, UI graphics & sample proofs
│   │   ├── test/                  # Widget & unit test suites
│   │   └── pubspec.yaml           # Flutter dependencies & asset manifests
│   └── web/                       # Municipal Admin Command Center
│       ├── css/                   # GovTech dark command styling & badge tokens
│       ├── js/                    # Realtime sync, Leaflet controller & Copilot
│       ├── assets/images/         # Web logos and branding
│       ├── dashboard.html         # Split-view command center & triage map
│       ├── reports.html           # Full incident table & SLA lifecycle manager
│       └── index.html             # Officer auth entrypoint
├── supabase/
│   └── migrations/                # PostgreSQL schema, PostGIS & RLS policies
│       ├── database_schema.sql
│       ├── enhanced_database_schema.sql
│       ├── credit_system_schema.sql
│       └── priority_enhancement_schema.sql
├── docs/                          # Architecture blueprints & technical specs
│   ├── architecture/              # High-level architecture & diagrams
│   ├── database/                  # Schema documentation & entity relationships
│   ├── features/                  # 7-step lifecycle, AI triage & rewards docs
│   └── images/                    # UI screenshots and pitch mockups
├── packages/                      # Shared configs and reusable modules
├── .env.example                   # Unified environment variables template
├── .gitignore                     # Enterprise clean monorepo ignore rules
└── README.md                      # Monorepo documentation
```

---

## ⚡ Core Features Matrix

| Feature Domain | Citizen Mobile App | Municipal Command Center | AI & Backend Engine |
| :--- | :--- | :--- | :--- |
| **Grievance Reporting** | Multimodal photo capture + GPS auto-pinpoint | Real-time incident intake queue | Gemini dual-classification triage |
| **Proximity Suppression** | In-line 200m duplicate detection with upvoting | 200m buffer rings plotted on Dark Leaflet map | PostGIS Haversine distance matching |
| **Remediation & SLA** | Live 7-step progression tracking & push notifications | Contractor assignment & SLA deadline timers | Status transition audit logging |
| **Quality Verification** | Citizen approval / rework rejection request | Interactive "Before & After" photo comparison modal | Tamper-resistant image storage |
| **Citizen Incentives** | Green token balance & nursery voucher redemption | Citizen engagement analytics | Automated reward credit ledger |
| **Municipal AI Copilot** | Automated priority detection on submission | Floating AI Intelligence drawer with quick chips | RAG grounded complaint synthesis |

---

## 🚀 Quickstart Guide

### 1. Prerequisites
- **Flutter SDK** (v3.19 or higher)
- **Dart SDK** (v3.0 or higher)
- **Supabase Account** with PostgreSQL database instance
- **Google AI Studio API Key** (for Gemini 1.5 Flash)

---

### 2. Environment Configuration
Copy the template at the root to create your local `.env`:
```bash
cp .env.example apps/mobile/.env
```
Populate `apps/mobile/.env` and `apps/web/js/config.js` with your keys:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key-here
GEMINI_API_KEY=your-gemini-api-key-here
```

---

### 3. Running the Citizen Mobile App (`apps/mobile/`)
```bash
cd apps/mobile

# Install Dart & Flutter dependencies
flutter pub get

# Run on connected device or Chrome web emulator
flutter run -d chrome  # or: flutter run -d android / ios
```

---

### 4. Running the Municipal Web Command Center (`apps/web/`)
The web portal is pure Vanilla JS / CSS with Leaflet and Supabase CDN libraries. No build step is required:
```bash
# Option A: Using Python local server
cd apps/web
python -m http.server 8080

# Option B: Using VS Code Live Server or Nginx / Cloudflare Pages
# Open apps/web/index.html in your browser
```
> **Default Test Credentials:**
> - **Username:** `admin`
> - **Password:** `1234`

---

## 🗄️ Database & Schema Setup
Execute the SQL migrations in order within your Supabase SQL Editor:
1. `supabase/migrations/database_schema.sql` (Core tables: `reports`, `users`, `categories`)
2. `supabase/migrations/enhanced_database_schema.sql` (7-step status machine & RLS)
3. `supabase/migrations/credit_system_schema.sql` (Green citizen rewards ledger)
4. `supabase/migrations/priority_enhancement_schema.sql` (Proximity indexing & SLA triggers)

---

## 🏆 National Hackathon Alignment (Problem Statement 02)
- **Deterministic 7-Step Lifecycle State Machine:** `submitted` ➔ `under_review` ➔ `assigned` ➔ `in_progress` ➔ `resolution_submitted` ➔ `verified` ➔ `closed`.
- **200-Meter Proximity Deduplication:** Eliminates duplicate work orders through geo-radius buffer queries.
- **Contractor Accountability:** Compulsory "Before & After" photo evidence with geotag and timestamp validation.
- **Civic Incentives:** Citizen tokens redeemable for tree saplings and municipal nursery vouchers.

---

## 📄 License
This project is open-source and licensed under the [MIT License](LICENSE).
