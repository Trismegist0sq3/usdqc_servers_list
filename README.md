# USDQC Server Player List

`usdqc_servers_list.sh` queries a predefined list of USDQC QuakeWorld servers and displays only servers that currently have players connected.

The script uses `qstat` to query each server and prints the server address followed by the names of connected players.

## Requirements

This script requires **qstat** to query QuakeWorld servers:

- [qstat - Server status query tool](https://github.com/rocketsciencegg/qstat)

## Usage

Make the script executable:

```bash
chmod +x usdqc_servers_list.sh
```

Run it:

```bash
./usdqc_servers_list.sh
```
