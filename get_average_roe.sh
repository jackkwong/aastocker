symbol=$1
source lib.sh
url="`getUrlFinancialRatio "$symbol"`"
echo "URL: \"$url\"" >&2
html="`getNormalizedHTML "$url"`"

function reportField {
    local fieldName="$1"
    local html="$2"
    local values="`getFiveYearsFiguresForField "$fieldName" "$html" 2>/dev/null`"

    echo "last 5 historical $fieldName:"
    echo "$values" | paste -s -

    echo "5-years arithmetic mean of $fieldName:"
    arithmeticMean "$values" 2>/dev/null
}

reportField 'Return on Equity (%)' "$html"
