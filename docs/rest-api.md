# REST API reference

Base URL: **https://api.nspros.ca**

All responses are JSON. Every query response automatically includes the
source's `license` and `attribution` — keep them with the data when you
display or redistribute results.

## Authentication

Send your key on every query request:

```
Authorization: Bearer <key>
```

Get a free key at https://data.nspros.ca/signup (issued immediately, no card
required). The same key works for REST and MCP.

**Exception:** the catalog endpoints (`GET /v1/sources` and
`GET /v1/sources/{source_id}`) are public and need no key. Browse first; get a
key when you are ready to run queries.

## Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/v1/sources` | public | List the source catalog. Supports `q`, `category`, `country` filters. |
| GET | `/v1/sources/{source_id}` | public | One source's details, including a ready-to-run example. |
| GET | `/v1/query/{source_id}?q=...` | key | Run a query against one source. |
| POST | `/v1/query` | key | Run a query with a JSON body. |
| GET | `/v1/usage` | key | Your key's plan and current monthly usage. |

### GET /v1/sources

| Parameter | Description |
|---|---|
| `q` | Free-text search over source id, name, and category. |
| `category` | Category filter, e.g. `finance`, `health`, `weather_env`. |
| `country` | ISO country code filter, e.g. `US`, `CA`, `GB`, `JP`. |

```bash
curl "https://api.nspros.ca/v1/sources?category=finance&country=US"
```

Response (excerpt):

```json
{
  "count": 1,
  "sources": [
    {
      "id": "us_treasury",
      "name": "US Treasury Fiscal Data",
      "country": "US",
      "category": "finance",
      "license": "Public domain (U.S. federal government)",
      "attribution": "Source: US Treasury Fiscal Data — ...",
      "byo": false
    }
  ]
}
```

`count` is the number of sources returned by this catalog query (it reflects
your filters). Each source entry shows its license name and the attribution
text to keep with its data. All catalog sources are License Grade A —
commercial redistribution confirmed.

### GET /v1/sources/{source_id}

Returns the same fields as one catalog entry, plus an `example` object with a
ready-to-run GET URL, a curl command, and the equivalent MCP tool arguments.

```bash
curl "https://api.nspros.ca/v1/sources/uk_bank_holidays"
```

### GET /v1/query/{source_id}

| Parameter | Description |
|---|---|
| `q` | Query text for the source. |
| `limit` | Max results, 1–20 (default 5). |

```bash
curl -H "Authorization: Bearer <key>" \
  "https://api.nspros.ca/v1/query/worldbank?q=GDP%20per%20capita%20Canada&limit=5"
```

### POST /v1/query

JSON body fields: `source` (source id), `q` (query text), `limit`
(optional, 1–20, default 5).

```bash
curl -X POST https://api.nspros.ca/v1/query \
  -H "Authorization: Bearer <key>" \
  -H "Content-Type: application/json" \
  -d '{"source": "uk_bank_holidays", "q": "2026"}'
```

### Query response format

```json
{
  "source": {"name": "UK bank holidays (GOV.UK)", "id": "uk_bank_holidays"},
  "license": "Open Government Licence v3.0 (OGL)",
  "attribution": "Source: UK bank holidays (GOV.UK) — contains public sector information licensed under the Open Government Licence v3.0 (OGL).",
  "query": "2026",
  "cached": false,
  "results": [
    {"title": "...", "snippet": "...", "url": "..."}
  ]
}
```

- `count` — number of results in this response.
- `cached` — `true` when the response was served from the per-source cache.
- `results` — normalized records (`title`, `snippet`, `url`, and where the
  source provides them, `date`), whatever the source's native format was.

Query responses include usage headers:

```
X-Usage-Month: <requests used this month>
X-Quota-Limit: <monthly limit for the key's plan, or "unlimited">
X-Quota-Remaining: <requests remaining this month, or "unlimited">
```

### GET /v1/usage

```bash
curl -H "Authorization: Bearer <key>" https://api.nspros.ca/v1/usage
```

Returns the key's plan and current monthly usage — the same information as
the MCP `get_usage` tool.

## Errors

Errors are JSON: `{"error": {"code": "...", "message": "..."}}` shape with a
matching HTTP status.

| HTTP | Meaning |
|---|---|
| 400 | Malformed request (e.g. invalid JSON body). |
| 401 | Missing or invalid API key. Check the `Authorization` header. |
| 403 | The query is excluded for that source for licensing reasons (message explains). |
| 404 | Unknown source id (`source_not_found`). |
| 429 | Rate limit exceeded, or free-tier monthly quota reached. `Retry-After` is sent for rate limits. |
| 502 | The upstream source returned an error or was unavailable. Retry later. |

## Rate limits and caching

- Per key: 120 requests/minute
- Per source: 30 requests/minute
- Free tier: 1,000 requests/month per key
- Responses are cached per source with a source-specific TTL, so repeated
  identical queries return faster and are marked `"cached": true`.
