/**
 * VaxGuide – Bulk JSON → Firestore Uploader
 *
 * Usage:
 *   node upload.js                                   # uploads ALL collections
 *   node upload.js --collection vaccine_categories   # uploads only categories
 *   node upload.js --collection vaccines             # uploads only vaccines
 *   node upload.js --collection articles             # uploads only articles
 *   node upload.js --collection vaccine_alerts       # uploads only alerts
 *
 * Prerequisites:
 *   1. Place your Firebase service-account key JSON in this folder as
 *      "serviceAccountKey.json" (download from Firebase Console →
 *       Project Settings → Service accounts → Generate new private key).
 *   2. npm install
 *   3. Fill in the JSON data files, then run: npm run upload
 */

const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const fs = require("fs");
const path = require("path");

// ──────────────────────────────────────────────
// 1. Initialise Firebase Admin
// ──────────────────────────────────────────────
const serviceAccountPath = path.join(__dirname, "serviceAccountKey.json");
if (!fs.existsSync(serviceAccountPath)) {
  console.error(
    "❌  serviceAccountKey.json not found!\n" +
      "   Download it from Firebase Console → Project Settings → Service accounts → Generate new private key.\n" +
      "   Place the file in the data/ folder."
  );
  process.exit(1);
}

initializeApp({
  credential: cert(require(serviceAccountPath)),
});
const db = getFirestore();

// ──────────────────────────────────────────────
// 2. Helpers
// ──────────────────────────────────────────────

/** Read & parse a JSON data file. Returns array of objects. */
function readJsonFile(filePath) {
  const raw = fs.readFileSync(filePath, "utf-8");
  const data = JSON.parse(raw);
  if (!Array.isArray(data)) {
    throw new Error(`${filePath} must contain a JSON array.`);
  }
  return data;
}

/** Convert date string (YYYY-MM-DD or ISO) to Firestore Timestamp, or null. */
function toTimestamp(value) {
  if (!value || (typeof value === "string" && value.trim() === "")) return null;
  const d = new Date(value);
  if (isNaN(d.getTime())) return null;
  return Timestamp.fromDate(d);
}

// ──────────────────────────────────────────────
// 3. Collection-specific row → Firestore doc mappers
// ──────────────────────────────────────────────

function mapVaccineCategory(row) {
  return {
    key: row.key || "",
    label: row.label || "",
    icon: row.icon || "",
    subcategories: Array.isArray(row.subcategories) ? row.subcategories : [],
  };
}

function mapVaccine(row) {
  return {
    name: row.name || "",
    category: row.category || "",
    subcategory: row.subcategory || "",
    importance: row.importance || "",
    schedule: row.schedule || "",
    administrationMethod: row.administrationMethod || "",
    sideEffects: row.sideEffects || "",
    locations: row.locations || "",
    precautions: row.precautions || "",
    warnings: row.warnings || "",
    countries: Array.isArray(row.countries) ? row.countries : [],
  };
}

function mapArticle(row) {
  return {
    title: row.title || "",
    body: row.body || "",
    imageUrl: row.imageUrl || "",
    author: row.author || "",
    createdAt: toTimestamp(row.createdAt) || Timestamp.now(),
    isPublished: row.isPublished !== undefined ? row.isPublished : true,
  };
}

function mapVaccineAlert(row) {
  const doc = {
    title: row.title || "",
    message: row.message || "",
    severity: row.severity || "info",
    vaccineName: row.vaccineName || "",
    isActive: row.isActive !== undefined ? row.isActive : true,
    createdAt: toTimestamp(row.createdAt) || Timestamp.now(),
  };
  const exp = toTimestamp(row.expiresAt);
  if (exp) doc.expiresAt = exp;
  return doc;
}

// ──────────────────────────────────────────────
// 4. Bulk upload using batched writes (max 500 per batch)
// ──────────────────────────────────────────────

async function uploadCollection(collectionName, jsonFileName, mapFn, docIdField = null) {
  const filePath = path.join(__dirname, jsonFileName);
  if (!fs.existsSync(filePath)) {
    console.warn(`⚠️  ${jsonFileName} not found – skipping.`);
    return;
  }

  const rows = readJsonFile(filePath);
  if (rows.length === 0) {
    console.log(`ℹ️  ${jsonFileName} is empty – nothing to upload.`);
    return;
  }

  console.log(`📤  Uploading ${rows.length} docs → "${collectionName}" ...`);

  const BATCH_SIZE = 500;
  let totalWritten = 0;

  for (let i = 0; i < rows.length; i += BATCH_SIZE) {
    const batch = db.batch();
    const chunk = rows.slice(i, i + BATCH_SIZE);

    for (const row of chunk) {
      const docData = mapFn(row);

      // Skip rows that have no meaningful data
      const hasData = Object.values(docData).some((v) => {
        if (typeof v === "string") return v.length > 0;
        if (Array.isArray(v)) return v.length > 0;
        return v !== null && v !== undefined;
      });
      if (!hasData) continue;

      // Use a specific field as document ID if provided, otherwise auto-ID
      const docRef =
        docIdField && row[docIdField]
          ? db.collection(collectionName).doc(row[docIdField])
          : db.collection(collectionName).doc();
      batch.set(docRef, docData);
      totalWritten++;
    }

    await batch.commit();
  }

  console.log(`✅  ${collectionName}: ${totalWritten} documents written.`);
}

// ──────────────────────────────────────────────
// 5. Main
// ──────────────────────────────────────────────

const COLLECTIONS = {
  vaccine_categories: {
    file: "vaccine_categories.json",
    mapper: mapVaccineCategory,
    docIdField: "key",
  },
  vaccines: {
    file: "vaccines.json",
    mapper: mapVaccine,
  },
  articles: {
    file: "articles.json",
    mapper: mapArticle,
  },
  vaccine_alerts: {
    file: "vaccine_alerts.json",
    mapper: mapVaccineAlert,
  },
};

async function main() {
  // Parse --collection flag
  const args = process.argv.slice(2);
  const collIdx = args.indexOf("--collection");
  const targetCollection = collIdx !== -1 ? args[collIdx + 1] : null;

  if (targetCollection && !COLLECTIONS[targetCollection]) {
    console.error(
      `❌  Unknown collection "${targetCollection}". Available: ${Object.keys(COLLECTIONS).join(", ")}`
    );
    process.exit(1);
  }

  const toUpload = targetCollection
    ? { [targetCollection]: COLLECTIONS[targetCollection] }
    : COLLECTIONS;

  for (const [name, { file, mapper, docIdField }] of Object.entries(toUpload)) {
    await uploadCollection(name, file, mapper, docIdField || null);
  }

  console.log("\n🎉  All done!");
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});

