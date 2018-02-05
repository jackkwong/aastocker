const fs = require('fs')
const cheerio = require('cheerio')

function init(processHTML) {
    process.on("SIGPIPE", process.exit)

    var data = ""

    process.stdin.setEncoding('utf8');
    process.stdin.resume();

    process.stdin.on('data', function(chunk) {
        data += chunk;
    });

    process.stdin.on('end', function() {
        const $ = cheerio.load(data)
        processHTML($)
    });
}

module.exports = {
    init: init
}
