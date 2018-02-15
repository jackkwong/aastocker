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
    | {
        "stock_code": .stock_code,
        "name": .basic_information."公司名稱"
    }
)
| sort_by(.stock_code | tonumber) 
| map("\(.stock_code) - \(.name)") 
| .[]
JQ_FILTER
`"

cat main_board/tc/*.json | jq -s -r "$filter"