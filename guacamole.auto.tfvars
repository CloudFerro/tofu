#sample config file for initial configuration of Guacamole.
#Generate your own version of this file if you want to have initial configuration BEFORE running tofu apply with generate-guacamole-openstack-inventory.sh script located in "files" directory. 
#You can safely run tofu apply without this file and add servers and users later via WebGUI.
#More informations in bastion module README.md file.

bastion_guacamole_connections = []

#additional Guacamole users
bastion_guacamole_users = [
  {
    username = "ops"
    password = "ops_USER_PASS"
  },
  {
    username = "audit"
    password = "audit_USER_PASS"
  }
]

#initial host connections list
bastion_guacamole_openstack_instances = [
  {
    name     = "stateless-vm-01"
    address  = "VM_IP_ADDRESS"
    protocol = "ssh"
    username = "eouser"
    users    = ["ops", "audit"]
    parameters = {
      "recording-path" = "$${HISTORY_PATH}"
      "recording-name" = "$${HISTORY_UUID}"
    }
  },
  {
    name     = "ha-tier-01"
    address  = "VM_IP_ADDRESS"
    protocol = "ssh"
    username = "eouser"
    users    = ["ops", "audit"]
    parameters = {
      "recording-path" = "$${HISTORY_PATH}"
      "recording-name" = "$${HISTORY_UUID}"
    }
  },
  {
    name     = "ha-tier-02"
    address  = "VM_IP_ADDRESS"
    protocol = "ssh"
    username = "eouser"
    users    = ["ops", "audit"]
    parameters = {
      "recording-path" = "$${HISTORY_PATH}"
      "recording-name" = "$${HISTORY_UUID}"
    }
  },
  {
    name     = "simple-vm-01"
    address  = "VM_IP_ADDRESS"
    protocol = "ssh"
    username = "eouser"
    users    = ["ops", "audit"]
    parameters = {
      "recording-path" = "$${HISTORY_PATH}"
      "recording-name" = "$${HISTORY_UUID}"
    }
  },
  {
    name     = "data-server-01"
    address  = "VM_IP_ADDRESS"
    protocol = "ssh"
    username = "eouser"
    users    = ["ops", "audit"]
    parameters = {
      "recording-path" = "$${HISTORY_PATH}"
      "recording-name" = "$${HISTORY_UUID}"
    }
  },
  {
    name     = "data-server-02"
    address  = "VM_IP_ADDRESS"
    protocol = "ssh"
    username = "eouser"
    users    = ["ops", "audit"]
    parameters = {
      "recording-path" = "$${HISTORY_PATH}"
      "recording-name" = "$${HISTORY_UUID}"
    }
  }
]
