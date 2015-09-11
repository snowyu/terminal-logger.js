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
    beforeEach -> TerminalLogger::_write.reset()

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

    getKeys(TerminalLogger::statusColors).forEach (status)->
      describe '#'+status, ->
        it 'should write msg with status', ->
          log[status] 'hiMsg'
          expect(writeFn).to.be.calledOnce
          expect(writeFn.firstCall.args[0]).to.be.include 'hiMsg'
          expect(writeFn.firstCall.args[0]).to.be.include status

test()