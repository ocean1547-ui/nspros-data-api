#!/usr/bin/env bash
# NS Pros Data API — curl examples
# Get a free key at https://data.nspros.ca/signup and set it first:
#   export NSPROS_API_KEY="<key>"
set -euo pipefail

API="https://api.nspros.ca"

# 1. Browse the catalog — public, no key needed.
curl "$API/v1/sources?category=finance&country=US"

# 2. One source's details, including a ready-to-run example.
curl "$API/v1/sources/uk_bank_holidays"

# 3. Run a query (GET).
curl -H "Authorization: Bearer $NSPROS_API_KEY" \
  "$API/v1/query/worldbank?q=GDP%20per%20capita%20Canada&limit=5"

# 4. Run a query (POST with JSON body).
curl -X POST "$API/v1/query" \
  -H "Authorization: Bearer $NSPROS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"source": "uk_bank_holidays", "q": "2026"}'

# 5. Check this key's usage.
curl -H "Authorization: Bearer $NSPROS_API_KEY" "$API/v1/usage"

# 6. MCP: initialize and call a tool.
curl -X POST "$API/mcp" \
  -H "Authorization: Bearer $NSPROS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}}'

curl -X POST "$API/mcp" \
  -H "Authorization: Bearer $NSPROS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 2, "method": "tools/call",
       "params": {"name": "search_sources",
                  "arguments": {"query": "earthquake"}}}'
