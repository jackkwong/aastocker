symbol=$1
source lib.sh
url="`getUrlFinancialRatio "$symbol"`"
echo "URL: \"$url\"" >&2
echo
html="`getNormalizedHTML "$url"`"

reportField 'Long Term Debt/Equity (%)' "$html"
reportField 'Total Debt/Equity (%)' "$html"
reportField 'Return on Equity (%)' "$html"
