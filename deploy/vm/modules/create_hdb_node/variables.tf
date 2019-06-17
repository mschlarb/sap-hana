variable "availability_set_id" {
  description = "The id associated with the availability set to put this VM into."
  default     = ""                                                                 # Empty string denotes that this VM is not in an availability set.
}

variable "az_domain_name" {
  description = "Prefix to be used in the domain name"
}

variable "az_region" {}

variable "az_resource_group" {
  description = "Which Azure resource group to deploy the HANA setup into.  i.e. <myResourceGroup>"
}

variable "backend_ip_pool_ids" {
  type        = "list"
  description = "The ids that associate the load balancer's back end IP pool with this VM's NIC."
  default     = []
}

variable "hdb_num" {
  description = "The number of the node that is currently being created."
}

#variable "hana_subnet_id" {
#  description = "The HANA specific subnet that this node needs to be on."
#}

#variable "nsg_id" {
#  description = "The NSG id for the NSG that will control this VM."
#}

variable "private_ip_address" {
  description = "The desired private IP address of this NIC.  If it isn't specified, a dynamic IP will be allocated."
  default     = ""
}

variable "public_ip_allocation_type" {
  description = "Defines whether the IP address is static or dynamic. Options are Static or Dynamic."
}

variable "sap_sid" {
  default = "PV1"
}

variable "sshkey_path_public" {
  description = "The path on the local machine to where the public key is"
}

variable "storage_disk_sizes_data" {
  description = "List disk sizes in GB for all HANA data disks"
  default     = [512, 512, 512]
}

variable "storage_disk_sizes_log" {
  description = "List disk sizes in GB for all HANA log disks"
  default     = [32, 32]
}

variable "storage_disk_sizes_shared" {
  description = "List disk sizes in GB for all HANA shared disks"
  default     = [512]
}

variable "vm_size" {
  description = "Size of the VM"
}

variable "vm_user" {
  description = "The username of your HANA database VM."
}

variable "write_accelerator" {
  description = "Whether or not you want to enable write accelerator for HANA log disks - this requires certain VM types"
  default = false
}

variable "zone" {
  description = "Specify the availability zone"
  default = ["1"]
}

variable "hana_vnet_name" {
  description = "The name of the existing Vnet"
}

variable "hana_subnet_name" {
  description = "The name of the first subnet"
  default = "default"
}

locals {
  machine_name = "${lower(var.sap_sid)}-hdb${var.hdb_num}"
  vm_hdb_name  = "hdb${var.hdb_num}"
}
