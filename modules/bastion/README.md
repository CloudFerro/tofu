# Bastion module with Guacamole

This repository provisions an OpenStack virtual machine with OpenTofu and bootstraps Apache Guacamole with cloud-init.

## What gets deployed

- one OpenStack VM
- one Neutron port
- one security group
- optional floating IP from the `external` network
- Apache Guacamole stack on the VM using Docker:
  - PostgreSQL
  - guacd
  - guacamole 1.6.0
  - nginx with a self-signed TLS certificate
  - recording storage extension for in-browser playback from history

## Important defaults

- the root module now renders `files/bastion-cloud-init.yml.tftpl` and passes it as `user_data`
- `bastion_user_data` still overrides the generated Guacamole bootstrap if you want to provide your own cloud-init
- `bastion_allowed_tcp_ports` should include `80` and `443` so the web UI is reachable
- `bastion_attach_fip = true` is recommended if you want to reach the service from outside the tenant network
- Guacamole is exposed at `https://<vm-ip>/guacamole/`
- the initial Guacamole login is the upstream default: `guacadmin` / `guacadmin`
- Guacamole is configured to trust `X-Forwarded-For` and `X-Forwarded-Proto`, so login and history should show the real client IP behind nginx

Change the default Guacamole password immediately after first login.

## Recordings

The deployment now includes the official recording storage extension. Recordings are stored on the VM under `/opt/guacamole/recordings` and can be shown directly from the Guacamole history UI if the connection itself is configured to record sessions.

Recommended per-connection settings in Guacamole:

- enable session recording
- set recording path to `$${HISTORY_PATH}`
- set recording name to `$${HISTORY_UUID}`

After that, the recording will appear as a `View` link in the `Logs` column of the history screen.

## Two-factor authentication

The deployment installs the official TOTP extension during bootstrap, so Guacamole can require MFA with authenticator codes.

To use TOTP:

- recreate the VM or rerun the bootstrap so the updated cloud-init installs `guacamole-auth-totp`
- restart `guacamole-web` if you install the jar manually on an existing machine
- let users enroll on next login with an authenticator app like Aegis, 2FAS, Authy, or Google Authenticator

With Guacamole 1.6.0 you can disable the TOTP requirement per user or per group after the extension is enabled.

## Firefox On Linux

If copy and paste does not work at all in Firefox on Linux, open `about:config`, search for `dom.events.testing.asyncClipboard`, and set it to `true`.

## Users, connections, and permissions

The repository now supports first-boot seed data through Terraform variables:

- `bastion_guacamole_users` creates Guacamole users through the REST API after the stack becomes ready
- `bastion_guacamole_connections` creates Guacamole connections and grants listed users `READ` access to each created connection
- `bastion_guacamole_openstack_instances` converts a simpler OpenStack-style inventory into Guacamole connections automatically
- connection grants are additive and only applied if the user exists or is created by the same seed payload

This is intended for fresh VM bootstrap. The seed script authenticates as the default `guacadmin` account, so if you reuse an existing Guacamole data volume with a changed admin password, recreate the VM or adjust the data manually first.

Store Guacamole seed data in a separate auto-loaded file named `guacamole.auto.tfvars`. This keeps Bastion infrastructure settings in `bastion.auto.tfvars` and avoids accidentally rebuilding the VM with empty Guacamole seed arrays.

If you want to add connections for all instances in the OpenStack project, the practical approach in this repository is to export a lightweight instance inventory and feed it into `bastion_guacamole_openstack_instances`, which then generates Guacamole connections automatically.

Access can be limited with:

- per-user permissions on individual connections
- user groups with inherited permissions
- administrative permissions separated from simple connection usage
- TOTP disable or enforce behavior per user or group when MFA is enabled

Example `guacamole.auto.tfvars`:

```hcl
bastion_guacamole_users = [
  {
    username = "ops"
    password = "change-me-now"
  },
  {
    username = "audit"
    password = "change-me-now-too"
    attributes = {
      timezone = "Europe/Warsaw"
    }
  }
]

bastion_guacamole_connections = [
  {
    name       = "controller-01-ssh"
    protocol   = "ssh"
    users      = ["ops", "audit"]
    parameters = {
      hostname = "10.10.0.11"
      port     = "22"
      username = "ubuntu"
      "recording-path" = "$${HISTORY_PATH}"
      "recording-name" = "$${HISTORY_UUID}"
    }
  }
]

bastion_guacamole_openstack_instances = [
  {
    name     = "worker-01"
    address  = "10.10.0.21"
    protocol = "ssh"
    username = "ubuntu"
    users    = ["ops"]
    parameters = {
      "recording-path" = "$${HISTORY_PATH}"
      "recording-name" = "$${HISTORY_UUID}"
    }
  },
  {
    name      = "windows-01"
    address   = "10.10.0.31"
    protocol  = "rdp"
    username  = "Administrator"
    password  = "change-me"
    users     = ["ops", "audit"]
  }
]
```

Example inventory generation from OpenStack CLI:

```bash
openstack server list -f json | jq '[.[] | {name: .Name, address: (.Networks | split("=")[1] | split(",")[0]), protocol: "ssh", username: "ubuntu", users: ["ops"]}]'
```

Helper script for generating ready-to-paste HCL for `guacamole.auto.tfvars`:

```bash
openstack server list -f json \
| ./files/generate-guacamole-openstack-inventory.sh \
--username eouser \
--users ops,audit \
--user ops=haslo1 \
--user audit=haslo2 \
--parameter recording-path='${HISTORY_PATH}' \
--parameter recording-name='${HISTORY_UUID}'
```

To update the file in place without duplicating the variable, use:

```bash
openstack server list -f json \
| ./files/generate-guacamole-openstack-inventory.sh \
--username eouser \
--users ops,audit \
--user ops=haslo1 \
--user audit=haslo2 \
--parameter recording-path='${HISTORY_PATH}' \
--parameter recording-name='${HISTORY_UUID}' \
--tfvars-file ./guacamole.auto.tfvars
```

## Required variables

Update `bastion.auto.tfvars` with values valid in your OpenStack project:

```hcl
bastion_region            = null
bastion_count             = 1
bastion_name_prefix       = "bastion"
bastion_network_id        = "UUID-OF-TENANT-NETWORK"
bastion_image_name        = "Ubuntu 22.04 LTS"
bastion_flavor_name       = "eo2a.medium"
bastion_key_pair          = "your-keypair"
bastion_availability_zone = null
bastion_metadata          = {}
bastion_user_data         = null
bastion_config_drive      = false
bastion_allowed_tcp_ports = [22, 80, 443]
bastion_attach_fip        = true
```

Keep Guacamole users and connections in `guacamole.auto.tfvars`:

```hcl
bastion_guacamole_users = []

bastion_guacamole_connections = []

bastion_guacamole_openstack_instances = []
```

## Deploy

Load your OpenStack credentials and apply the stack:

```bash
cd /home/jdunia/playbook/bastion/tofu-bastion
source openrc.sh
tofu init
tofu plan
tofu apply
```

## Verify

List the VM in OpenStack:

```bash
openstack server list
openstack server show <server-name-or-id>
```

Check Guacamole bootstrap from the VM console or SSH session:

```bash
cloud-init status
sudo tail -f /var/log/cloud-init-output.log
docker ps
```

Then open:

```text
https://<floating-ip>/guacamole/
```

The TLS certificate is self-signed by default.
