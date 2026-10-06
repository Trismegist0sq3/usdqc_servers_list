#!/bin/bash
# Name     :  usdqc_servers_list.sh
# Date     :  10/6/2026
# Author   :  Trismegist0s
# Purpose  :  Show only servers that have players, excluding "[ServeMe]" names,
#             displaying server name in green and player names in white.

declare -a qwna_servers=(
    "tx.usdqc.com:28501"
    "tx.usdqc.com:28502"
    "usaquake.com:27500"
    "usaquake.com:27501"
    "usaquake.com:27502"
    "usaquake.com:27503"
    "tx.usdqc.com:27502"
    "tx.usdqc.com:27503"
    "tx.usdqc.com:27504"
)

for server in "${qwna_servers[@]}"; do
    
    ###############################################
    # 1) Grab qstat -P Output into a Single String
    ###############################################
    qstat_output=$(/usr/bin/qstat -qws "$server" -P 2>/dev/null)

    # If qstat returned nothing, skip
    [[ -z "$qstat_output" ]] && continue

    ###############################################
    # 2) Extract Player Totals from the "server line"
    #
    #    The server line typically looks like:
    #    la.qwsrv.com:28501   0/4   2/12 maphub_v1 ...
    #
    #    We'll match on the exact server address in column 1
    #    and then parse columns 2 & 3 → "0/4" and "2/12".
    ###############################################
    read -r spectators players < <(
      echo "$qstat_output" \
      | awk -v srvr="$server" '
          $1 == srvr {
            print $2, $3
          }
        '
    )

    # If we didn't match anything, skip
    [[ -z "$spectators" || -z "$players" ]] && continue

    # Convert "0/4" → "0"; "2/12" → "2"
    spec_num=$(echo "$spectators" | cut -d/ -f1)
    play_num=$(echo "$players"    | cut -d/ -f1)

    # Make sure parsed values are actually integers
    [[ "$spec_num" =~ ^[0-9]+$ ]] || spec_num=0
    [[ "$play_num" =~ ^[0-9]+$ ]] || play_num=0

    total=$(( spec_num + play_num ))

    #######################################################
    # 3) We do have players. Now parse the “player lines.”
    #
    #    Player lines look like:
    #      #39  -9999 frags ... Trismegist0s blue
    #
    #    Exclude any line with "[ServeMe]".
    #    Print the second-to-last field, e.g. "Trismegist0s".
    #######################################################
    player_names=$(
      echo "$qstat_output" \
      | awk '
          /^[[:space:]]*#[0-9]+/ && !/\[ServeMe\]/ {
            if (NF >= 2) {
              print $(NF-1)
            }
          }
        '
    )

    # If after filtering, no names remain, skip
    [[ -z "$player_names" ]] && continue

    ###############################################
    # 4) Output (with colors)
    ###############################################
    # Green for server, white for players
    echo -e "$server"
    
    # player_names could have multiple lines, so read line by line
    while IFS= read -r pname; do
        echo -e "$pname"
    done <<< "$player_names"
    
    echo
done
