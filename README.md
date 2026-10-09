# Access Policy Contracts

A small Rego acceptance component for reviewing tenant-bound access decisions before integrating them into an application. It adds explicit input and tenant checks around copied OPA Academy review/delete policies.

| Request | Observed decision |
| --- | --- |
| Same-tenant customer, reputation 10, review | `true` |
| Cross-tenant admin, delete | `false` |
| Same-tenant admin, reputation omitted, delete | `true` |
| Reputation supplied as a string | `false` |

The caller must authenticate identities and load trusted subject attributes and resource ownership. These fixtures do not authenticate users or enforce access in an application.

## Contents

- [Run the policies](#run-the-policies)
- [Contract](#contract)
- [Copied source](SOURCES.md)
- [Observed verification](VERIFICATION.md)
- [Research background](RESEARCH.md)

## Run the policies

The observed runtime is official OPA 0.67.0 for Windows amd64. The copied educational policies retain their older syntax; newer OPA releases and other platforms have not been tested here. In PowerShell, from the repository root:

```powershell
New-Item -ItemType Directory -Force .tools | Out-Null
Invoke-WebRequest 'https://github.com/open-policy-agent/opa/releases/download/v0.67.0/opa_windows_amd64.exe' -OutFile '.tools/opa.exe'
$opa = (Resolve-Path '.tools/opa.exe').Path
if ((Get-FileHash $opa -Algorithm SHA256).Hash.ToLowerInvariant() -ne '98ac401e944f6bc9bbc29a91f699b3403ec6979ed94682e46fa5ec78a8230bf3') { throw 'OPA checksum mismatch' }
$source = 'components/contrib/academy-samples/opa-by-example/review_authz_example/rules_and_data'
& $opa test -v $source 'contract/contract.rego' 'contract/contract_test.rego'
& $opa eval --strict-builtin-errors --format raw --input 'examples/same-tenant-review.json' --data "$source/main/rules.rego" --data "$source/policy/role/rules.rego" --data 'contract/contract.rego' 'data.access_contract.allow'
& $opa eval --strict-builtin-errors --format raw --input 'examples/cross-tenant-admin-delete.json' --data "$source/main/rules.rego" --data "$source/policy/role/rules.rego" --data 'contract/contract.rego' 'data.access_contract.allow'
```

The test command passed 51 tests in the recorded local assembly. The two example decisions are `true` and `false`, respectively. Runtime evaluation loads only the two copied policy modules and the contract; tests are loaded only for the test command. Inspect [the release](https://github.com/open-policy-agent/opa/releases/tag/v0.67.0) before downloading its binary.

## Contract

Both tenants must be nonblank strings and match exactly. The subject role must be a nonblank string; the action must be exactly `review` or `delete`. Values are not normalized. Review requires numeric reputation and calls the copied customer-review decision. Delete requires numeric reputation, or an admin role with reputation omitted, and calls the copied moderator-delete decision. Malformed reputation denies even for an admin when the field is present.

Only an explicit boolean `true` after successful evaluation may permit an operation. A future integration must reject errors, undefined values, and nonboolean responses. Authentication, attribute freshness, enforcement, policy administration, and application error handling remain integration responsibilities.

## Scope

This is a local policy acceptance component. The copied source is imported educational material excluded from the inspected upstream build/lint path. The observed checks establish these fixed contract cases, not production security, application integration, NIST-model compliance, customer usage, or revenue. No server, database, user interface, or remote CI result is included.

The added contract and tests are Apache-2.0 licensed. The copied source keeps both applicable licenses and its recorded provenance; see [NOTICE](NOTICE).
