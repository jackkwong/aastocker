const pipeTemplate = require('./pipe_script_template.js')

function parseDividendHistory($) {
    const mapper = function(schema) {
        return function(index, element){
            const tds = $(element).find('td')
            const result = schema.reduce(function(accumulator, key, keyIndex){
                accumulator[key] = tds.eq(keyIndex).text().trim()
                return accumulator
            }, {})

            return result
        }
    }
    const trs = $('#cp_pDHDetail tr').filter(function() {
        return $(this).find("td").length >= 8
    })
    
    const schema = trs.eq(0).find('td').map(function(){
        return $(this).text().replace(/[\n \s]+/g, ' ').trim()
    }).get()
    const data = trs.slice(1).map(mapper(schema)).get()

    console.log(JSON.stringify(data, null, 2))
}

pipeTemplate.init(parseDividendHistory)

