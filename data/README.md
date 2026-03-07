# VaxGuide – Bulk Data Upload

All data files use **JSON** format (not CSV) so that Arabic text, commas,
newlines, and Unicode are handled correctly without delimiter issues.

## 📁 Files

| File | Firestore Collection | Description |
|---|---|---|
| `vaccine_categories.json` | `vaccine_categories` | Category definitions with subcategories (doc ID = `key`) |
| `vaccines.json` | `vaccines` | All vaccine records (preschool, school, travel, additional) |
| `articles.json` | `articles` | Educational / news articles |
| `vaccine_alerts.json` | `vaccine_alerts` | Push-notification vaccine alerts |

## 🚀 Setup & Upload

### 1. Get your Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/) → **Project Settings** → **Service accounts**
2. Click **"Generate new private key"**
3. Save the downloaded JSON file as **`serviceAccountKey.json`** in this `data/` folder

### 2. Install dependencies

```bash
cd data
npm install
```

### 3. Fill in the JSON data files

Open each `.json` file in any text editor (VS Code recommended) and fill in the Arabic data.

Every file is a **JSON array** `[ { … }, { … }, … ]`.

#### vaccine_categories.json fields

| Field | Type | Required | Description |
|---|---|---|---|
| `key` | string | ✅ | Category key — used as Firestore document ID (`preschool`, `school`, `travel`, `additional`) |
| `label` | string | ✅ | Arabic display label |
| `icon` | string | | Material icon name (e.g. `child_care_rounded`) |
| `subcategories` | string[] | | Array of subcategory names |

#### vaccines.json fields

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | string | ✅ | Vaccine name (Arabic) |
| `category` | string | ✅ | One of: `preschool`, `school`, `travel`, `additional` |
| `subcategory` | string | ✅ | Age/grade label matching category subcategories |
| `importance` | string | | أهمية التطعيم والأمراض التي يقي منها |
| `schedule` | string | | الجدول الزمني وعدد الجرعات ومدة فعاليته |
| `administrationMethod` | string | | طريقة الإعطاء |
| `sideEffects` | string | | الآثار الجانبية والأدوية اللازمة لها |
| `locations` | string | | أماكن تلقي التطعيم |
| `precautions` | string | | الاحتياطات اللازمة قبل أو بعد تلقي التطعيم |
| `warnings` | string | | متى يجب تجنبه أو نصائح أو تحذيرات |
| `countries` | string[] | | Array of country names (travel vaccines) |

#### articles.json fields

| Field | Type | Required | Description |
|---|---|---|---|
| `title` | string | ✅ | Article title |
| `body` | string | ✅ | Full article body text |
| `imageUrl` | string | | URL to header image |
| `author` | string | | Author name |
| `createdAt` | string | | Date in `YYYY-MM-DD` format (defaults to now) |
| `isPublished` | boolean | | `true` or `false` (defaults to `true`) |

#### vaccine_alerts.json fields

| Field | Type | Required | Description |
|---|---|---|---|
| `title` | string | ✅ | Alert title |
| `message` | string | ✅ | Alert body message |
| `severity` | string | | `high`, `medium`, or `info` (defaults to `info`) |
| `vaccineName` | string | | Related vaccine name |
| `isActive` | boolean | | `true` or `false` (defaults to `true`) |
| `createdAt` | string | | Date in `YYYY-MM-DD` format (defaults to now) |
| `expiresAt` | string/null | | Expiry date in `YYYY-MM-DD` format (optional) |

### 4. Upload to Firestore

```bash
# Upload ALL collections
npm run upload

# Or upload individually
npm run upload:categories
npm run upload:vaccines
npm run upload:articles
npm run upload:alerts
```

## ⚠️ Important Notes

- **serviceAccountKey.json** is gitignored — never commit it!
- Each run **creates new documents** (auto-generated IDs). If you re-run, you'll get duplicates. Categories use `key` as doc ID so they are safe to re-run (overwrite).
- Firestore batched writes are limited to 500 operations per batch — the script handles this automatically.
- All files must be valid JSON saved as **UTF-8** encoding.
