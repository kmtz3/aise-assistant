---
name: notion-sync-owner
description: Sync Customer.Owner → Current Account Owner on all linked Sessions, Tasks, and Active Packages. Only updates records where drift is detected. Reports totals scanned, drifted, updated, and any failures.
---

Push `Customer.Owner` down to all descendant records where `Current Account Owner` has drifted.

Do **not** spawn a subagent — execute the steps below inline as the main assistant.

## Steps

**1. Resolve identity (--mine only — skip entirely for --global).**

Follow the **Identity resolution procedure** in `context/notion-schema.md` § Identity resolution. Extract `notion_user_id` as `<user-uuid>`.

**2. Determine scope from flag.**
- `--mine` (default when no flag given): add `WHERE Owner LIKE '%<user-uuid>%'`
- `--global`: no owner filter — scan all Customers. Before proceeding, warn the user in chat that this will scan the entire workspace. Ask for confirmation unless `--no-confirm` is also passed.

**3. Query Customers DB** (`collection://29397e9c-7d4f-8067-b290-000b1c2d57e1`):
```sql
SELECT id, Customer, Owner
FROM "collection://29397e9c-7d4f-8067-b290-000b1c2d57e1"
[WHERE Owner LIKE '%<user-uuid>%']
LIMIT 200
```
Build a map: `{ customer_page_id → owner_uuids[] }`. The `Owner` field stores values as `["user://uuid1", ...]` — strip the `user://` prefix to get bare UUIDs.

**4. Query descendant DBs** in sequence with a 400 ms sleep between each call to avoid rate limits:

- **Sessions** (`collection://29397e9c-7d4f-8052-886b-000b9e3479d7`):
  ```sql
  SELECT id, Name, Customers, "Current Account Owner"
  FROM "collection://29397e9c-7d4f-8052-886b-000b9e3479d7"
  WHERE <Customers = customer_page_id OR ...>
  LIMIT 500
  ```
- **Tasks** (`collection://29397e9c-7d4f-808f-bcd4-000b66a94678`):
  Same pattern; title field is `Task` not `Name`.
- **Active Packages** (`collection://29697e9c-7d4f-8031-9f76-000b7e932b36`):
  ```sql
  SELECT id, Name, Customer, "Current Account Owner"
  FROM "collection://29697e9c-7d4f-8031-9f76-000b7e932b36"
  WHERE <Customer = customer_page_id OR ...>
  LIMIT 300
  ```
  Note: field is `Customer` (singular) not `Customers`.

**5. Detect drift.**
For each record, look up its customer in the map and compare the correct owner UUID set against the parsed `Current Account Owner` value (strip `user://`). Drift = sorted arrays differ.

**6. Update drifted records.**
For each drifted record call `notion-update-page` with:
```
command: update_properties
properties: { "Current Account Owner": "[\"<uuid1>\",\"<uuid2>\"]" }
content_updates: []
```
Write format is a JSON-stringified array of **bare UUIDs** (no `user://` prefix). Sleep 380 ms between each write.

**7. Report in chat.**
- Total records scanned (per DB)
- Total records with drift
- Total records updated
- Any write failures (by record name)

## Notes
- Filter queries use `LIKE '%<bare-uuid>%'` — matches the stored `user://uuid` form because the bare UUID substring is present.
- Contacts have no `Current Account Owner` field — exclude them entirely.
- This skill is safe to re-run; it only writes where drift exists.

## Flags
- `--mine` — scope to customers owned by the current user (default)
- `--global` — scan all customers; asks for confirmation first unless `--no-confirm` is also passed
