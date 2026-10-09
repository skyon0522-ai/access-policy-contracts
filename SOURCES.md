# Source composition

The component duplicates the complete eight-file `academy-samples/opa-by-example/review_authz_example` subtree from [open-policy-agent/contrib](https://github.com/open-policy-agent/contrib/tree/5b21e4cb42b8b3893a3ade1cf33423336c6176e1/academy-samples/opa-by-example/review_authz_example), commit `5b21e4cb42b8b3893a3ade1cf33423336c6176e1`. Both the root and academy Apache-2.0 licenses are retained. [source-provenance.json](source-provenance.json) records all ten source/license paths, byte sizes, SHA-256 values, Git blob identities, and immutable URLs.

No copied file is modified. The main policy makes review/delete decisions and delegates moderator classification to the role policy. `contract/contract.rego` supplies validated trusted-subject input to those actual copied decisions; it does not reimplement them. `contract/contract_test.rego` adds acceptance cases around that composition.

The reference was chosen for its small, inspectable separation of action rules and role/attribute rules, and its six substituted-input tests. It is a teaching example, not a complete user/role/permission assignment system. Its academy material is imported and marked potentially outdated. The subtree has no Makefile, and the root Regal configuration excludes academy samples. Official hosting does not establish current CI coverage or production suitability.

The local sequence ran the original snapshot, an unchanged duplicate, and the improved assembly with one checksum-verified OPA executable. Two disposable mutations caused the assembled tests to fail, then byte restoration restored their passing results. That sensitivity evidence establishes consumption of both copied modules; it is not a security proof. Details are in [VERIFICATION.md](VERIFICATION.md).
