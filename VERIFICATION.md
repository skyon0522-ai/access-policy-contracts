# Observed local verification

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
