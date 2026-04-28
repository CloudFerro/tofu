network_region      = null
network_name        = "tenant-net-1"
router_name         = "tenant-router-1"
external_network_id = "UUID-OF-EXTERNAL-NETWORK"

subnets = [
  {
    name       = "tenant-net-1-v4"
    cidr       = "192.168.123.0/24"
    ip_version = 4
    dns_nameservers = [ "192.168.123.10", "1.1.1.1" ]
    allocation_pools = [
      {
        start = "192.168.123.100"
        end   = "192.168.123.140"
      }
    ]
  }#,
#  {
#    name              = "tenant-dualstack-v6"
#    cidr              = "2001:db8:1234:20::/64"
#    ip_version        = 6
#    dns_nameservers   = [ "2001:db8:1234:20::10" ]
#    ipv6_address_mode = "dhcpv6-stateless"
#    ipv6_ra_mode      = "dhcpv6-stateless"
#    allocation_pools = [
#      {
#        start = "2001:db8:1234:20::100"
#        end   = "2001:db8:1234:20:ffff:ffff:ffff:ffff"
#      }
#    ]
#  }
]
