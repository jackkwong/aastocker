#!/bin/bash
source lib.sh

symbol="$1"
language="${2:-en}"

file_basic_info="`mktemp`"
file_financial_ratio="`mktemp`"
trap "rm -f '$file_basic_info' '$file_financial_ratio';exit 0" EXIT

echo fetching basic information... >&2
getBasicInformation "$symbol" "$language" > "$file_basic_info" &
pid_job1=$!
echo fetching financial ratio... >&2
getFinancialRatio "$symbol" "$language" > "$file_financial_ratio" &
pid_job2=$!
echo waiting for completion... >&2
wait $pid_job1 $pid_job2
echo done >&2
jq -n --arg stock_code "$symbol" --argfile basic_information "$file_basic_info" --argfile financial_ratio "$file_financial_ratio" '{$stock_code, $basic_information, $financial_ratio}'
