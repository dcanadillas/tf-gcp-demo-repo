# output "vm-ips" {
#     value = google_compute_instance_from_template.tpl-vm.*.network_interface.0.access_config.0.nat_ip
# }
output "vm-ips" {
    value = google_compute_instance.vm.*.network_interface.0.access_config.0.nat_ip
}