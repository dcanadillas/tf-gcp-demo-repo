policy "enforce_mandatory_labels" {
    source = "./enforce_mandatory_labels.sentinel"
    enforcement_level = "advisory"
}

policy "restrict_vm_gcp" {
    source = "./restrict_vm_gcp.sentinel"
    enforcement_level = "soft_mandatory"
}
