const pipeTemplate = require('./pipe_script_template.js')

function parseBasicInfo($) {
    const reducer = function(accumulator, currentValue, currentIndex){
        const tds = $(currentValue).find('td')
        const key = tds.eq(0).text().replace(/[\n \s]+/g, ' ').trim()
        const value = tds.eq(1).text().trim()
        accumulator[key] = value
        return accumulator
    }
    const data = $('#cp_pBITable1 tr').toArray().reduce(reducer, {})

    console.log(JSON.stringify(data, null, 2))
}

pipeTemplate.init(parseBasicInfo)

