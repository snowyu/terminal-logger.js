chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

setImmediate    = setImmediate || process.nextTick

#TerminalLogger  = require '../src'
getKeys         = Object.keys

module.exports = test = (TerminalLogger)->
  TerminalLogger ?= require '../src'
  old_writeFn = TerminalLogger::_write
  TerminalLogger::_write = writeFn = sinon.spy (msg)->old_writeFn.apply @, arguments

  describe TerminalLogger.name, ->
    log = TerminalLogger('test')
    beforeEach ->
      writeFn.reset()
      log.level = 'ERROR'

    it 'should customize the colors and statusLevels', ->
      expectedColors = {}
      expectedStatusLevels = {}
      result = TerminalLogger
        name: 'test'
        colors: expectedColors
        statusLevels: expectedStatusLevels
      expect(result).to.be.instanceof TerminalLogger
      expect(result.colors).to.be.equal expectedColors
      expect(result.statusLevels).to.be.equal expectedStatusLevels
      expect(result.name).to.be.equal 'test'

    describe '#tick', ->
      it 'should tick a msg', ->
        log.tick 'hiMsg'
        expect(writeFn).to.be.calledOnce
        expect(writeFn.firstCall.args[0]).to.be.include 'hiMsg'
        expect(writeFn.firstCall.args[0]).to.be.include '✔'

    describe '#cross', ->
      it 'should tick a msg', ->
        log.cross 'hiMsg'
        expect(writeFn).to.be.calledOnce
        expect(writeFn.firstCall.args[0]).to.be.include 'hiMsg'
        expect(writeFn.firstCall.args[0]).to.be.include '✗'

    describe '#table', ->
      it 'should make a table string', ->
        result = log.table [['hiMsg'],[2]]
        expect(result).to.be.include 'hiMsg'
        expect(result).to.be.include '2'

    describe '#up/down', ->
      it 'should increment padding', ->
        expected = log.padding.length + log.step.length
        log.up()
        expect(log.padding).to.have.length expected
        log.down()
        expected -= log.step.length
        expect(log.padding).to.have.length expected

    describe '#status', ->
      it 'should write msg', ->
        log.level = 'trace'
        getKeys(log.colors).forEach (status, i)->
          if status != 'name'
            writeFn.reset()
            log.status status, 'hiMsg'
            expect(writeFn).to.have.callCount 1
            expect(writeFn.firstCall.args[0]).to.be.include 'hiMsg'
            expect(writeFn.firstCall.args[0]).to.be.include status
      it 'should mute msg with status', ->
        log.level = 'silent'
        getKeys(log.colors).forEach (status, i)->
          if status != 'name'
            writeFn.reset()
            log.status status, 'hiMsg'
            expect(writeFn).to.have.callCount 0

      getKeys(log.colors).forEach (status, i)->
        if status != 'name'
          describe '#status.'+status, ->
            it 'should write msg with '+status, ->
              log.level = 'trace'
              log.status[status] 'hiMsg'
              expect(writeFn).to.have.callCount 1
              expect(writeFn.firstCall.args[0]).to.be.include 'hiMsg'
              expect(writeFn.firstCall.args[0]).to.be.include status

    describe '#log', ->
      it 'should log with level', ->
        log.log 'hiMsg',
          status: 'create'
        expect(writeFn).to.have.callCount 0
        log.level = 'INFO'
        log.log '${status}: hiMsg',
          status: 'create'
        expect(writeFn).to.have.callCount 2
        expect(writeFn.firstCall.args[0]).to.be.include 'hiMsg'
        expect(writeFn.firstCall.args[0]).to.be.include 'create'

test()