for i in `cat hsi.txt`
do
    ticker="`echo $i | sed 's/\..*//'`" 
    echo "##### $i #####"
    result="`./get_stock_info_from_aastock.sh "$ticker"`"
    echo "$result" | grep "@@@@ "
    echo "$result" | grep "Return on Equity" -A2
    echo "##############"
    echo
done