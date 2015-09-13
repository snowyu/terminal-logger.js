ConsoleLogger     = require('./lib')
SingleLineLogger  = require('./lib/single-line')
defineProperty    = require('util-ex/lib/defineProperty')
setPrototypeOf    = require('inherits-ex/lib/setPrototypeOf')

module.exports = function (name, aOptions){
  var result = ConsoleLogger(name, aOptions)
  var single = result.single = {}
  setPrototypeOf(single, result)
  single.NEWLINE = ''
  single._write = SingleLineLogger.prototype._write
  // update this reference of the status.xxx methods.
  single.updateColors(single._colors)
  // defineProperty(result, 'single', undefined, {
  //   get: function() {
  //      return SingleLineLogger(this) //I do not like this.
  //   }
  // })
  return result
}