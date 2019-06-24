output "machine_hostname" {
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.disk_data,
    azurerm_virtual_machine_data_disk_attachment.disk_log,
    azurerm_virtual_machine_data_disk_attachment.disk_shared,
  ]

  value = "${var.machine_name}"
}
