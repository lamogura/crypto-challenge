require '../extensions' # load extensions
# lib
expect         = require 'expect.js'
inspect        = require('util').inspect
crypto         = require 'crypto'
fs             = require 'fs'
_              = require 'underscore'

# local
CryptoTools    = require '../cryptotools'

log  = (msg) -> console.log msg
logi = (obj) -> console.log inspect obj

describe 'Matasano Challenge Set#2', ->
  @timeout(0) # decrypting can take time

  describe 'challenge#9', ->
    it "can pad a buffer with pkcs#7", ->
      buffer = new Buffer('YELLOW SUBMARINE')
      paddedLength = 20
      length = buffer.length
      paddedBuffer = buffer.pkcs7(paddedLength)
      # check length
      expect(paddedBuffer.length).to.be paddedLength

      # check padded contents
      diff = paddedLength - length
      expectedBuffer = new Buffer(diff for i in [0...diff])
      expect(paddedBuffer.slice(length).isEqual expectedBuffer).to.be true

  describe 'challenge#10', ->
    it "can do decrypt CDC encrypt correctly", (done) ->
      fs.readFile 'data/10.txt', 'utf8', (err, data) ->
        return log err if err
        iv = new Buffer(0 for i in [0...16])
        cipher = crypto.createDecipheriv('aes-128-cbc', 'YELLOW SUBMARINE', iv)
        decodedString = cipher.update(data, 'base64', 'utf8') + cipher.final('utf8')
        expect(decodedString.match(/freaks/g).length).to.be 1
        done()

    it.only "can do CDC encrypt manually", ->
      plaintext = "egg sandwhich nopan even longer onee thdis is as realddly dsdflong, why does it work, this is really strnage"
      key = 'YELLOW SUBMARINE'
      pBuffer = new Buffer(plaintext)
      iv = new Buffer(0 for i in [0...16])

      blocks = pBuffer.partition(16, doPkcs7Pad=true)
      log "original blocks"
      log blocks

      cipher = crypto.createCipheriv('aes-128-cbc', key, iv)
      cBuffer = Buffer.concat [cipher.update(pBuffer), cipher.final()]
      log "expected encrypt result, length: " + cBuffer.length
      log cBuffer.slice(40)

      encryptedBlocks = []
      cipher = crypto.createCipheriv('aes-128-ecb', key, new Buffer(0))
      for block, i in blocks
        xorResult = block.xorWith(iv)
        iv = cipher.update(xorResult)
        # iv = Buffer.concat [cipher.update(xorResult), cipher.final()]
        encryptedBlocks.push iv
      # encryptedBlocks.push cipher.final()

      myEncrypt = Buffer.concat encryptedBlocks
      log "my result, length: " + cBuffer.length
      log myEncrypt.slice(40)

      cipher = crypto.createDecipheriv('aes-128-cbc', key, (new Buffer(0)).pad(16))
      theirDecrypt = (Buffer.concat [cipher.update(myEncrypt), cipher.final()]).toString('utf8')
      log "them decrypting me"
      log theirDecrypt
      expect(theirDecrypt).to.be plaintext