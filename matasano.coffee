class Matasano
  constructor: (hexString) ->
    @data = new Buffer(hexString, 'hex')

  toBase64: -> @data.toString('base64')

  toHex: -> @data.toString('hex')

  toString: -> (String.fromCharCode(code) for code in @data).join('')

  xorWith: (obj) -> 
    if obj.hex?
      otherData = new Buffer(obj.hex, 'hex')
    else if obj.string?
      otherData = (char.charCodeAt(0) for char in obj.string)
    else throw "nothing to xor with"

    @data = new Buffer(@data[i] ^ otherData[i % otherData.length] for i in [0...@data.length])

module.exports = Matasano