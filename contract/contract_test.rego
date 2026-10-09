package access_contract_test

import future.keywords
import data.access_contract

request(subject, action) := {
    "subject": subject,
    "resource": {"tenant": "tenant-a"},
    "action": action,
}

admin := {"role": "admin", "tenant": "tenant-a"}
moderator := {"role": "guest", "reputation": 100, "tenant": "tenant-a"}
customer := {"role": "customer", "reputation": 10, "tenant": "tenant-a"}

allowed(candidate) if { access_contract.allow == true with input as candidate }
denied(candidate) if { access_contract.allow == false with input as candidate }

test_customer_review_delegates if { allowed(request(customer, "review")) }
test_zero_reputation_customer_review if { allowed(request(object.union(customer, {"reputation": 0}), "review")) }
test_high_reputation_delete_delegates if { allowed(request(moderator, "delete")) }
test_customer_high_reputation_delete if { allowed(request(object.union(customer, {"reputation": 100}), "delete")) }
test_admin_delete_without_reputation if { allowed(request(admin, "delete")) }
test_admin_delete_with_negative_numeric_reputation if { allowed(request(object.union(admin, {"reputation": -10}), "delete")) }

test_negative_reputation_customer_review_denied if { denied(request(object.union(customer, {"reputation": -10}), "review")) }
test_guest_review_denied if { denied(request(moderator, "review")) }
test_medium_reputation_customer_delete_denied if { denied(request(customer, "delete")) }
test_below_moderator_threshold_delete_denied if { denied(request(object.union(moderator, {"reputation": 99}), "delete")) }
test_cross_tenant_admin_delete_denied if { denied(request(object.union(admin, {"tenant": "tenant-b"}), "delete")) }
test_cross_tenant_moderator_delete_denied if { denied(request(object.union(moderator, {"tenant": "tenant-b"}), "delete")) }
test_cross_tenant_customer_review_denied if { denied(request(object.union(customer, {"tenant": "tenant-b"}), "review")) }

test_missing_subject_tenant_denied if { denied(request({"role": "admin"}, "delete")) }
test_missing_resource_tenant_denied if { denied({"subject": admin, "resource": {}, "action": "delete"}) }
test_both_tenants_missing_denied if { denied({"subject": {"role": "admin"}, "resource": {}, "action": "delete"}) }
test_equal_empty_tenants_denied if { denied({"subject": {"role": "admin", "tenant": ""}, "resource": {"tenant": ""}, "action": "delete"}) }
test_equal_whitespace_tenants_denied if { denied({"subject": {"role": "admin", "tenant": " "}, "resource": {"tenant": " "}, "action": "delete"}) }
test_equal_numeric_tenants_denied if { denied({"subject": {"role": "admin", "tenant": 1}, "resource": {"tenant": 1}, "action": "delete"}) }
test_equal_boolean_tenants_denied if { denied({"subject": {"role": "admin", "tenant": true}, "resource": {"tenant": true}, "action": "delete"}) }
test_equal_null_tenants_denied if { denied({"subject": {"role": "admin", "tenant": null}, "resource": {"tenant": null}, "action": "delete"}) }
test_tenant_not_normalized_denied if { denied(request(object.union(admin, {"tenant": "tenant-a "}), "delete")) }

test_unknown_action_denied if { denied(request(admin, "write")) }
test_missing_action_denied if { denied({"subject": admin, "resource": {"tenant": "tenant-a"}}) }
test_nonstring_action_denied if { denied(request(admin, 1)) }
test_case_changed_action_denied if { denied(request(admin, "DELETE")) }
test_whitespace_action_denied if { denied(request(admin, "delete ")) }
test_missing_role_denied if { denied(request({"reputation": 100, "tenant": "tenant-a"}, "delete")) }
test_empty_role_denied if { denied(request(object.union(moderator, {"role": ""}), "delete")) }
test_nonstring_role_denied if { denied(request(object.union(moderator, {"role": 1}), "delete")) }
test_missing_review_reputation_denied if { denied(request({"role": "customer", "tenant": "tenant-a"}, "review")) }
test_missing_nonadmin_delete_reputation_denied if { denied(request({"role": "guest", "tenant": "tenant-a"}, "delete")) }
test_missing_admin_review_reputation_denied if { denied(request(admin, "review")) }
test_string_review_reputation_denied if { denied(request(object.union(customer, {"reputation": "100"}), "review")) }
test_string_delete_reputation_denied if { denied(request(object.union(moderator, {"reputation": "100"}), "delete")) }
test_boolean_delete_reputation_denied if { denied(request(object.union(moderator, {"reputation": true}), "delete")) }
test_null_delete_reputation_denied if { denied(request(object.union(moderator, {"reputation": null}), "delete")) }
test_admin_string_reputation_denied if { denied(request(object.union(admin, {"reputation": "100"}), "delete")) }
test_admin_null_reputation_denied if { denied(request(object.union(admin, {"reputation": null}), "delete")) }

test_missing_subject_denied if { denied({"resource": {"tenant": "tenant-a"}, "action": "delete"}) }
test_missing_resource_denied if { denied({"subject": admin, "action": "delete"}) }
test_null_subject_denied if { denied({"subject": null, "resource": {"tenant": "tenant-a"}, "action": "delete"}) }
test_nonobject_resource_denied if { denied({"subject": admin, "resource": ["tenant-a"], "action": "delete"}) }
test_null_input_denied if { denied(null) }
test_array_input_denied if { denied([]) }
