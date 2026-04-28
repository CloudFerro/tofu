locals {
  user_data_path = "${path.root}/files/${var.name_prefix}-cloud-init.yml"
}

resource "terraform_data" "stateless_vm_flavor_tracker" {
  count = var.vm_count

  triggers_replace = {
    flavor = var.flavor_name
  }
}

resource "openstack_networking_port_v2" "stateless_vm_port" {
  count = var.vm_count

  name           = format("%s-%02d-port", var.name_prefix, count.index + 1)
  network_id     = var.network_id
  admin_state_up = true
  region         = var.region

  security_group_ids = [
    var.security_group_id
  ]

#  lifecycle {
#    # Port is never replaced — VM keeps its IP across flavor changes and rebuilds
#    ignore_changes = [
#      security_group_ids,
#    ]
#  }
}

resource "openstack_compute_instance_v2" "stateless_vm" {
  count = var.vm_count

  name              = format("%s-%02d", var.name_prefix, count.index + 1)
  image_name        = var.image_name
  flavor_name       = var.flavor_name
  key_pair          = var.key_pair
  availability_zone = var.availability_zone
  config_drive      = var.config_drive
  region            = var.region

  network {
    port = openstack_networking_port_v2.stateless_vm_port[count.index].id
  }

  metadata = merge(
    {
      created_by      = var.created_by
      client_project  = var.client_project
      managed_by      = "opentofu"
    },
    var.extra_metadata
  )

  user_data = fileexists(local.user_data_path) ? file(local.user_data_path) : var.user_data

  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      terraform_data.stateless_vm_flavor_tracker[count.index]
    ]
#    ignore_changes = [
#      access_ip_v4,
#      access_ip_v6,
#      all_metadata,
#      all_tags,
#    ]
  }

  depends_on = [
    openstack_networking_port_v2.stateless_vm_port,
    terraform_data.stateless_vm_flavor_tracker
  ]
}

resource "openstack_networking_floatingip_v2" "stateless_vm_fip" {
  count = var.attach_fip ? var.vm_count : 0

  pool   = "external"
  region = var.region

  lifecycle {
    prevent_destroy = false
    ignore_changes  = all
  }
}

resource "openstack_networking_floatingip_associate_v2" "stateless_vm_fip_assoc" {
  count = var.attach_fip ? var.vm_count : 0

  floating_ip = openstack_networking_floatingip_v2.stateless_vm_fip[count.index].address
  port_id     = openstack_networking_port_v2.stateless_vm_port[count.index].id
  region      = var.region

  depends_on = [
    openstack_compute_instance_v2.stateless_vm,
    openstack_networking_floatingip_v2.stateless_vm_fip
  ]
}

