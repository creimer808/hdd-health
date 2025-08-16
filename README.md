HDD Health JSON

A lightweight Bash script that collects SMART health information for multiple hard drives and outputs the results in structured JSON format.
It is designed to work with smartctl and jq, making it easy to integrate with monitoring systems, dashboards, or log collectors.

Features

Scans predefined drives (/dev/sda through /dev/sde by default).

Collects and summarizes SMART data including:

Drive model and serial number

Overall SMART health status (PASSED/FAILED)

Current temperature

Key attributes:

Reallocated sectors (ID 5)

Pending sectors (ID 197)

Uncorrectable sectors (ID 198)

CRC errors (ID 199)

Power-on hours

Outputs results as JSON (array of drive objects).

Saves JSON report both to stdout and as hddhealth.json in the same directory as the script.
