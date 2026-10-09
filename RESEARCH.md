# Research background and limits

Sandhu, Ferraiolo, and Kuhn, *The NIST Model for Role-Based Access Control: Towards a Unified Standard*, RBAC 2000, DOI 10.1145/344287.344301, distinguishes users, roles, and permissions and discusses reviewing assignments. This repository uses that vocabulary to describe which trusted role/attribute inputs permit each concrete action. It does not implement the complete NIST assignment model or claim compliance. [NIST publication](https://csrc.nist.gov/pubs/conference/2000/07/26/nist-model-for-rbac-towards-a-unified-standard/final), [author-hosted paper](https://profsandhu.com/confrnc/rbac/rbac-nist.pdf).

NIST SP 800-162 describes attribute-based decisions in terms of subject, object, operation, and optional environment attributes. The separate subject, resource tenant, and action fields apply that conceptual vocabulary. Their local behavior is checked by the actual contract tests; the publication does not certify this implementation. [NIST SP 800-162](https://csrc.nist.gov/pubs/sp/800/162/upd2/final).

Neither reference supplies benchmark results, authentication, enforcement, or a security proof for this component. Runtime delegation and denied malformed/cross-tenant cases are local implementation evidence. See [VERIFICATION.md](VERIFICATION.md).
