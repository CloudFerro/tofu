#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: generate-guacamole-openstack-inventory.sh [options]

Generate HCL for bastion_guacamole_openstack_instances from `openstack server list -f json`.

Options:
  --protocol <ssh|rdp|vnc|telnet|kubernetes>  Default protocol. Default: ssh
  --username <name>                           Default username to include
  --user <name=password>                      Add Guacamole user seed entry, can be repeated
  --users <csv>                               Comma-separated Guacamole users, e.g. ops,audit
  --network <label>                           Prefer address from a specific network label
  --port <number>                             Override port for all generated entries
  --parameter <key=value>                     Add connection parameter, can be repeated
  --attribute <key=value>                     Add connection attribute, can be repeated
  --tfvars-file <path>                        Replace bastion_guacamole_openstack_instances in a tfvars file
  --input <path>                              Read OpenStack JSON from file instead of stdin
  --help                                      Show this help
EOF
}

protocol="ssh"
username=""
users_csv=""
network_label=""
port_override=""
input_path=""
tfvars_file=""
declare -a user_pairs=()
declare -a parameter_pairs=()
declare -a attribute_pairs=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --protocol)
      protocol="$2"
      shift 2
      ;;
    --username)
      username="$2"
      shift 2
      ;;
    --user)
      user_pairs+=("$2")
      shift 2
      ;;
    --users)
      users_csv="$2"
      shift 2
      ;;
    --network)
      network_label="$2"
      shift 2
      ;;
    --port)
      port_override="$2"
      shift 2
      ;;
    --parameter)
      parameter_pairs+=("$2")
      shift 2
      ;;
    --attribute)
      attribute_pairs+=("$2")
      shift 2
      ;;
    --tfvars-file)
      tfvars_file="$2"
      shift 2
      ;;
    --input)
      input_path="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$protocol" in
  ssh|rdp|vnc|telnet|kubernetes) ;;
  *)
    echo "Unsupported protocol: $protocol" >&2
    exit 1
    ;;
esac

if [[ -n "$port_override" ]] && ! [[ "$port_override" =~ ^[0-9]+$ ]]; then
  echo "Port override must be numeric" >&2
  exit 1
fi

for pair in "${user_pairs[@]}"; do
  if [[ "$pair" != *=* ]]; then
    echo "User must be provided as name=password" >&2
    exit 1
  fi

  user_name="${pair%%=*}"
  user_password="${pair#*=}"
  if [[ -z "$user_name" || -z "$user_password" ]]; then
    echo "User name and password must be non-empty" >&2
    exit 1
  fi
done

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

if [[ -n "$input_path" ]]; then
  json_input="$(cat "$input_path")"
else
  json_input="$(cat)"
fi

if [[ -z "$json_input" ]]; then
  echo "No JSON input provided" >&2
  exit 1
fi

render_users() {
  local csv="$1"
  local output=""
  local item

  [[ -z "$csv" ]] && return 0

  output="    users    = ["
  IFS=',' read -r -a items <<< "$csv"
  for item in "${items[@]}"; do
    item="$(printf '%s' "$item" | xargs)"
    [[ -z "$item" ]] && continue
    if [[ "$output" != "    users    = [" ]]; then
      output+=", "
    fi
    output+="\"$item\""
  done
  output+="]"
  printf '%s\n' "$output"
}

