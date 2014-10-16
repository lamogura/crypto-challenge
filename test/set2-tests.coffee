require '../extensions' # load extensions
# lib
expect         = require 'expect.js'
inspect        = require('util').inspect
crypto         = require 'crypto'
fs             = require 'fs'
_              = require 'underscore'

# local
CryptoTools    = require '../cryptotools'

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
        return console.log err if err
        cipher = crypto.createDecipheriv('aes-128-cbc', 'YELLOW SUBMARINE', (new Buffer(0)).pad(16))
        decodedString = cipher.update(data, 'base64', 'utf8') + cipher.final('utf8')
        expect(decodedString.match(/freaks/g).length).to.be 1
        done()

    it.skip "can do CDC encrypt manually", ->
      plaintext = "something only i can do but that isnt really true,no really really anyone can do it now"

      iv = CryptoTools.padBuffer(new Buffer(0), 16)
      b = new CryptoData string: plaintext

      blocks = CryptoTools.partitionBuffer(b.buffer, 16, true)

      encryptedBlocks = []
      for block, i in blocks
        cipher = crypto.createCipheriv('aes-128-ecb', 'YELLOW SUBMARINE', new Buffer(0))
        c = new CryptoData buffer: block
        xorBuff = c.xorWith(buffer: iv).buffer
        console.log i
        eblock = Buffer.concat [cipher.update(xorBuff), cipher.final()]
        encryptedBlocks.push eblock
        iv = eblock

      console.log encryptedBlocks[0..2]

      # console.log CryptoTools.partitionBuffer(b, 16)