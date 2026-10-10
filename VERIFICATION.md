# Observed local verification

## Decision walkthrough rerun (2026-10-11)

The walkthrough ran on Windows with PowerShell 7 and the same official
OPA 0.67.0 Windows amd64 executable. Its SHA-256 was
`98ac401e944f6bc9bbc29a91f699b3403ec6979ed94682e46fa5ec78a8230bf3`.
`pwsh -NoProfile -File tools/run-demo.ps1 -Opa .tools/opa.exe` ran the full
policy suite (`PASS: 51/51`) and four direct `data.access_contract.allow`
queries. The decisions were `true`, `false`, `true`, `false` in the order shown
in [decision-results.json](examples/decision-results.json). The fourth input
deliberately supplies an admin reputation as a string and is denied.

The committed [JSON](examples/decision-results.json) and
[offline HTML](examples/decision-matrix.html) were reproduced into a separate
private output directory with matching SHA-256 values. The HTML embeds the
exact text of each evaluated JSON fixture, so all request details remain
available when the report is saved outside the repository. A local headless
layout check at 1440, 390 and 320 pixels found no page overflow, four
decision rows and a keyboard-focusable scroll region at each width. It made
no external requests; the checked screenshot is in `docs/assets/`. All 26 original files
other than the root README and this verification note matched the prior baseline bytes;
the copied policies, fixtures and notices were unchanged. This rerun does not
establish application enforcement, remote CI, another OPA version or another
platform.

The added [Windows workflow](.github/workflows/checks.yml) is configured to
download and checksum the same OPA binary, run all tests and four demo cases
into a new runner-temp directory, and compare parsed JSON plus HTML after CRLF
normalization with the committed reports. It is configuration only until a
GitHub run is observed; the local run above is the current execution evidence.

Observed on 2026-10-10 JST, using official OPA 0.67.0 Windows amd64, build `b62ae6bfed6ffad5a0a62f057499a56b0ae98dd0`. Executable SHA-256: `98ac401e944f6bc9bbc29a91f699b3403ec6979ed94682e46fa5ec78a8230bf3`, matching the official published checksum. No global installation or OPA server was used.

| Check | Observed result |
| --- | --- |
| Original snapshot | 6 upstream tests passed; 5 fixture decisions recorded |
| Unchanged duplicate | 6 tests passed; all 5 fixture pairs matched the original |
| Improved assembly | Strict check passed; 6 upstream and 45 contract tests passed, 51 total |
| Direct runtime queries | 10 original fixture/action decisions preserved; 21 negative fixtures denied; every response boolean and every exit successful |
| Main-module sensitivity | Disposable mutation made the selected assembled assertion fail with exit 2; exact restoration passed with exit 0 |
| Role-module sensitivity | Disposable mutation made the selected assembled assertion fail with exit 2; exact restoration passed with exit 0 |

The public `verification/` JSON files contain the baseline outcomes, assembly test summary, requests/expected/actual decisions, and mutation/restoration hashes. Original machine paths and private procedure logs are omitted. The five source fixture files cover four distinct inputs because input3 and input4 are identical.

Negative cases cover mismatched/missing/blank/nonstring tenants, missing/unknown actions, malformed structures, missing/malformed roles and reputation, guest review, and low/negative reputation. Admin delete with omitted reputation is deliberately preserved. Direct runtime queries excluded all test modules.

These checks establish the fixed local policy contract and source composition. Newer-runtime/platform compatibility, caller integration, identity verification, enforcement, attribute freshness, production security, remote CI, and customer use remain unverified. The old compatible runtime is intentional for the unchanged baseline; this is not a recommendation to deploy an unreviewed OPA server.
