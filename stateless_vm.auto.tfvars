stateless_vm_region            = null
stateless_vm_count             = 1
stateless_vm_name_prefix       = "stateless-vm"
stateless_vm_network_id        = "UUID-OF-TENANT-NETWORK"
stateless_vm_image_name        = "Ubuntu 22.04 LTS"
stateless_vm_flavor_name       = "eo2a.medium"
stateless_vm_key_pair          = "my-key"
stateless_vm_availability_zone = null
stateless_vm_config_drive      = false
stateless_vm_user_data         = null
stateless_vm_security_group_id = "UUID-OF-SECURITY-GROUP"
stateless_vm_attach_fip        = false

# Set in shell before apply — never commit to version control:
# export TF_VAR_stateless_vm_created_by=$OS_USERNAME

stateless_vm_client_project    = "my-client-project"
stateless_vm_extra_metadata    = {
  key1 = "value1",
  key2 = "value2"
}


