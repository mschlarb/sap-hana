# Generate random text for a unique storage account name.
resource "random_id" "randomId" {
  keepers = {
    # Generate a new id only when a new resource group is defined.
    resource_group = "${var.az_resource_group}"
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "bootdiagstorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = "${var.az_resource_group}"
  location                 = "${var.az_region}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Terraform SAP HANA deployment"
  }
}

# All disks that are in the storage_disk_sizes_data list will be created
resource "azurerm_managed_disk" "disk_data" {
  count                = "${length(var.storage_disk_sizes_data)}"
  name                 = "${var.machine_name}-datadisk${count.index}"
  location             = "${var.az_region}"
  storage_account_type = "Premium_LRS"
  resource_group_name  = "${var.az_resource_group}"
  disk_size_gb         = "${var.storage_disk_sizes_data[count.index]}"
  create_option        = "Empty"
}

# All of the disks created above will now be attached to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "disk_data" {
  count              = "${length(var.storage_disk_sizes_data)}"
  virtual_machine_id = "${azurerm_virtual_machine.vm.id}"
  managed_disk_id    = "${element(azurerm_managed_disk.disk_data.*.id, count.index)}"
  lun                = "${count.index}"
  caching            = "ReadOnly"
}

# All disks that are in the storage_disk_sizes_log list will be created
resource "azurerm_managed_disk" "disk_log" {
  count                = "${length(var.storage_disk_sizes_log)}"
  name                 = "${var.machine_name}-logdisk${count.index}"
  location             = "${var.az_region}"
  storage_account_type = "Premium_LRS"
  resource_group_name  = "${var.az_resource_group}"
  disk_size_gb         = "${var.storage_disk_sizes_log[count.index]}"
  create_option        = "Empty"
}

# All of the disks created above will now be attached to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "disk_log" {
  count              = "${length(var.storage_disk_sizes_log)}"
  virtual_machine_id = "${azurerm_virtual_machine.vm.id}"
  managed_disk_id    = "${element(azurerm_managed_disk.disk_log.*.id, count.index)}"
  lun                = "${count.index + length(var.storage_disk_sizes_data)}"
  caching            = "None"
  write_accelerator_enabled = "${var.write_accelerator}"
}

# All disks that are in the storage_disk_sizes_shared list will be created
resource "azurerm_managed_disk" "disk_shared" {
  count                = "${length(var.storage_disk_sizes_shared)}"
  name                 = "${var.machine_name}-shareddisk${count.index}"
  location             = "${var.az_region}"
  storage_account_type = "Premium_LRS"
  resource_group_name  = "${var.az_resource_group}"
  disk_size_gb         = "${var.storage_disk_sizes_shared[count.index]}"
  create_option        = "Empty"
}

# All of the disks created above will now be attached to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "disk_shared" {
  count              = "${length(var.storage_disk_sizes_shared)}"
  virtual_machine_id = "${azurerm_virtual_machine.vm.id}"
  managed_disk_id    = "${element(azurerm_managed_disk.disk_shared.*.id, count.index)}"
  lun                = "${count.index + length(var.storage_disk_sizes_data) + length(var.storage_disk_sizes_log)}"
  caching            = "ReadWrite"
}

# Create virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                          = "${var.machine_name}"
  location                      = "${var.az_region}"
  resource_group_name           = "${var.az_resource_group}"
  network_interface_ids         = ["${var.nic_id}"]
  availability_set_id           = "${var.availability_set_id}"
  vm_size                       = "${var.vm_size}"
  delete_os_disk_on_termination = "true"
  zones = ["${var.zone}"]

  storage_os_disk {
    name              = "${var.machine_name}-OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
# Replace with custom image
  storage_image_reference {
    publisher = "SUSE"
    offer     = "SLES-SAP"
    sku       = "12-SP3"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.machine_name}"
    admin_username = "${var.vm_user}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.vm_user}/.ssh/authorized_keys"
      key_data = "${file("${var.sshkey_path_public}")}"
    }
  }

  boot_diagnostics {
    enabled = "true"

    storage_uri = "${azurerm_storage_account.bootdiagstorageaccount.primary_blob_endpoint}"
  }

}
