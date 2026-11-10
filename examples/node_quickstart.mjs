// NS Pros Data API — Node.js quickstart (built-in fetch, Node 18+).
//
// Get a free key at https://data.nspros.ca/signup, then:
//   NSPROS_API_KEY="<key>" node node_quickstart.mjs

const API = "https://api.nspros.ca";
const KEY = process.env.NSPROS_API_KEY;

async function call(path, { params, auth } = {}) {
  const url = new URL(API + path);
  if (params) url.search = new URLSearchParams(params).toString();
  const res = await fetch(url, {
    headers: auth ? { Authorization: `Bearer ${KEY}` } : {},
  });
  if (!res.ok) throw new Error(`${res.status} ${await res.text()}`);
  return res.json();
}

// 1. Browse the catalog — public, no key needed.
const catalog = await call("/v1/sources", { params: { category: "finance" } });
for (const s of catalog.sources) console.log(s.id, "—", s.license);

// 2. Run a query against one source.
const result = await call("/v1/query/worldbank", {
  params: { q: "GDP per capita Canada", limit: 5 },
  auth: true,
});
console.log("\nAttribution:", result.attribution);
for (const item of result.results) console.log("-", item.title, "|", item.url);

// 3. Check usage for this key.
console.log("\nUsage:", await call("/v1/usage", { auth: true }));
