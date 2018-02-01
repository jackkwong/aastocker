symbol=$1
source lib.sh
url="`getUrlFinancialRatio "$symbol"`"
echo "URL: \"$url\"" >&2
echo
html="`getNormalizedHTML "$url"`"

echo "#### Liquidity Analysis ####"
reportField 'Current Ratio (X)' "$html"
reportField 'Quick Ratio (X)' "$html"

echo "#### Solvency Analysis ####"
reportField 'Long Term Debt/Equity (%)' "$html"
reportField 'Total Debt/Equity (%)' "$html"
reportField 'Total Debt/Capital Employed (%)' "$html"

echo "#### Return on Investment Analysis ####"
reportField 'Return on Equity (%)' "$html"
reportField 'Return on Capital Employ (%)' "$html"
reportField 'Return on Total Assets (%)' "$html"

echo "#### Profitability Analysis ####"
reportField 'Operating Profit Margin (%)' "$html"
reportField 'Pre-tax Profit Margin (%)' "$html"
reportField 'Net Profit Margin (%)' "$html"

echo "#### Trading Analysis ####"
reportField 'Inventory Turnover (X)' "$html"

echo "#### Investment Income Analysis ####"
reportField 'Dividend Payout (%)' "$html"

echo "#### Related Statistics ####"
reportField 'Fiscal Year High' "$html"
reportField 'Fiscal Year Low' "$html"
reportField 'Fiscal Year PER Range High (X)' "$html"
reportField 'Fiscal Year PER Range Low (X)' "$html"
reportField 'Fiscal Year Yield Range High (%)' "$html"
reportField 'Fiscal Year Yield Range Low (%)' "$html"