render_user_seed_block() {
  local first=1
  local pair user_name user_password

  [[ ${#user_pairs[@]} -eq 0 ]] && return 0

  printf 'bastion_guacamole_users = [\n'
  for pair in "${user_pairs[@]}"; do
    user_name="${pair%%=*}"
    user_password="${pair#*=}"

    if [[ $first -eq 0 ]]; then
      printf ',\n'
    fi
    first=0

    printf '  {\n'
    printf '    username = "%s"\n' "$user_name"
    printf '    password = "%s"\n' "$(escape_hcl_value "$user_password")"
    printf '  }'
  done
  printf '\n]\n'
}

escape_hcl_value() {
  printf '%s' "$1" | perl -0pe 's/\$\$\{/__ESCAPED_TF_OPEN__/g; s/\$\{/\$\$\{/g; s/__ESCAPED_TF_OPEN__/\$\$\{/g'
}

render_attributes() {
  local pair key value
  [[ ${#attribute_pairs[@]} -eq 0 ]] && return 0

  printf '    attributes = {\n'
  for pair in "${attribute_pairs[@]}"; do
    key="${pair%%=*}"
    value="${pair#*=}"
    value="$(escape_hcl_value "$value")"
    printf '      "%s" = "%s"\n' "$key" "$value"
  done
  printf '    }\n'
}

render_parameters() {
  local pair key value
  [[ ${#parameter_pairs[@]} -eq 0 ]] && return 0

  printf '    parameters = {\n'
  for pair in "${parameter_pairs[@]}"; do
    key="${pair%%=*}"
    value="${pair#*=}"
    value="$(escape_hcl_value "$value")"
    printf '      "%s" = "%s"\n' "$key" "$value"
  done
  printf '    }\n'
}

pick_address() {
  local networks_json="$1"
  jq -rn --arg networks_json "$networks_json" --arg network "$network_label" '
    def trim:
      gsub("^\\s+|\\s+$"; "");

    def entries_from_string($value):
      $value
      | split(",")
      | map(trim)
      | map(select(length > 0))
      | map(
          if contains("=") then
            {
              label: (split("=")[0] | trim),
              addresses: [(split("=")[1:] | join("=") | trim)]
            }
          else
            { label: "", addresses: [.] }
          end
        );

    def entries_from_object($value):
      $value
      | to_entries
      | map(
          .key as $label
          | if (.value | type) == "array" then
              {
                label: $label,
                addresses: (.value | map(tostring | trim) | map(select(length > 0)))
              }
            elif (.value | type) == "string" then
              {
                label: $label,
                addresses: [(.value | trim)]
              }
            else
              {
                label: $label,
                addresses: []
              }
            end
        );

    ($networks_json | fromjson?) as $networks
    | (
        if $networks == null then
          []
        elif ($networks | type) == "string" then
          entries_from_string($networks)
        elif ($networks | type) == "object" then
          entries_from_object($networks)
        else
          []
        end
      ) as $entries
    | (
        if ($network | length) > 0 then
          ($entries | map(select(.label == $network)))
        else
          $entries
        end
      )
    | ((first? | .addresses[0]?) // "")
  '
}

update_tfvars_file() {
  local target_file="$1"
  local users_block="$2"
  local generated_block="$3"
  local temp_file
  local replace_users=0

  [[ -n "$users_block" ]] && replace_users=1

  temp_file="$(mktemp)"

  if [[ -f "$target_file" ]]; then
    awk -v replace_users="$replace_users" '
      BEGIN {
        skip_openstack = 0
        skip_users = 0
      }

      skip_openstack && /^\]$/ {
        skip_openstack = 0
        next
      }

      skip_users && /^\]$/ {
        skip_users = 0
        next
      }

      skip_openstack || skip_users {
        next
      }

      /^bastion_guacamole_openstack_instances[[:space:]]*=/ {
        skip_openstack = 1
        next
      }

      replace_users && /^bastion_guacamole_users[[:space:]]*=/ {
        skip_users = 1
        next
      }

      { print }
    ' "$target_file" > "$temp_file"
  fi

  if [[ -s "$temp_file" ]]; then
    printf '\n' >> "$temp_file"
  fi

  if [[ -n "$users_block" ]]; then
    printf '%s\n\n' "$users_block" >> "$temp_file"
  elif ! grep -Eq '^bastion_guacamole_users[[:space:]]*=' "$temp_file"; then
    printf 'bastion_guacamole_users = []\n\n' >> "$temp_file"
  fi

  if ! grep -Eq '^bastion_guacamole_connections[[:space:]]*=' "$temp_file"; then
    printf 'bastion_guacamole_connections = []\n\n' >> "$temp_file"
  fi

  printf '%s\n' "$generated_block" >> "$temp_file"
  mv "$temp_file" "$target_file"
}

users_block="$(render_user_seed_block || true)"

generated_block="$({
  printf 'bastion_guacamole_openstack_instances = [\n'

  first=1
  while IFS=$'\t' read -r name networks; do
    address="$(pick_address "$networks")"
    [[ -z "$address" ]] && continue

    if [[ $first -eq 0 ]]; then
      printf ',\n'
    fi
    first=0

    printf '  {\n'
    printf '    name     = "%s"\n' "$name"
    printf '    address  = "%s"\n' "$address"
    printf '    protocol = "%s"\n' "$protocol"
    if [[ -n "$username" ]]; then
      printf '    username = "%s"\n' "$username"
    fi
    if [[ -n "$port_override" ]]; then
      printf '    port     = %s\n' "$port_override"
    fi
    render_users "$users_csv"
    render_parameters
    render_attributes
    printf '  }'
  done < <(printf '%s' "$json_input" | jq -r '.[] | [.Name, ((.Networks // null) | @json)] | @tsv')

  printf '\n]\n'
})"

if [[ -n "$tfvars_file" ]]; then
  update_tfvars_file "$tfvars_file" "$users_block" "$generated_block"
else
  if [[ -n "$users_block" ]]; then
    printf '%s\n' "$users_block"
  fi
  printf '%s' "$generated_block"
fi