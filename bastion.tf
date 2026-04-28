locals {
  guacamole_connection_parameter_names = toset([
    "recording-path",
    "create-recording-path",
    "recording-name",
    "recording-exclude-output",
    "recording-exclude-mouse",
    "recording-include-keys",
    "recording-write-existing",
    "typescript-path",
    "create-typescript-path",
    "typescript-name",
    "typescript-write-existing"
  ])

  guacamole_generated_connections = [
    for instance in var.bastion_guacamole_openstack_instances : {
      name              = instance.name
      protocol          = instance.protocol
      parent_identifier = instance.parent_identifier
      users             = instance.users
      attributes = {
        for key, value in try(instance.attributes, {}) : key => value
        if !contains(local.guacamole_connection_parameter_names, key)
      }
      parameters = merge(
        {
          hostname = instance.address
          port = tostring(coalesce(
            try(instance.port, null),
            instance.protocol == "ssh" ? 22 : null,
            instance.protocol == "rdp" ? 3389 : null,
            instance.protocol == "vnc" ? 5900 : null,
            instance.protocol == "telnet" ? 23 : null,
            instance.protocol == "kubernetes" ? 443 : null
          ))
        },
        instance.protocol == "ssh" ? { "server-alive-interval" = "15" } : {},
        try(instance.parameters, {}),
        {
          for key, value in try(instance.attributes, {}) : key => value
          if contains(local.guacamole_connection_parameter_names, key)
        },
        try(instance.username, null) != null ? { username = instance.username } : {},
        try(instance.password, null) != null ? { password = instance.password } : {},
        try(instance.private_key, null) != null ? { "private-key" = instance.private_key } : {},
        (
          contains(keys(merge(
            try(instance.parameters, {}),
            {
              for key, value in try(instance.attributes, {}) : key => value
              if contains(local.guacamole_connection_parameter_names, key)
            }
          )), "recording-path")
          && !contains(keys(merge(
            try(instance.parameters, {}),
            {
              for key, value in try(instance.attributes, {}) : key => value
              if contains(local.guacamole_connection_parameter_names, key)
            }
          )), "recording-name")
        ) ? { "recording-name" = "$${HISTORY_UUID}" } : {}
      )
    }
  ]

  guacamole_explicit_connections = [
    for connection in var.bastion_guacamole_connections : merge(connection, {
      attributes = {
        for key, value in try(connection.attributes, {}) : key => value
        if !contains(local.guacamole_connection_parameter_names, key)
      }
      parameters = merge(
        connection.protocol == "ssh" ? { "server-alive-interval" = "15" } : {},
        connection.parameters,
        {
          for key, value in try(connection.attributes, {}) : key => value
          if contains(local.guacamole_connection_parameter_names, key)
        },
        (
          contains(keys(merge(
            connection.parameters,
            {
              for key, value in try(connection.attributes, {}) : key => value
              if contains(local.guacamole_connection_parameter_names, key)
            }
          )), "recording-path")
          && !contains(keys(merge(
            connection.parameters,
            {
              for key, value in try(connection.attributes, {}) : key => value
              if contains(local.guacamole_connection_parameter_names, key)
            }
          )), "recording-name")
        ) ? { "recording-name" = "$${HISTORY_UUID}" } : {}
      )
    })
  ]

  guacamole_all_connections = concat(local.guacamole_generated_connections, local.guacamole_explicit_connections)

  bastion_cloud_init = templatefile("${path.module}/files/bastion-cloud-init.yml.tftpl", {
    guacamole_users_json       = jsonencode(var.bastion_guacamole_users)
    guacamole_connections_json = jsonencode(local.guacamole_all_connections)
  })
}

module "bastion" {
  source = "./modules/bastion"

  region            = var.bastion_region
  vm_count          = var.bastion_count
  name_prefix       = var.bastion_name_prefix
  network_id        = var.bastion_network_id
  image_name        = var.bastion_image_name
  flavor_name       = var.bastion_flavor_name
  key_pair          = var.bastion_key_pair
  availability_zone = var.bastion_availability_zone
  metadata          = var.bastion_metadata
  user_data         = coalesce(var.bastion_user_data, local.bastion_cloud_init)
  config_drive      = var.bastion_config_drive
  allowed_tcp_ports = var.bastion_allowed_tcp_ports
  attach_fip        = var.bastion_attach_fip
}
