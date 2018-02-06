#!/bin/bash
source lib.sh
mkdir -p company_data
cat hsi.txt | sed 's/\..*//' | (while read i; do echo "fetching $i..." >&2; getBasicInformation $i > company_data/"$i.json"; done)
