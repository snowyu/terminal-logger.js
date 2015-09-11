inherits      = require 'inherits-ex/lib/inherits'
createObject  = require 'inherits-ex/lib/createObjectWith'
isObject      = require 'util-ex/lib/is/type/object'
TerminalLogger= require './'

# Single-line Logger Class
# Single line update on console
#
# eg,
# var log = 'isdk-logger/console'
# var dot = '.'
# singleLineLog()
# function singleLineLog()
# {
#     dot = dot.replace('.', '..')
#     log.single.info("update:", dot)
#     setTimeout(singleLineLog, 500)
# }
module.exports = class SingleLineLogger
  inherits SingleLineLogger, TerminalLogger

  NEWLINE: ''

  constructor: (aName, aOptions)->
    return createObject SingleLineLogger, arguments unless @ instanceof SingleLineLogger
    # if isObject aName
    #   aOptions  = aName
    #   aName = aOptions.name
    super
    aOptions  = aName if isObject aName
    ignoreSingleLine = aOptions.ignoreSingleLine if aOptions
    vMissing = @valid()
    if vMissing.length
      @dontSupport = true
      throw new Error 'missing methods:'+vMissing.join(',') unless ignoreSingleLine

  valid: ->
    vMethods = ['clearLine', 'cursorTo']
    vMethods = vMethods.filter (m)->not(m of process.stderr)

  _write: (msg, aPos) ->
    if !@dontSupport
      aPos ?= 0
      process.stderr.clearLine()
      process.stderr.cursorTo(aPos)
      process.stderr.write(msg)
    else
      super(msg)
    @