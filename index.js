ConsoleLogger     = require('./lib')
SingleLineLogger  =  require('./lib/single-line')

module.exports = function (name, aOptions){
  var result = ConsoleLogger(name, aOptions)
  result.single = SingleLineLogger(name, aOptions)
  return result
}