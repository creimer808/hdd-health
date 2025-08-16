#!/usr/bin/env bash
# hddhealth-json.sh — SMART summary for /dev/sda–/dev/sde in JSON
set -euo pipefail
DRIVES=(/dev/sda /dev/sdb /dev/sdc /dev/sdd /dev/sde)

need() { command -v "$1" >/dev/null || { echo "Missing $1. Install with: apt-get install -y $1" >&2; exit 1; }; }
need smartctl
need jq

# Collect JSON into a variable
json_output=$(
  first=true
  echo "["
  for dev in "${DRIVES[@]}"; do
    [[ -b "$dev" ]] || continue
    j=$(smartctl -j -H -A -i "$dev" 2>/dev/null)

    model=$(jq -r '.model_name // "-" ' <<<"$j")
    serial=$(jq -r '.serial_number // "-" ' <<<"$j")
    health=$(jq -r 'if .smart_status.passed==true then "PASSED" else "FAILED" end' <<<"$j")

    # Temperature
    temp=$(jq -r '.temperature.current? // (.ata_smart_attributes.table[]? | select(.id==194) | .raw.value) // "-" ' <<<"$j")
    temp=${temp%% *}; [[ "$temp" =~ ^[0-9]+$ ]] || temp=null

    # Helper for attributes
    get_attr() { jq -r --argjson id "$1" '(.ata_smart_attributes.table[]? | select(.id==$id) | .raw.value) // null' <<<"$j"; }

    realloc=$(get_attr 5)
    pending=$(get_attr 197)
    uncorr=$(get_attr 198)
    crc=$(get_attr 199)

    # Power-on hours
    poh=$(jq -r '.power_on_time.hours? // empty' <<<"$j")
    if [[ -z "$poh" || "$poh" == "null" ]]; then
      raw9=$(get_attr 9)
      if [[ "$raw9" =~ ^([0-9]+)h ]]; then poh="${BASH_REMATCH[1]}"
      elif [[ "$raw9" =~ ^[0-9]+$ ]]; then poh="$raw9"
      else poh=null
      fi
    fi

    $first || echo ","
    first=false
    jq -n \
      --arg drive "$(basename "$dev")" \
      --arg model "$model" \
      --arg serial "$serial" \
      --arg health "$health" \
      --argjson temp "${temp:-null}" \
      --argjson realloc "${realloc:-null}" \
      --argjson pending "${pending:-null}" \
      --argjson uncorr "${uncorr:-null}" \
      --argjson poh "${poh:-null}" \
      --argjson crc "${crc:-null}" \
      '{drive:$drive, model:$model, serial:$serial,
        health:$health, temp:$temp,
        realloc:$realloc, pending:$pending,
        uncorr:$uncorr, poh:$poh, crc:$crc}'
  done
  echo "]"
)

# Print to stdout
echo "$json_output"

# Always overwrite /root/scripts/hddhealth.json (same dir as script)
script_dir="$(dirname "$0")"
echo "$json_output" > "$script_dir/hddhealth.json"
