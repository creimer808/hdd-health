# HDD Health Monitor for n8n & Discord

A lightweight Bash script designed to check the S.M.A.R.T. health status of your storage drives, compile a clean status report, and format the output so it can easily be processed by n8n to send real-time alerts directly to Discord.

## Features

- **Automated S.M.A.R.T. Checks**: Pulls raw diagnostic data using `smartctl`.
- **Dynamic Status Report**: Monitors drive passage/failure states, temperatures, reallocated sector counts, and power-on hours.
- **Fun Alert Variations**: Generates randomized emojis and status messages for both healthy states and warning states.
- **n8n Ready**: Formatted text output that fits perfectly into SSH execution nodes or command-line nodes to pass down stream to Webhooks (like Discord/ntfy).

---

## Prerequisites

Before setting up the script, ensure your system has `smartmontools` installed:

### On Debian / Ubuntu:
```bash
sudo apt update && sudo apt install smartmontools -y
