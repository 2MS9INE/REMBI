# Rembi — رمبي


Rembi is a mobile marketplace connecting Algerian farmers and artisans with buyers across the country. Sellers register, post listings with photos, and receive direct contact via phone or WhatsApp. Buyers browse, search, and filter by category and wilaya.

---

## Tech Stack

| Layer | Technology | Why |
|---|---|---|
| UI | Flutter 3.x | Single codebase for Android & iOS |
| State Management | flutter_riverpod ^3.x | Compile-safe providers, testable |
| Navigation | go_router ^17.x | Declarative routing, ShellRoute for tab nav |
| Backend | Supabase (PostgreSQL + Storage + Auth) | Open-source, SQL power, free tier |
| Localization | Flutter Intl / ARB | AR (RTL), FR, EN, Tamazight |
| Local Notifications | flutter_local_notifications | No paid service, scheduled expiry alerts |
| Maps | flutter_map + OpenStreetMap | Free, no API key required |
| Image Handling | image_picker + flutter_image_compress | Local compress before upload |

---

## Architecture Decisions

### Feature-based Folder Structure
Code organized by business feature (not layer): `home/`, `listing/`, `auth/`, `farmer/`, `admin/`, `notifications/`, `settings/`. All data, domain, and presentation code for a feature lives together.

### Why Riverpod
- No `BuildContext` in business logic
- `FutureProvider` / `AsyncNotifier` — automatic loading/error/data states
- Compile-safe provider types
- `autoDispose` prevents memory leaks

### JSONB Dynamic Fields — The Key Design Decision

Different categories need completely different attributes: livestock needs breed, age, vaccination status; crops need variety, harvest date, quantity; artisan products need allergen info. Traditional solutions are:

- **Multiple category tables** (rejected) — rigid schema, complex joins, migrations per new category
- **Wide nullable columns** (rejected) — 50+ nulls per row, confusing data layer
- **JSONB + schema-driven UI** (chosen) — one `dynamic_fields JSONB` column plus a `category_schemas` table storing field definitions per category

Adding a new category requires **only inserting a row in `category_schemas`** — no migrations, no new Flutter code. The UI is fully data-driven. PostgreSQL JSONB supports GIN indexing for fast attribute-based queries. This pattern mirrors Shopify metafields, Airtable column types, and Contentful content modeling.

### Why Supabase over Firebase
- SQL for complex GROUP BY / aggregation queries
- Row Level Security (RLS) — access control in the database, not client code
- Realtime via PostgreSQL logical replication
- Open source, self-hostable, no vendor lock-in

---

## Local Setup

### Prerequisites
- Flutter SDK ≥ 3.11.1
- Supabase account (free at [supabase.com](https://supabase.com))

### Steps

```bash
# 1. Clone
git clone https://github.com/your-username/rembi.git
cd rembi

# 2. Create .env
echo "SUPABASE_URL=https://your-project.supabase.co" > .env
echo "SUPABASE_ANON_KEY=your-anon-key" >> .env
```

**3.** Open Supabase Dashboard → SQL Editor → paste `supabase_schema.sql` → Run

**4.** Seed category schemas from `seed_data.sql`

```bash
# 5. Install packages
flutter pub get

# 6. Run
flutter run
```

---

## Database ER Diagram

```
users (id, full_name, phone, wilaya, role, is_verified, warnings JSONB)
  │
  ├─< listings (id, farmer_id, title, category, subcategory,
  │             dynamic_fields JSONB, price, wilaya, status, is_featured)
  │     ├─< listing_photos (listing_id, photo_url, display_order)
  │     ├─< reports (listing_id, reporter_id, reason, status)
  │     └─< reviews (listing_id, reviewer_id, rating, comment)
  │
  └── category_schemas (category, subcategory, fields JSONB)
```

---

## Folder Structure

```
lib/
├── core/           (constants, providers, router, theme, utils, widgets)
├── features/
│   ├── admin/      (admin_repository, admin_provider, admin_panel_screen)
│   ├── auth/       (auth_repository, auth_provider, login, register)
│   ├── farmer/     (farmer_repository, category_schema_provider, dashboard, create_listing)
│   ├── home/       (listing_repository, listing_provider, home_screen)
│   ├── listing/    (listing domain model, listing_detail_screen)
│   ├── notifications/ (notification_log_provider, notifications_screen)
│   ├── onboarding/ (language_select, onboarding)
│   ├── seller/     (seller_profile_screen)
│   └── settings/   (settings_screen)
├── l10n/           (app_ar.arb, app_en.arb, app_fr.arb)
└── main.dart
```

---

## Known Limitations

- No in-app payments — buyers contact sellers directly via phone/WhatsApp
- No in-app chat — communication is external
- Local notifications only — no push (Supabase Realtime used for in-session verification alerts)
- No offline mode — requires active internet
- Admin role set manually in the database (`role = 'admin'`)

---

## Academic Notes: The JSONB Dynamic Fields Design

### The Problem
A multi-category marketplace has heterogeneous product attributes. Cattle listings need breed, age, weight, vaccination status. Honey listings need flower source, raw/processed status. Agricultural service listings need service type, geographic coverage, duration. A rigid relational schema cannot cleanly serve all categories without one of two anti-patterns: a wide table with dozens of nullable columns (confusing, wasteful), or one table per category (brittle, migration-heavy, requires code changes for every new category).

### The Solution
Rembi separates *schema definition* from *data storage*. A `category_schemas` table stores each category-subcategory combination's field definitions as a JSONB array. Each entry describes a field's key, multilingual labels (AR/FR/EN), data type (`text`, `number`, `boolean`, `select`, `date`, `textarea`), required status, and allowed options for select fields.

The Flutter app reads the schema via a Riverpod `FutureProvider` (`categorySchemaProvider`) and renders a completely dynamic form using a generic `_DynamicField` widget. No hardcoded field widgets per category exist anywhere in the codebase. Listing data is stored in `dynamic_fields JSONB` on the `listings` table.

### Why This Matters
Adding a new category — for example, beehives — requires only inserting a new row into `category_schemas`. No Flutter code change, no database migration, no app update. This *data-driven UI* principle is used by Shopify (product metafields), Airtable (flexible column types), and Contentful (content type modelling). PostgreSQL JSONB stores data in binary format and supports GIN (Generalized Inverted Index) indexing, so attribute searches like *"cattle with breed = 'Charollais'"* remain efficient even as the dataset grows. This replaces the more verbose EAV (Entity-Attribute-Value) pattern with a far cleaner, document-oriented approach while remaining within a fully relational ACID-compliant database.
