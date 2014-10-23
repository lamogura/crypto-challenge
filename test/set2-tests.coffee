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
    describe "Buffer#pkcs7", ->
      it "can handle uneven blocked buffer", ->
        buffer = new Buffer('YELLOW SUBMARINE')
        padLength = 20
        paddedBuffer = buffer.pkcs7(padLength)
        # check length
        expect(paddedBuffer.length % padLength).to.be 0

        # check padded contents
        diff = padLength - buffer.length
        expectedBuffer = new Buffer(diff for i in [0...diff])
        expect(paddedBuffer.slice(-diff).isEqual expectedBuffer).to.be true
      
      it "can handle even blocked buffer", ->
        buffer = new Buffer('YELLOW SUBMARINE')
        padLength = 16
        paddedBuffer = buffer.pkcs7(padLength)
        # check length
        expect(paddedBuffer.length % padLength).to.be 0

        # check padded contents
        expectedBuffer = new Buffer(padLength for i in [0...padLength])
        expect(paddedBuffer.slice(-padLength).isEqual expectedBuffer).to.be true

  describe 'challenge#10', ->
    it "can do decrypt CDC encrypt correctly", (done) ->
      fs.readFile 'data/10.txt', 'utf8', (err, data) ->
        return log err if err
        iv = new Buffer(0 for i in [0...16])
        cipher = crypto.createDecipheriv('aes-128-cbc', 'YELLOW SUBMARINE', iv)
        decodedString = cipher.update(data, 'base64', 'utf8') + cipher.final('utf8')
        expect(decodedString.match(/freaks/g).length).to.be 1
        done()

    describe "buffer#partition", ->
      describe "no padding", ->
        it "can handle evenly divisible partition lengths", ->
          aBuf = new Buffer([1,2,3,4,5,6,7,8,9,10])
          buffs = aBuf.partition(5)
          expect(buffs[1].isEqual(new Buffer([6,7,8,9,10]))).to.be true

        it "can handle uneven divisible partition lengths", ->
          aBuf = new Buffer([1,2,3,4,5,6,7,8,9,10])
          buffs = aBuf.partition(4)
          expect(buffs[2].isEqual(new Buffer([9,10]))).to.be true

      describe "pkc7 padded partition", ->
        it "can handle evenly divisible partition lengths", ->
          aBuf = new Buffer([1,2,3,4,5,6,7,8,9,10])
          buffs = aBuf.partition(5, doPkcs7Pad=true)
          expect(buffs[2].isEqual(new Buffer([5,5,5,5,5]))).to.be true

        it "can handle uneven divisible partition lengths", ->
          aBuf = new Buffer([1,2,3,4,5,6,7,8,9,10])
          buffs = aBuf.partition(4, doPkcs7Pad=true)
          expect(buffs[2].isEqual(new Buffer([9,10,2,2]))).to.be true

    it "can manually do CDC encrypt", ->
      key = 'YELLOW SUBMARINE'
      iv = new Buffer(0 for i in [0...16])
      # log crypto.getCiphers()
      
      for i in [1..100]
        plaintext = ('a' for j in [0...i]).join('')
        cBuffer = CryptoTools.cbcEncrypt(plaintext, key, iv)
        cipher = crypto.createDecipheriv('aes-128-cbc', key, iv)
        openSSLDecrypt = (Buffer.concat [cipher.update(cBuffer), cipher.final()]).toString('utf8')
        expect(openSSLDecrypt).to.be plaintext