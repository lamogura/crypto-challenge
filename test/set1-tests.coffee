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

describe 'Matasano Challenge Set#1', ->
  @timeout(0) # decrypting can take time

  describe 'challenge#1', ->
    it 'should be able to convert from a given hex string to base64 (using bytes)', ->
      theHex = '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d'
      buf = new Buffer(theHex, 'hex')
      expect(buf.toString('base64')).to.be 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t'

  describe 'challenge#2', ->
    it 'should be able to xor 2 hex strings', ->
      buffer1 = new Buffer('1c0111001f010100061a024b53535009181c', 'hex')
      buffer2 = new Buffer('686974207468652062756c6c277320657965', 'hex')
      xorResult = buffer1.xorWith(buffer2)
      expect(xorResult.toString('hex')).to.be '746865206b696420646f6e277420706c6179'

  describe 'challenge#3', ->
    it 'should be able to do repeat XOR (single byte repeating)', ->
      buffer1 = new Buffer('1c0111001f010100061a024b53535009181c', 'hex')
      xorResult = buffer1.xorWith('a')
      expect(xorResult.toString('hex')).to.be '7d6070617e606061677b632a32323168797d'

    it 'can decrypt xor single byte encryption', ->
      cBuffer = new Buffer('1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736', 'hex')
      decryptedInfo = CryptoTools.oneByteXORDecrypt(cBuffer)
      expect(decryptedInfo.key).to.be 'X'
  
  describe 'challenge#4', ->
    it 'can find the encrypted string in file of many encrypted looking strings', (done) ->
      fs.readFile 'data/s1c4.txt', 'utf8', (err, data) ->
        return console.log err if err
        decryptedLines = []
        for line in data.split('\n')
          cBuffer = new Buffer(line, 'hex')
          result = CryptoTools.oneByteXORDecrypt(cBuffer)
          decryptedLines.push result

        bestDecrypted = {score: 10000}
        for decryptedInfo in decryptedLines
          if decryptedInfo.score < bestDecrypted.score
            bestDecrypted = decryptedInfo

        # console.log inspect bestDecrypted
        expect(bestDecrypted.plaintext).to.be "Now that the party is jumping\n"
        done()

  describe 'challenge#5', ->
    it 'should be able to do repeating key XOR (multibyte)', ->
      plaintext = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
      buffer = new Buffer(plaintext)
      result = buffer.xorWith 'ICE'
      expect(result.toString('hex')).to.be "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"

  describe 'challenge#6', ->
    it 'can calculate hamming distance correctly', ->
      buffer1 = new Buffer("this is a test")
      buffer2 = new Buffer("wokka wokka!!!")
      distance = buffer1.hammingDistanceWith(buffer2)
      expect(distance).to.be 37

    it 'guesses encrypted keysize correctly', (done) ->
      fs.readFile 'data/s1c6.txt', 'utf8', (err, data) ->
        return console.log err if err
        cBuffer = new Buffer(data, 'base64')
        keysize = CryptoTools.determineEncryptedKeysize(cBuffer)
        expect(keysize).to.be 29
        done()

    it 'can break repeating key XOR', (done) ->
      fs.readFile 'data/s1c6.txt', 'utf8', (err, data) ->
        return console.log err if err
        cBuffer = new Buffer(data, 'base64')
        keysize = CryptoTools.determineEncryptedKeysize(cBuffer)

        blocks = cBuffer.partition(keysize)
        # chop off last block in case it is incomplete cause it fucks with the scoring results
        blocks = blocks[0...blocks.length-1] 

        # transpose so we have buffers that correspond to pos1 in each partiontion, pos2..etc
        transposed = (new Buffer(block) for block in _.zip.apply(_, blocks))

        key = ""
        for block in transposed
          key += CryptoTools.oneByteXORDecrypt(block).key

        expect(key).to.be "Terminator X: Bring the noise"
        done()

  describe 'challenge#7', ->
    it "can decrypt AES-ECB-128 given the key", (done) ->
      fs.readFile 'data/s1c7.txt', 'utf8', (err, data) ->
        return console.log err if err
        cipher = crypto.createDecipheriv('aes-128-ecb', 'YELLOW SUBMARINE', new Buffer(0))
        decodedString = cipher.update(data, 'base64', 'utf8') + cipher.final('utf8')
        expect(decodedString.match(/freaks/g).length).to.be 1
        done()

  describe 'challenge#8', ->
    it "can detect an AES-ECB encrypted ciphertext", (done) ->
      fs.readFile 'data/s1c8.txt', 'utf8', (err, data) ->
        return console.log err if err

        mostRepeatedHex = {count: 0}
        for line, i in data.split('\n')
          buffer = new Buffer(line, 'base64')
          blocks = buffer.partition(4)
          byteHistogram = {}
          for block in blocks
            hex = block.toString('hex')
            byteHistogram[hex] = (byteHistogram[hex] + 1) || 1

          for hex, count of byteHistogram
            if count > mostRepeatedHex.count
              mostRepeatedHex = { count: count, line: line, hex: hex, lineNumber: i+1 }
        expect(mostRepeatedHex.lineNumber).to.be 133
        done()