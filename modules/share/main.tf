locals {
  acl_rules = {
    for idx, ip in var.allowed_instance_ips : idx => ip
    if trim(ip, " ") != ""
  }
  normalized_share_name = trim(replace(lower(var.name), "/[^0-9a-z]+/", "_"), "_")
  mount_dir             = "/mnt/${trim(local.normalized_share_name, "_")}"
  script_filename       = "${path.root}/files/mount_${trim(local.normalized_share_name, "_")}_share.sh"
}

resource "openstack_sharedfilesystem_share_v2" "share" {
  count = var.share_enabled ? 1 : 0

  name             = var.name
  description      = var.description
  share_proto      = var.share_proto
  size             = var.size
  share_type       = var.share_type
  is_public        = false
  share_network_id = var.share_network_id
  availability_zone = var.availability_zone
  metadata         = var.metadata
  region           = var.region
}

resource "openstack_sharedfilesystem_share_access_v2" "ip_acl" {
  for_each = var.share_enabled ? local.acl_rules : {}

  share_id      = openstack_sharedfilesystem_share_v2.share[0].id
  access_type   = "ip"
  access_to     = each.value
  access_level  = var.access_level
  region        = var.region

  depends_on = [
    openstack_sharedfilesystem_share_v2.share
  ]
}

resource "null_resource" "mount_script" {
  count = var.share_enabled && var.generate_mount_script ? 1 : 0

  triggers = {
    share_id         = openstack_sharedfilesystem_share_v2.share[0].id
    export_location  = try(openstack_sharedfilesystem_share_v2.share[0].export_locations[0].path, "")
    mount_dir        = local.mount_dir
    script_filename  = local.script_filename
    share_name       = var.name
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<-EOT
      set -euo pipefail

      /bin/mkdir -p "${path.root}/files"

      /bin/cat > "${local.script_filename}" <<'SCRIPT'
#!/usr/bin/env bash
set -u

SHARE_EXPORT='${try(openstack_sharedfilesystem_share_v2.share[0].export_locations[0].path, "")}'
MOUNT_DIR='${local.mount_dir}'
FSTAB_FILE='/etc/fstab'

if [ -z "$SHARE_EXPORT" ]; then
  /bin/echo "Mount error, check if share is accesible and apropriate share access list exists"
  exit 0
fi

EXISTING_FSTAB_SOURCE="$(/bin/findmnt --fstab --target "$MOUNT_DIR" -n -o SOURCE 2>/dev/null || true)"
if [ -n "$EXISTING_FSTAB_SOURCE" ] && [ "$EXISTING_FSTAB_SOURCE" != "$SHARE_EXPORT" ]; then
  /bin/echo "Another share has entry for this mount path in /etc/fstab !"
  exit 1
fi

CURRENT_MOUNT="$(/bin/findmnt -rn -S "$SHARE_EXPORT" -o TARGET 2>/dev/null || true)"
if [ -n "$CURRENT_MOUNT" ]; then
  /bin/echo "This share is already mounted in $CURRENT_MOUNT"
  exit 0
fi

sudo /bin/mkdir -p "$MOUNT_DIR"

FSTAB_LINE="$SHARE_EXPORT $MOUNT_DIR nfs defaults,_netdev,nofail 0 0"

if ! /bin/grep -Fqs "$SHARE_EXPORT $MOUNT_DIR " "$FSTAB_FILE"; then
  /bin/echo "$FSTAB_LINE" | sudo /usr/bin/tee -a "$FSTAB_FILE" >/dev/null
fi

if /bin/mountpoint -q "$MOUNT_DIR"; then
  /bin/echo "This share is already mounted in $MOUNT_DIR"
  exit 0
fi

if sudo /bin/mount "$MOUNT_DIR"; then
  if /bin/mountpoint -q "$MOUNT_DIR"; then
    /bin/echo "Share mounted in $MOUNT_DIR"
    exit 0
  fi
fi

/bin/echo "Mount error, check if share is accesible and apropriate share access list exists"
exit 1
SCRIPT

      /bin/chmod 0755 "${local.script_filename}"
    EOT
  }

  depends_on = [
    openstack_sharedfilesystem_share_v2.share,
    openstack_sharedfilesystem_share_access_v2.ip_acl
  ]
}

