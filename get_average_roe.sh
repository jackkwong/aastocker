symbol=$1
source lib.sh
url="`getUrlFinancialRatio "$symbol"`"
echo "URL: \"$url\"" >&2
html="`getNormalizedHTML "$url"`"
values="`getFiveYearsFiguresForField 'Return on Equity (%)' "$html"`"

echo "last 5 historical ROE:"
echo "$values" | paste -s -

echo "5-years arithmetic mean of ROE:"
arithmeticMean "$values"
