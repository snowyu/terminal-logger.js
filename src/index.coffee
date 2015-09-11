inherits      = require 'inherits-ex/lib/inherits'
createObject  = require 'inherits-ex/lib/createObjectWith'
format        = require 'util-ex/lib/format'
isArray       = require 'util-ex/lib/is/type/array'
Table         = require 'cli-table'
colors        = require 'colors/safe'
Logger        = require 'abstract-logger'
getKeys       = Object.keys


pad = (status) ->
  max = 'identical'.length
  delta = max - status.length
  (if delta then new Array(delta + 1).join(' ') + status else status)

# `Logger` is a [logref](https://github.com/mikeal/logref)
# compatible logger, with an enhanced API.
#
# All logs are done against STDERR, letting you stdout for meaningfull
# value and redirection, should you need to generate output this way.
#
module.exports = class TerminalLogger
  inherits TerminalLogger, Logger

  constructor: ->
    return createObject TerminalLogger, arguments unless @ instanceof TerminalLogger
    super


  noBorderTable: noBorderTable =
    'top': ''
    'top-mid': ''
    'top-left': ''
    'top-right': ''
    'bottom': ''
    'bottom-mid': ''
    'bottom-left': ''
    'bottom-right': ''
    'left': ''
    'left-mid': ''
    'mid': ''
    'mid-mid': ''
    'right': ''
    'right-mid': ''
    'middle': ' '
  noPaddingTable: noPaddingTable =
    'padding-left': 0
    'padding-right': 0

  # color -> status mappings
  statusColors: stColors =
    skip: 'magenta' # warning
    force: 'yellow' # warning
    create: 'green'
    invoke: 'bold'
    conflict: 'red'   # error/warning
    identical: 'cyan' # error/warning
    error: 'red'
    ok: 'green'
    debug: 'blue'
    warning: 'yellow'
    info: 'gray'      # info

  # padding step
  step: '  '
  padding: ' '


  # Write a string to stderr.
  #
  # Returns the logger
  _write: (msg)->
    process.stderr.write msg
    @

  # Convenience helper to write sucess status, this simply prepends the
  # message with a green `✔`.
  tick: (msg) ->
    @write colors.green('✔ ') + format.apply(null, arguments) + @NEWLINE
    this

  # Convenience helper to write error status, this simply prepends the
  # message with a red `✗`.
  cross: (msg) ->
    @write colors.red('✗ ') + format.apply(null, arguments) + @NEWLINE
    this

  up: ->
    @padding += @step
    this

  down: ->
    @padding = @padding.replace(@step, '')
    this

  getKeys(stColors).forEach (status) ->

    # Each predefined status has its logging method utility, handling
    # status color and padding before the usual `.write()`
    #
    # Example
    #
    #    log
    #      .write()
    #      .info('Doing something')
    #      .force('Forcing filepath %s, 'some path')
    #      .conflict('on %s' 'model.js')
    #      .write()
    #      .ok('This is ok');
    #
    # The list of status and mapping stColors
    #
    #    skip       yellow
    #    force      yellow
    #    create     green
    #    invoke     bold
    #    conflict   red
    #    identical  cyan
    #    error      red
    #    ok         green
    #    debug      blue
    #    warning    yellow
    #    info       grey
    #
    # Returns the logger
    TerminalLogger::[status] = ->
      vColor = stColors[status]
      vStr = format.apply(null, arguments)
      vLN = @NEWLINE
      padding = @padding
      if vLN
        vStr = vStr.split(vLN).map (s)->
          result = if s then padding + s else s
        .join(vLN)
      #vTable = new Table
      vStr = @table
        chars: noBorderTable,
        style: noPaddingTable,
        colAligns:['right', 'left']
        rows: [[colors[vColor](pad status), vStr]]
      #vTable.push [colors[vColor](pad status), vStr]
      #vStr = vTable.toString()
      vStr += @NEWLINE
      @write vStr
      this

  # A basic wrapper around `cli-table` package, resetting any single
  # char to empty strings, this is used for aligning options and
  # arguments without too much Math on our side.
  #
  # - aOptions - A list of rows or an options object to pass through cli
  #              table.
  #
  # Returns the table reprensetation string.
  table: (aOptions) ->
    if isArray(aOptions)
      vRows = aOptions
      aOptions = null
    else if aOptions
      vRows = aOptions.rows
    result = new Table aOptions
    if isArray vRows
      vRows.forEach (row)->result.push row
    result.toString()

