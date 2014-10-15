_              = require 'underscore'
StringAnalysis = require './stringanalysis'
CryptoUtils    = require './cryptoutils'
inspect        = require('util').inspect

class CryptoData
  constructor: (data) -> @buffer = CryptoUtils.bufferFromData(data)

  findKeysize: (min=2, max=40) ->
    bestResult = {distance: 100000}
    for keysize in [min..max]
      [block1, block2, block3, block4] = CryptoUtils.partitionBuffer(@buffer, keysize, 4)
      distance1 = CryptoUtils.hammingDistance(block1, block2) / keysize
      distance2 = CryptoUtils.hammingDistance(block1, block3) / keysize
      distance3 = CryptoUtils.hammingDistance(block1, block4) / keysize
      distance = (distance1 + distance2 + distance3) / 3
      if distance < bestResult.distance
        bestResult = { keysize: keysize, distance: distance }
    return bestResult.keysize

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
        score: (new StringAnalysis(decoded)).englishDeviationScore
      }

    bestCandidate = {score: 100000}
    for candidate in candidates
      # console.log "'#{candidate.decodeKey}' -> '#{candidate.decodedString}'"
      bestCandidate = candidate if candidate.score < bestCandidate.score

    return bestCandidate

  xorWith: (data) -> 
    otherBuffer = CryptoUtils.bufferFromData(data)
    xorResult = new Buffer(@buffer[i] ^ otherBuffer[i % otherBuffer.length] for i in [0...@buffer.length])
    return new CryptoData(buffer: xorResult)

module.exports = CryptoData