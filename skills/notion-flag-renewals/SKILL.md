---
name: notion-flag-renewals
description: Find active packages where End Date is within N days (default 90) and Status is not already Renewal, then set Status = Renewal. Supports --dry-run to preview without writing.
---

Flag upcoming renewals on Active Packages by setting `Status = Renewal`.

Do **not** spawn a subagent — execute the steps below inline as the main assistant.

## Steps

**1. Resolve identity.**
Read `<PLUGIN_DATA_DIR>/about/identity.md` (path via `PLUGIN_DATA_DIR=$(cat "$HOME/.claude/aise-assistant.datadir")`). Extract `notion_user_id` as `<user-uuid>`.

**2. Determine scope and parameters.**
- `--mine` (default): filter `Current Account Owner LIKE '%<user-uuid>%'`
- `--global`: no owner filter. Warn the user in chat and ask for confirmation unless `--no-confirm` is also passed.
- `--days N`: flag packages ending within N days (default: 90)
- `--dry-run`: preview only — report what would change without writing anything

**3. Query Active Packages** (`collection://29697e9c-7d4f-8031-9f76-000b7e932b36`):
```sql
SELECT id, Name, Status, "date:End Date:start", "Current Account Owner"
FROM "collection://29697e9c-7d4f-8031-9f76-000b7e932b36"
WHERE "Active?" = '__YES__'
[AND "Current Account Owner" LIKE '%<user-uuid>%']
LIMIT 500
```

**4. Filter client-side.** For each returned package, apply all of the following:
- `End Date` is set and parses as a valid `YYYY-MM-DD` date
- `End Date` is **after** today (not already expired)
- `End Date` is within N days from today
- `Status` is **not** already `Renewal`

**5. If `--dry-run`**: report the list of packages that would be updated (name, end date, days remaining). Stop here — do not write anything.

**6. Otherwise, update each matching package.** Call `notion-update-page` with:
```
command: update_properties
properties: { "Status": "Renewal" }
content_updates: []
```
Sleep 380 ms between each write.

**7. Report in chat.**
- Packages updated (name, end date, days remaining)
- Packages skipped — already `Renewal`
- Packages skipped — no end date set
- Packages skipped — end date already past (`Package Expired`)
- Any write failures (by package name)

## Notes
- `Status` is a Notion status type — write as a plain string: `"Renewal"`.
- Valid `Status` values for Active Packages: `Not started`, `Renewal`, `Preparing`, `Activating`, `Adopting`, `Package Expired`, `Service Quota Used`.
- Do **not** flag packages with `Status = Package Expired` — the contract end date has already passed.
- `date:End Date:start` is the SQL column name; its value is a `YYYY-MM-DD` string.

## Flags
- `--mine` — scope to the current user's packages (default)
- `--global` — scan all active packages; asks for confirmation first unless `--no-confirm` is also passed
- `--days N` — flag packages ending within N days (default: 90)
- `--dry-run` — preview what would change without writing
