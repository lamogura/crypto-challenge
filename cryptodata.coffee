inspect = require('util').inspect
_ = require 'underscore'
StringAnalysis = require './stringanalysis'

class CryptoException
  constructor: (@message) -> @name = "MatasanoException"

class CryptoData
  constructor: (data) ->
    if data.buffer?      then @buffer = data.buffer
    else if data.hex?    then @buffer = new Buffer(data.hex, 'hex')
    else if data.base64? then @buffer = new Buffer(data.base64, 'base64')
    else if data.string? then @buffer = new Buffer(char.charCodeAt(0) for char in data.string)
    else throw new CryptoException('Unsupported or no data passed: ' + inspect(data))

  toString: (format="string") ->
    if      format.toLowerCase() is 'hex'    then return @buffer.toString('hex')
    else if format.toLowerCase() is 'base64' then return @buffer.toString('base64')
    else if format.toLowerCase() is 'string' then (String.fromCharCode(code) for code in @buffer).join('')

  singleBitXORDecode: ->
    [start, finish] = ['1'.charCodeAt(0), 'z'.charCodeAt(0)] 
    candidates = []
    for i in [start..finish]
      xorResult = @xorWith(string: String.fromCharCode(i))
      decoded = xorResult.toString('string')
      candidates.push {
        decodeKey: String.fromCharCode(i)
        decodedString: decoded
        score: (new StringAnalysis(decoded)).englishScore
      }

    bestCandidate = {score: 0}
    for candidate in candidates
      # console.log "'#{candidate.decodeKey}' -> '#{candidate.decodedString}'"
      if candidate.score > bestCandidate.score
        bestCandidate = candidate
    return bestCandidate

  xorWith: (data) -> 
    if data.hex?         then otherData = new Buffer(data.hex, 'hex')
    else if data.base64? then otherData = new Buffer(data.hex, 'base64')
    else if data.string? then otherData = (char.charCodeAt(0) for char in data.string)
    else throw new CryptoException("No data to XOR with: " + inspect(data))

    xorResult = new Buffer(@buffer[i] ^ otherData[i % otherData.length] for i in [0...@buffer.length])
    return new CryptoData(buffer: xorResult)

module.exports = CryptoData