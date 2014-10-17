inspect = require('util').inspect

class MatasanoException
  constructor: (@message) -> @name = "MatasanoException"

Buffer.prototype.xorWith = (data) -> 
  otherBuffer = data
  otherBuffer = new Buffer(data) if typeof otherBuffer is "string" 
  throw new MatasanoException("Can only xor with a string or another buffer!") unless Buffer.isBuffer(otherBuffer)
  return new Buffer(this[i] ^ otherBuffer[i % otherBuffer.length] for i in [0...@length])

Buffer.prototype.hammingDistanceWith = (otherBuffer) ->
  throw new MatasanoException("must pass buffers to do hamming!") unless Buffer.isBuffer(otherBuffer)
  throw new MatasanoException("Buffer lengths differ!") unless @length is otherBuffer.length
  xorResult = @xorWith(otherBuffer)
  binaryString = ""
  binaryString += parseInt(byte).toString(2) for byte in xorResult
  return (binaryString.match(/1/g) || []).length

Buffer.prototype.partition = (partitionLength, doPkcs7Pad=false, takeCount=null) ->
  maxFullBlocks = Math.floor(@length / partitionLength)
  take = Math.min(takeCount, maxFullBlocks) || maxFullBlocks
  partitions = []
  for i in [0...take] # take only full blocks
    partitions.push this[i*partitionLength...(i+1)*partitionLength]

  remainder = @length % partitionLength
  shouldAddLastBlock = (takeCount is null) or (takeCount > maxFullBlocks)
  if remainder > 0 and shouldAddLastBlock 
    lastBuff = @slice(@length-remainder)
    lastBuff = lastBuff.pkcs7(partitionLength) if doPkcs7Pad
    partitions.push lastBuff
  return partitions

Buffer.prototype.pkcs7 = (padToLength=20) ->
  paddingNeeded = Math.max(padToLength-@length, 0)
  paddingBytes = (paddingNeeded for i in [0...paddingNeeded])
  paddedBuffer = Buffer.concat [this, new Buffer(paddingBytes)]
  return paddedBuffer

Buffer.prototype.isEqual = (otherBuffer) ->
  return false unless Buffer.isBuffer(otherBuffer)
  return false unless @length is otherBuffer.length
  for i in [0...@length]
    return false if @[i] isnt otherBuffer[i]
  return true