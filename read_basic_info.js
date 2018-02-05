const fs = require('fs')
const cheerio = require('cheerio')

process.on("SIGPIPE", process.exit)

var data = ""

process.stdin.setEncoding('utf8');
process.stdin.resume();

process.stdin.on('data', function(chunk) {
    data += chunk;
});

process.stdin.on('end', function() {
    parseHTML(data)
});

function parseHTML(html) {
    const $ = cheerio.load(html)

    const reducer = function(accumulator, currentValue, currentIndex){
        const tds = $(currentValue).find('td')
        const key = tds.eq(0).text().replace(/[\n \s]+/g, ' ')
        const value = tds.eq(1).text()
        accumulator[key] = value
        return accumulator
    }
    const data = $('#cp_pBITable1 tr').toArray().reduce(reducer, {})

    console.log(JSON.stringify(data, null, 2))
}

