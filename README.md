# NS Pros Data API

**The world's public data, one API.**

Public data is scattered across thousands of government portals — every source
with its own API style, response format, and license terms. NS Pros Data API
normalizes license-cleared public data sources into **one REST API and one MCP
server**, so developers and AI agents can query them all with a single key and
a single response format.

- **Catalog (no key needed):** https://api.nspros.ca/v1/sources
- **Product & signup:** https://data.nspros.ca
- **Docs:** https://data.nspros.ca/docs · [REST reference](docs/rest-api.md) · [MCP guide](docs/mcp.md) · [OpenAPI spec](openapi.yaml) · [llms.txt](llms.txt)

## What's in the catalog

Weather, earthquakes, finance, health, business, science, and public records
from sources including:

- **Japan Meteorological Agency** — forecasts and earthquake reports
- **World Bank** — worldwide economic indicators
- **US National Weather Service** and **US Treasury Fiscal Data**
- **Government of Canada** open data and provincial portals
- **UK data.gov.uk / GOV.UK** — including UK bank holidays
- Open data portals from Australia, New Zealand, Germany, Finland, Ireland,
  and Hong Kong, plus scholarly sources such as arXiv, Crossref, and DailyMed

New sources are added daily. Every source in the catalog is **License Grade
A**: its license terms were reviewed and commercial redistribution is
confirmed. Every response carries the source's attribution text automatically,
so staying within the license terms is the default, not an afterthought.

## Quickstart

### 1. Browse the catalog — no key required

```bash
curl "https://api.nspros.ca/v1/sources?category=finance&country=US"
```

### 2. Get a free API key

Sign up at https://data.nspros.ca/signup — a free-tier key is issued
immediately, no card required. The same key works for REST and MCP.

### 3a. Query over REST

```bash
curl -H "Authorization: Bearer <key>" \
  "https://api.nspros.ca/v1/query/uk_bank_holidays?q=2026"
```

Response shape (excerpt):

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

Each result is a normalized record with `title`, `snippet`, and `url` fields,
whatever the original source's native format was.

Full reference: [docs/rest-api.md](docs/rest-api.md) · machine-readable spec:
[openapi.yaml](openapi.yaml)

### 3b. Connect over MCP

Server URL: `https://api.nspros.ca/mcp` (streamable HTTP, same Bearer key)

**Claude Desktop / Claude Code / Cursor** — add to your MCP config
(`mcpServers`):

```json
{
  "mcpServers": {
    "nspros-data": {
      "url": "https://api.nspros.ca/mcp",
      "headers": {
        "Authorization": "Bearer <key>"
      }
    }
  }
}
```

**VS Code** — uses a `servers` block instead:

```json
{
  "servers": {
    "nspros-data": {
      "type": "http",
      "url": "https://api.nspros.ca/mcp",
      "headers": {
        "Authorization": "Bearer <key>"
      }
    }
  }
}
```

Ready-to-copy files are in [examples/](examples/).

#### MCP tools

| Tool | Description |
|---|---|
| `search_sources` | Search the catalog by keyword, `category`, and `country`. |
| `query_source` | Run a query against one source by `source_id`. Counts against your key's monthly quota. |
| `get_usage` | Return your key's plan and current monthly usage. |

Details and JSON-RPC examples: [docs/mcp.md](docs/mcp.md)

## Pricing

| Plan | Price | Includes |
|---|---|---|
| Free | $0 | 1,000 requests/month, no card required |
| Pay as you go | $1.99 per 1,000 requests | Billed per thousand requests beyond the free tier |

Signing up currently issues a free-tier key immediately. Pay-as-you-go billing
will be connected via Stripe in the next step; until then, no usage charges
are billed.

## Categories

`weather_env` · `finance` · `health` · `business` · `science` · `general` ·
`immigration_life` · `library` · `vehicles`

Filter the catalog with `?category=` and `?country=` (ISO country codes such
as `US`, `CA`, `GB`, `JP`).

## License policy

Each source carries a license grade, shown in the catalog next to its license
name and attribution text:

- **Grade A** — commercial redistribution confirmed. The only grade offered.
- **Grade B** — usable with your own upstream key (BYO). Planned, not offered yet.
- **Grade C** — internal use only. Not offered.
- **Grade D** — on hold pending license review. Not offered.

When you display or redistribute results, keep the `attribution` field that
comes with every response — it states the original source and its license.

The documentation and example code in this repository are MIT-licensed (see
[LICENSE](LICENSE)). Data returned by the API remains under each original
source's license, as stated in the response's `license` and `attribution`
fields.

## Rate limits

- Per key: 120 requests/minute
- Per source: 30 requests/minute
- Responses are cached per source with a source-specific TTL, so repeated
  identical queries return faster.

## Contact

NS Pros — Halifax, Nova Scotia, Canada
hello@nspros.ca · https://nspros.ca · https://data.nspros.ca
