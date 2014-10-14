inspect = require('util').inspect

class CryptoException
  constructor: (@message) -> @name = "MatasanoException"

class CryptoData
  constructor: (data) ->
    if data.hex?         then @buffer = new Buffer(data.hex, 'hex')
    else if data.base64? then @buffer = new Buffer(data.base64, 'base64')
    else if data.string? then @buffer = new Buffer(char.charCodeAt(0) for char in data.string)
    else throw new CryptoException('Unsupported or no data passed: ' + inspect(data))

  toString: (format="string") ->
    if      format.toLowerCase() is 'hex'    then return @buffer.toString('hex')
    else if format.toLowerCase() is 'base64' then return @buffer.toString('base64')
    else if format.toLowerCase() is 'string' then (String.fromCharCode(code) for code in @buffer).join('')

  xorWith: (data) -> 
    if data.hex?         then otherData = new Buffer(data.hex, 'hex')
    else if data.base64? then otherData = new Buffer(data.hex, 'base64')
    else if data.string? then otherData = (char.charCodeAt(0) for char in data.string)
    else throw new CryptoException("No data to XOR with: " + inspect(data))

    @buffer = new Buffer(@buffer[i] ^ otherData[i % otherData.length] for i in [0...@buffer.length])

module.exports = CryptoData