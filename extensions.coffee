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

Buffer.prototype.pkcs7 = (padToBlockLength=20) ->
  padBytesNeeded = padToBlockLength - (@length % padToBlockLength)
  padBytes = (padBytesNeeded for i in [0...padBytesNeeded])
  return Buffer.concat [this, new Buffer(padBytes)]

Buffer.prototype.isEqual = (otherBuffer) ->
  return false unless Buffer.isBuffer(otherBuffer)
  return false unless @length is otherBuffer.length
  for i in [0...@length]
    return false if @[i] isnt otherBuffer[i]
  return true

Buffer.prototype.partition = (partitionLength, doPkcs7Pad=false, takeCount=null) ->
  theBuffer = if doPkcs7Pad then @pkcs7(partitionLength) else this
  maxPartitions = Math.ceil(theBuffer.length / partitionLength) 
  takeCount = Math.min(takeCount, maxPartitions) or maxPartitions
  
  partitions = []
  # push all but last one
  for i in [0...takeCount]
    partitions.push theBuffer.slice(i*partitionLength, (i+1)*partitionLength)

  return partitions

Buffer.randomBytes = (length=16) ->
  return new Buffer(Math.floor(255*Math.random()) for i in [0...length])