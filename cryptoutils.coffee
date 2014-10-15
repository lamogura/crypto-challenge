inspect = require('util').inspect

class CryptoException
  constructor: (@message) -> @name = "CryptoException"

module.exports = 
  CryptoException: CryptoException

  padBuffer: (buffer, blockLength=20, padWith='\x00') ->
    if buffer.length >= blockLength then throw new CryptoException("Buffer is already >= block length of #{blockLength}")
    while buffer.length < blockLength
      buffer = Buffer.concat([buffer, new Buffer(padWith)]) 
    return buffer

  partitionBuffer: (buffer, paritionSize, doPad=false, take=null) ->
    partitions = []
    maxPartitionCount = Math.floor(buffer.length / paritionSize)
    takeCount = if take? then Math.min(take, maxPartitionCount) else maxPartitionCount
    
    for i in [0...takeCount]
      partitions.push buffer[i*paritionSize...(i+1)*paritionSize]

    remainder = buffer.length % paritionSize
    if not take? and remainder isnt 0
      lastBuff = buffer.slice(buffer.length-remainder)
      lastBuff = @padBuffer(lastBuff, paritionSize) if doPad
      partitions.push lastBuff

    return partitions

  hammingDistance: (buffer1, buffer2) ->
    # throw new CryptoException("must pass buffers to do hamming!") if !Buffer.isBuffer(buffer1) or !Buffer.isBuffer(buffer2)
    throw new CryptoException("a and b data lengths differ!") if buffer1.length isnt buffer2.length
    count = 0
    for i in [0...buffer1.length]
      binaryXOR = buffer1[i] ^ buffer2[i]
      count += (binaryXOR.toString(2).match(/1/g) || []).length
    return count

  bufferFromData: (data) ->
    if      data.hex?    then return new Buffer(data.hex, 'hex')
    else if data.buffer? then return data.buffer
    else if data.base64? then return new Buffer(data.base64, 'base64')
    else if data.string? then return new Buffer(char.charCodeAt(0) for char in data.string)
    else throw new CryptoException('Unsupported or no data passed: ' + inspect(data))

  buffersAreEqual: (a, b) ->
    return false if a.length isnt b.length
    for i in [0...a.length]
      return false if a[i] isnt b[i]
    return true
