package access_contract

import future.keywords

# New contract glue, 2026-10-10. The copied main/role modules are unchanged.
# The caller authenticates and loads trusted subject/resource attributes.
default allow := false

tenant_bound if {
    is_object(input)
    is_object(input.subject)
    is_object(input.resource)
    is_string(input.subject.tenant)
    trim_space(input.subject.tenant) != ""
    is_string(input.resource.tenant)
    trim_space(input.resource.tenant) != ""
    input.subject.tenant == input.resource.tenant
    is_string(input.subject.role)
    trim_space(input.subject.role) != ""
}

delete_attributes_valid if {
    is_number(input.subject.reputation)
}

delete_attributes_valid if {
    input.subject.role == "admin"
    not "reputation" in object.keys(input.subject)
}

allow if {
    tenant_bound
    input.action == "review"
    is_number(input.subject.reputation)
    data.main.allow_review == true with input as input.subject
}

allow if {
    tenant_bound
    input.action == "delete"
    delete_attributes_valid
    data.main.allow_delete == true with input as input.subject
}
