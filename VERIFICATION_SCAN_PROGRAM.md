# Scan + Program verification

## Frontend (this repo) – verified

1. **program_id in payload**  
   When a program is selected (e.g. "Baseline – STR CODE 9"), the scan request **always includes** `program_id` in the POST body. When "No Program" is selected, `program_id` is **omitted** so the backend can use only manually enabled strategies.

2. **Debug logs (temporary)**  
   - `lib/src/utils/services/scan_service.dart`: before POST, logs  
     `Scan request: program_id=<id or "(none - backend uses enabled strategies)">`.  
   - `lib/src/features/home/home_controller.dart`: before calling API, logs  
     `Scan: program_id=<id or "(No Program - backend uses enabled strategies)">`.  
   View in DevTools → Console (web) or run with `flutter run` and check the console.

3. **strategy_ids actually used**  
   The frontend does not know which strategy IDs the backend uses. To verify STR9 (or any program) is applied, add a **backend** log when handling `POST /scans/` that prints:
   - `program_id` from the request body
   - `strategy_ids` (or equivalent) actually used for the scan (e.g. from the program’s strategy set)

## Backend – required behavior (not in this repo)

- When `program_id` is **present**: prioritize it and use that program’s strategy set; **ignore** the globally enabled/disabled strategies for this scan. So disabling strategies in the Strategies screen must **not** affect scans that send a `program_id`.
- When `program_id` is **absent** (No Program): run the scan using only **manually enabled** strategies (global enabled/disabled state).
- Add a temporary log in the scan endpoint: print `program_id` and the list of `strategy_ids` (or strategy names) used for the scan so you can confirm e.g. STR9 is applied at runtime.

## Quick test

1. Select program "Baseline – STR CODE 9" in the Home scan dialog.
2. Run a scan.
3. In console, confirm log: `Scan request: program_id=str_code_9` (or whatever ID that program has).
4. In backend logs, confirm the same `program_id` and the strategy IDs used for the scan.
