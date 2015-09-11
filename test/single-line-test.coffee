chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

setImmediate    = setImmediate || process.nextTick

SingleLineLogger  = require '../src/single-line'
TerminalLogger    = require '../src'

test = require './index-test'

test(SingleLineLogger)

describe 'SingleLineLogger', ->
  beforeEach ->
    SingleLineLogger::_write.reset()
    TerminalLogger::_write.reset()

  describe 'constructor', ->
    it 'should create an instance via object', ->
      result = SingleLineLogger
        name: 'test'
      expect(result).to.have.property 'name', 'test'
      result.dontSupport = true
      result.write 'log'
      expect(SingleLineLogger::_write).to.be.calledOnce
      expect(TerminalLogger::_write).to.be.calledOnce
      expect(TerminalLogger::_write.firstCall.args[0]).to.be.include 'log'
  it 'should be no NEWLINE', ->
    expect(SingleLineLogger::NEWLINE).to.be.equal ''

