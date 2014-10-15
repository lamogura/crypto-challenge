inspect        = require('util').inspect
_              = require 'underscore'

StringAnalysis = require './stringanalysis'
CryptoUtils    = require './cryptoutils'

class CryptoData
  constructor: (data) -> @buffer = CryptoUtils.bufferFromData(data)

  findKeysize: (min=2, max=40) ->
    bestResult = {distance: 100000}
    for keysize in [min..max]
      take = 15
      blocks = CryptoUtils.partitionBuffer(@buffer, keysize, take)
      sum = 0
      for block in blocks[1...blocks.length]
        sum += CryptoUtils.hammingDistance(blocks[0], block) / keysize / 8
      distance = sum / take
      # console.log "keysize: #{keysize}, distance: #{distance}"
      if distance < bestResult.distance
        bestResult = { keysize: keysize, distance: distance }
    return bestResult.keysize

  toString: (format="string") ->
    if      format.toLowerCase() is 'hex'    then return @buffer.toString('hex')
    else if format.toLowerCase() is 'base64' then return @buffer.toString('base64')
    else if format.toLowerCase() is 'string' then (String.fromCharCode(code) for code in @buffer).join('')

  singleBitXORDecode: (start=0, finish=250) ->
    candidates = []
    for i in [start..finish]
      xorResult = @xorWith(string: String.fromCharCode(i))
      decoded = xorResult.toString('string')
      candidates.push {
        decodeKey: String.fromCharCode(i)
        decodedString: decoded
        score: (new StringAnalysis(decoded)).englishDeviationScore
      }

    bestCandidate = {score: 100000}
    for candidate in candidates
      # console.log inspect candidate if candidate.decodeKey.toLowerCase() is 'm'
      # console.log "'#{candidate.decodeKey}' -> '#{candidate.decodedString}'"
      bestCandidate = candidate if candidate.score < bestCandidate.score

    return bestCandidate

  xorWith: (data) -> 
    otherBuffer = CryptoUtils.bufferFromData(data)
    xorResult = new Buffer(@buffer[i] ^ otherBuffer[i % otherBuffer.length] for i in [0...@buffer.length])
    return new CryptoData(buffer: xorResult)

module.exports = CryptoData