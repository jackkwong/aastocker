symbol=$1
source lib.sh
url="`getUrlFinancialRatio "$symbol"`"
echo "URL: \"$url\"" >&2
html="`getNormalizedHTML "$url"`"

reportField 'Return on Equity (%)' "$html"
