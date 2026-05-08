---
name: notion-flag-renewals
description: Find active packages where End Date is within N days (default 90) and Status is not already Renewal, then set Status = Renewal. Supports --dry-run to preview without writing.
---

Flag upcoming renewals on Active Packages by setting `Status = Renewal`.

Do **not** spawn a subagent — execute the steps below inline as the main assistant.

## Steps

**1. Resolve identity (--mine only — skip entirely for --global).**

Follow the **Identity resolution procedure** in `context/notion-schema.md` § Identity resolution. Extract `notion_user_id` as `<user-uuid>`.

**2. Determine scope and parameters.**
- `--mine` (default): filter `Current Account Owner LIKE '%<user-uuid>%'`
- `--global`: no owner filter. Warn the user in chat and ask for confirmation unless `--no-confirm` is also passed.
- `--days N`: flag packages ending within N days (default: 90)
- `--dry-run`: preview only — report what would change without writing anything

Compute `<today>` (today's date as `YYYY-MM-DD`) and `<cutoff>` (`<today>` + N days) before building the query.

**3. Query Active Packages** (`collection://29697e9c-7d4f-8031-9f76-000b7e932b36`) with server-side date filtering:

```sql
-- For --mine:
SELECT id, Name, Status, "date:End Date:start", "Current Account Owner"
FROM "collection://29697e9c-7d4f-8031-9f76-000b7e932b36"
WHERE "Active?" = '__YES__'
  AND "date:End Date:start" IS NOT NULL
  AND "date:End Date:start" > '<today>'
  AND "date:End Date:start" <= '<cutoff>'
  AND Status != 'Renewal'
  AND Status != 'Package Expired'
  AND "Current Account Owner" LIKE '%<user-uuid>%'
LIMIT 500

-- For --global (omit the owner filter):
SELECT id, Name, Status, "date:End Date:start", "Current Account Owner"
FROM "collection://29697e9c-7d4f-8031-9f76-000b7e932b36"
WHERE "Active?" = '__YES__'
  AND "date:End Date:start" IS NOT NULL
  AND "date:End Date:start" > '<today>'
  AND "date:End Date:start" <= '<cutoff>'
  AND Status != 'Renewal'
  AND Status != 'Package Expired'
LIMIT 500
```

All date and status filtering is done in the query — no client-side filtering step needed. The result set is the exact list of packages to flag.

**4. If `--dry-run`**: report the list of packages that would be updated (name, end date, days remaining). Stop here — do not write anything.

**5. Otherwise, update each matching package.** Call `notion-update-page` with:
```
command: update_properties
properties: { "Status": "Renewal" }
content_updates: []
```
Sleep 380 ms between each write.

**6. Report in chat.**
- Packages updated (name, end date, days remaining)
- Packages skipped — already `Renewal` (filtered out by query)
- Packages skipped — no end date set (filtered out by query)
- Packages skipped — end date already past (`Package Expired`, filtered out by query)
- Any write failures (by package name)

## Notes
- `Status` is a Notion status type — write as a plain string: `"Renewal"`.
- Valid `Status` values for Active Packages: `Not started`, `Renewal`, `Preparing`, `Activating`, `Adopting`, `Package Expired`, `Service Quota Used`.
- Do **not** flag packages with `Status = Package Expired` — the contract end date has already passed.
- `date:End Date:start` is the SQL column name; its value is a `YYYY-MM-DD` string.
- The skill's base directory is shown in the `Base directory:` header line of the skill invocation — sibling `about/` paths can be derived from it.

## Flags
- `--mine` — scope to the current user's packages (default)
- `--global` — scan all active packages; asks for confirmation first unless `--no-confirm` is also passed
- `--days N` — flag packages ending within N days (default: 90)
- `--dry-run` — preview what would change without writing
