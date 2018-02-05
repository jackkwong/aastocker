const pipeTemplate = require('./pipe_script_template.js')

function parseFinancialRatio($) {
    const reducer = function(accumulator, currentValue, currentIndex){
        const tds = $(currentValue).find('td')
        const key = tds.eq(0).text().replace(/[\n \s]+/g, ' ').trim()
        const value = [1,2,3,4,5].map(function(i){ return tds.eq(i).text().trim() })
        accumulator[key] = value
        return accumulator
    }
    const data = $('#cp_repPLData_Panel5_0').parent('.grid_11').find('tr').filter(function(){
        return $(this).find("td").length >= 6
    }).toArray().reduce(reducer, {})

    console.log(JSON.stringify(data, null, 2))
}

pipeTemplate.init(parseFinancialRatio)

