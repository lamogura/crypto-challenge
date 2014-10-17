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
    it "can pad a buffer", ->
      buffer = new Buffer('YELLOW SUBMARINE')
      paddedBuffer = buffer.pad(20)
      expect(paddedBuffer.length).to.be 20

  describe 'challenge#10', ->
    it "can do decrypt CDC encrypt correctly", (done) ->
      fs.readFile 'data/10.txt', 'utf8', (err, data) ->
        return log err if err
        cipher = crypto.createDecipheriv('aes-128-cbc', 'YELLOW SUBMARINE', (new Buffer(0)).pad(16))
        decodedString = cipher.update(data, 'base64', 'utf8') + cipher.final('utf8')
        expect(decodedString.match(/freaks/g).length).to.be 1
        done()

    it.only "can do CDC encrypt manually", ->
      plaintext = "egg sandwhich nope nasdf efafess"
      key = 'YELLOW SUBMARINE'
      pBuffer = new Buffer(plaintext)
      iv = (new Buffer(0)).pad(16)

      blocks = pBuffer.partition(16)
      log "original blocks"
      log blocks

      cipher = crypto.createCipheriv('aes-128-cbc', key, iv)
      cBuffer = Buffer.concat [cipher.update(pBuffer), cipher.final()]
      log "expected encrypt result, length: " + cBuffer.length
      log cBuffer.slice(30)

      encryptedBlocks = []
      cipher = crypto.createCipheriv('aes-128-ecb', key, new Buffer(0))
      for block, i in blocks
        xorResult = block.xorWith(iv)
        iv = cipher.update(xorResult)
        # iv = Buffer.concat [cipher.update(xorResult), cipher.final()]
        encryptedBlocks.push iv
      encryptedBlocks.push cipher.final()

      myEncrypt = Buffer.concat encryptedBlocks
      log "my result, length: " + cBuffer.length
      log myEncrypt.slice(30)

      # cipher = crypto.createDecipheriv('aes-128-cbc', key, (new Buffer(0)).pad(16))
      # log "them decrypting me"
      # log (Buffer.concat [cipher.update(myEncrypt), cipher.final()]).toString('utf8')