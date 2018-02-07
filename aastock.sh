#!/bin/bash
source lib.sh

symbol="$1"
language="${2:-en}"

file_basic_info="`mktemp`"
file_financial_ratio="`mktemp`"
file_profit_loss="`mktemp`"
file_dividend_history="`mktemp`"
trap "rm -f '$file_basic_info' '$file_financial_ratio' '$file_profit_loss' '$file_dividend_history';exit 0" EXIT

echo fetching basic information... >&2
getBasicInformation "$symbol" "$language" > "$file_basic_info" &
pid_job1=$!
echo fetching financial ratio... >&2
getFinancialRatio "$symbol" "$language" > "$file_financial_ratio" &
pid_job2=$!
echo fetching profit loss... >&2
getProfitLoss "$symbol" "$language" > "$file_profit_loss" &
pid_job3=$!
echo fetching dividend history... >&2
getDividendHistory "$symbol" "$language" > "$file_dividend_history" &
pid_job4=$!
echo waiting for completion... >&2
wait $pid_job1 $pid_job2 $pid_job3 $pid_job4
echo done >&2
jq -n \
    --arg stock_code "$symbol" \
    --argfile basic_information "$file_basic_info" \
    --argfile financial_ratio "$file_financial_ratio" \
    --argfile profit_loss "$file_profit_loss" \
    --argfile dividend_history "$file_dividend_history" \
    '{$stock_code, $basic_information, $financial_ratio, $profit_loss, $dividend_history}'
