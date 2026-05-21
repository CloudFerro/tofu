output "share" {
  description = "Created Manila share."
  value = var.share_enabled ? {
    id               = openstack_sharedfilesystem_share_v2.share[0].id
    name             = openstack_sharedfilesystem_share_v2.share[0].name
    share_proto      = openstack_sharedfilesystem_share_v2.share[0].share_proto
    size             = openstack_sharedfilesystem_share_v2.share[0].size
    share_type       = openstack_sharedfilesystem_share_v2.share[0].share_type
    share_network_id = openstack_sharedfilesystem_share_v2.share[0].share_network_id
    export_locations = openstack_sharedfilesystem_share_v2.share[0].export_locations
  } : null
}

output "share_access_rules" {
  description = "Created Manila share access rules."
  value = [
    for rule in openstack_sharedfilesystem_share_access_v2.ip_acl : {
      id           = rule.id
      access_type  = rule.access_type
      access_to    = rule.access_to
      access_level = rule.access_level
    }
  ]
}

output "mount_script" {
  description = "Generated mount script path in the root files directory."
  value = var.share_enabled && var.generate_mount_script ? {
    path      = "${path.root}/files/mount_${trim(replace(lower(var.name), "/[^0-9a-z]+/", "_"), "_")}_share.sh"
    mount_dir = "/mnt/${trim(replace(lower(var.name), "/[^0-9a-z]+/", "_"), "_")}"
  } : null
}
