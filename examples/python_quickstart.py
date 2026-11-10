"""NS Pros Data API — Python quickstart (standard library only).

Get a free key at https://data.nspros.ca/signup, then:

    export NSPROS_API_KEY="<key>"
    python3 python_quickstart.py
"""

import json
import os
import urllib.parse
import urllib.request

API = "https://api.nspros.ca"
KEY = os.environ["NSPROS_API_KEY"]


def call(path, params=None, auth=False):
    url = API + path
    if params:
        url += "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url)
    if auth:
        req.add_header("Authorization", "Bearer " + KEY)
    with urllib.request.urlopen(req) as resp:
        return json.load(resp)


# 1. Browse the catalog — public, no key needed.
catalog = call("/v1/sources", {"category": "weather_env", "country": "JP"})
for source in catalog["sources"]:
    print(source["id"], "—", source["license"])

# 2. Run a query against one source.
result = call(
    "/v1/query/jma_quake", {"q": "earthquake", "limit": 5}, auth=True
)
print("\nAttribution:", result["attribution"])
for item in result["results"]:
    print("-", item["title"], "|", item["url"])

# 3. Check usage for this key.
print("\nUsage:", call("/v1/usage", auth=True))
