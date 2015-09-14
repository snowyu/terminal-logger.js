inherits        = require 'inherits-ex/lib/inherits'
createObject    = require 'inherits-ex/lib/createObjectWith'
getPrototypeOf  = require 'inherits-ex/lib/getPrototypeOf'
format          = require 'util-ex/lib/format'
isArray         = require 'util-ex/lib/is/type/array'
isObject        = require 'util-ex/lib/is/type/object'
isString        = require 'util-ex/lib/is/type/string'
defineProperty  = require 'util-ex/lib/defineProperty'
Table           = require 'cli-table'
colors          = require 'colors/safe'
Logger          = require 'abstract-logger'
getKeys         = Object.keys

textColor = (aColors, aText)->
  if isString aColors
    aColors = [aColors]
  if isArray aColors
    aColors.forEach (color)->
      aText = colors[color] aText
  aText

# `Logger` is a [logref](https://github.com/mikeal/logref)
# compatible logger, with an enhanced API.
#
# All logs are done against STDERR, letting you stdout for meaningfull
# value and redirection, should you need to generate output this way.
#
module.exports = class TerminalLogger
  inherits TerminalLogger, Logger

  constructor: (aName, aOptions)->
    return createObject TerminalLogger, arguments unless @ instanceof TerminalLogger
    super
    aOptions = aName if isObject aName
    if isObject aOptions
      @colors = aOptions.colors if aOptions.colors
      @statusLevels = aOptions.statusLevels if aOptions.statusLevels
    @colors ?= stColors

  # padding step
  step: '  '
  padding: ' '

  pad = (status, max) ->
    max ?= 'identical'.length
    delta = max - status.length
    (if delta then new Array(delta + 1).join(' ') + status else status)

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
  stColors =
    skip: 'magenta'
    force: 'yellow'
    create: 'green'
    invoke: 'bold'
    conflict: 'red'
    identical: 'cyan'
    ok: 'green'
    emergency: ['red', 'bold']
    alert: 'red'
    critical: 'red'
    error: 'red'
    warning: 'yellow'
    notice: 'gray'
    info: 'gray'
    debug: 'blue'
    trace: 'blue'
    '✔': 'green'
    '✗': 'red'
    name: 'blue'

  # status -> level mappings
  statusLevels: stLevels =
    skip: 'warning'
    force: 'warning'
    create: 'notice'
    invoke: 'notice'
    conflict: 'error'
    identical: 'error'
    ok: 'notice'
    '✔': 'notice'
    '✗': 'error'

  _colorProp: (aObject, aName, aDefaultValue)->
    s = aObject[aName]
    aObject[aName] = textColor(@colors[s]||@colors[aName]||aDefaultValue, s) if s?
    return

  formatter: (aContext, args...) ->
    @_colorProp(aContext, 'status')
    @_colorProp(aContext, 'level')
    aContext.name = @name if !aContext.name? and @name?
    @_colorProp(aContext, 'name', 'blue')
    super

  inLevelContext: (aContext)->
    vStatus = aContext.status
    if vStatus? and !aContext.level?
      vLevel = @statusLevels[vStatus]
      vLevel ?= vStatus
      aContext.level = vLevel if @levelStr2Id(vLevel)?
    result = super aContext
    result

  defineProperty @::, '_colors'
  defineProperty @::, '_maxStatus' # the max length status in colors
  defineProperty @::, 'status'
  defineProperty @::, 'colors', undefined,
    get: -> @_colors
    set: (value)-> @updateColors(value)

  # return the max len of status in the aColors if successful.
  getMaxLenInColors: (aColors)->
    aColors ?= @_colors
    result = 0
    getKeys(aColors).forEach (status) ->
      result = status.length if status.length > result
    result

  _clearStatus: (aColors)->
    aColors ?= @_colors
    @status = (aStatus, args...)->
      aStatus = aStatus.toLowerCase()
      vLevel = @statusLevels[aStatus]
      vLevel ?= aStatus
      vLevel = @levelStr2Id(vLevel)
      if !vLevel? or @inLevel vLevel
        vColor = aColors[aStatus] if aColors
        vStr = format.apply(null, args)
        vLN = @NEWLINE
        padding = @padding
        if vLN
          vStr = vStr.split(vLN).map (s)->
            result = if s then padding + s else s
          .join(vLN)
        vStr = @table
          chars: noBorderTable,
          style: noPaddingTable,
          colAligns:['right', 'left']
          rows: [[textColor(vColor, pad(aStatus, @_maxStatus)), vStr]]
        vStr += @NEWLINE
        @write vStr
      return this
    # End @status
    @

  updateColors: (aColors)->
    if isObject(aColors)
      @_colors = aColors
      @_maxStatus = @getMaxLenInColors(aColors)

      @_clearStatus(aColors)
      that = @
      # maybe I should deprecate these:
      # Only reserve the status() method.
      getKeys(aColors).forEach (status)->
        # Each predefined status has its logging method utility, handling
        # status color and padding before the usual `.write()`
        #
        # Example
        #
        #    log
        #      .write()
        #      .status.info('Doing something')
        #      .status.force('Forcing filepath %s, 'some path')
        #      .status.conflict('on %s' 'model.js')
        #      .write()
        #      .ok('This is ok');
        # Returns the logger
        if status isnt 'name'
          that.status[status] = (args...)->
            args.unshift status
            that.status.apply that, args
    @

  # Write a string to stderr.
  #
  # Returns the logger
  _write: (msg)->
    process.stderr.write msg
    @

  # Convenience helper to write sucess status, this simply prepends the
  # message with a green `✔`.
  tick: ->
    vText = '✔'
    vColor = @colors[vText] if @colors
    vColor ?= 'green'
    @write @padding + textColor(vColor, vText+' ') + format.apply(null, arguments) + @NEWLINE
    this

  # Convenience helper to write error status, this simply prepends the
  # message with a red `✗`.
  cross: ->
    vText = '✗'
    vColor = @colors[vText] if @colors
    vColor ?= 'red'
    @write @padding + textColor(vColor, vText+' ') + format.apply(null, arguments) + @NEWLINE
    this

  up: ->
    @padding += @step
    this

  down: ->
    @padding = @padding.replace(@step, '')
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

