#!/bin/bash

library="`cat <<-'JQ_LIBRARY'
def dividend_years_between(from; to):
    . as $dividend_history
    | $dividend_history
    | map( 
        select(
            ."派息內容"
            | test("股息[:：]", "x")
        )
        | {
            "year": ( ."年度/截至" | strptime("%Y/%m")? | .[0] ), 
            "dividend_content": ."派息內容"
        }
        | select( (.year | isnan | not) and .year >= from and .year <= to )
    )
    | group_by(.year)
;

def has_at_least_n_dividends(numberOfDividendYear; from; to):
    . as $dividend_history
    | $dividend_history
    | dividend_years_between(from; to)
    | length
    | . >= numberOfDividendYear
;
JQ_LIBRARY
`"

filter="`cat <<-JQ_FILTER
$library

map(
    select( .dividend_history | has_at_least_n_dividends(9; 2007; 2016) )
        | select((.financial_ratio."流動比率(倍)" | last | tonumber?) >= 1)
        | select((.financial_ratio."速動比率(倍)" | last | tonumber?) >= 1)
)
| sort_by(.stock_code | tonumber) 
| map("\(.stock_code) - \(.basic_information."公司名稱")
PE: \(.basic_information."市盈率(倍)")
PB: \(.basic_information."股價/每股淨資產值(倍)")
Yield: \(.basic_information."周息率(%)")
ROE: \( (.financial_ratio."股東權益回報率(%)" | join(" -> ")) )
") 
| .[]
JQ_FILTER
`"

cat main_board/tc/*.json | jq -s -r "$filter"