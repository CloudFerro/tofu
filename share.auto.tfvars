share_region               = null
share_enabled              = true
share_name                 = "project-data"
share_description          = "Project Manila share"
share_proto                = "NFS"
share_size                 = 20
share_type                 = "sfs-nvme"
#provide share_network_id only with share_type "generic_nvme"
#share_network_id           = "UUID-OF-SHARE-NETWORK"
share_availability_zone    = null
share_metadata             = {}
share_allowed_instance_ips = [
  "10.10.10.11",
  "10.10.20.22"
]
share_access_level         = "rw"
share_generate_mount_script = true

