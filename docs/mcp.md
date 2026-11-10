# MCP guide

The NS Pros Data API MCP server gives AI agents direct tool access to the
same license-cleared public data catalog as the REST API.

- **Endpoint:** `https://api.nspros.ca/mcp`
- **Transport:** streamable HTTP (JSON-RPC 2.0)
- **Auth:** `Authorization: Bearer <key>` — the same key as REST.
  Get a free key at https://data.nspros.ca/signup.

## Client configuration

**Claude Desktop / Claude Code / Cursor** (`mcpServers`):

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

**VS Code** (`servers`):

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

Ready-to-copy files: [examples/mcp-config.json](../examples/mcp-config.json),
[examples/vscode-mcp.json](../examples/vscode-mcp.json).

## Tools

### `search_sources`

Search the catalog of public data sources.

| Argument | Type | Description |
|---|---|---|
| `query` | string | Free-text search over id, name, and category. |
| `category` | string | Category filter, e.g. `finance`, `health`. |
| `country` | string | Country code filter, e.g. `US`, `CA`, `GB`. |

All arguments are optional. Returns the matching source entries — each with
its `id`, name, country, category, license name, and attribution text.

### `query_source`

Run a query against one source. Counts against the API key's monthly quota.

| Argument | Type | Required | Description |
|---|---|---|---|
| `source_id` | string | yes | Source id from `search_sources`. |
| `query` | string | yes | Search query for the source. |
| `limit` | integer | no | Max results (1–20, default 5). |

Returns the same normalized response as the REST query endpoints: source
name and id, `license`, `attribution`, the result records, and a `cached`
flag.

### `get_usage`

No arguments. Returns the API key's plan and current monthly usage.

## JSON-RPC examples

Initialize:

```bash
curl -X POST https://api.nspros.ca/mcp \
  -H "Authorization: Bearer <key>" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}}'
```

Call a tool:

```bash
curl -X POST https://api.nspros.ca/mcp \
  -H "Authorization: Bearer <key>" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 2, "method": "tools/call",
       "params": {"name": "query_source",
                  "arguments": {"source_id": "uk_bank_holidays",
                                "query": "2026", "limit": 5}}}'
```

Tool results are returned as JSON text in the standard MCP `content` array.
Calls made with an invalid key return a JSON-RPC error (`-32001`,
Unauthorized).

## Typical agent flow

1. `search_sources` with a topic (e.g. `"earthquake"`, or
   `category: "weather_env"`) to find candidate sources.
2. `query_source` with the chosen `source_id` and the user's question as
   `query`.
3. Answer using the returned records, keeping the `attribution` text with
   any data you present.
