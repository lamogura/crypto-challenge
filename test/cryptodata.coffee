expect         = require 'expect.js'
inspect        = require('util').inspect
crypto         = require 'crypto'
fs             = require 'fs'
_              = require 'underscore'

CryptoData     = require '../cryptodata'
CryptoUtils    = require '../cryptoutils'
StringAnalysis = require '../stringanalysis'

describe 'CryptoData', ->
  @timeout(0) # decrypting can take time

  describe 'creating', ->
    it 'should create object from a given hex string (challenge#1)', ->
      a = new CryptoData hex:'49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d'
      expect(a.toString('base64')).to.be 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t'

  describe 'xorWith', ->
    it 'should be able to xor with another hex string (challenge#2)', ->
      a = new CryptoData hex: '1c0111001f010100061a024b53535009181c'
      b = a.xorWith hex: '686974207468652062756c6c277320657965'
      expect(b.toString('hex')).to.be '746865206b696420646f6e277420706c6179'

    it 'should be able to xor with a character (challenge#3)', ->
      a = new CryptoData hex:'1c0111001f010100061a024b53535009181c'
      b = new CryptoData hex:'1c0111001f010100061a024b53535009181c'
      a2 = a.xorWith(string: 'a')
      b2 = b.xorWith(hex: '61')
      expect(a2.toString('hex')).to.be b2.toString('hex')

    it 'should be able to do repeating key XOR (challenge#5)', ->
      unencrypted = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
      a = new CryptoData string:unencrypted
      result = a.xorWith string:'ICE'
      expect(result.toString('hex')).to.be "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"

  describe 'challenge#3', ->
    it 'can solve a xor single byte encryption', ->
      a = new CryptoData hex:'1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'
      result = a.singleBitXORDecode()
      expect(result.decodeKey).to.be 'X'

  describe 'challenge#4', ->
    it 'can find the encrypted string in file of many encrypted looking strings', (done) ->
      fs.readFile 'data/s1c4.txt', 'utf8', (err, data) ->
        return console.log err if err
        decoded = []
        for line in data.split('\r\n')
          a = new CryptoData hex: line
          # console.log line
          result = a.singleBitXORDecode()
          decoded.push result

        bestDecoded = {score: 10000}
        for attempt in decoded
          if attempt.score < bestDecoded.score
            bestDecoded = attempt

        # console.log inspect bestDecoded
        expect(bestDecoded.decodedString).to.be "Now that the party is jumping\n"
        done()

  describe 'challenge#6', ->
    it 'can calculate hamming distance correctly', ->
      a = new CryptoData string: "this is a test"
      b = new CryptoData string: "wokka wokka!!!"
      distance = CryptoUtils.hammingDistance(a.buffer, b.buffer)
      expect(distance).to.be 37

    it 'guesses keysize correctly', (done) ->
      fs.readFile 'data/s1c6.txt', 'utf8', (err, data) ->
        return console.log err if err
        a = new CryptoData base64: data
        keysize = a.findKeysize()
        expect(keysize).to.be 29
        done()

    it 'can break repeating key XOR', (done) ->
      fs.readFile 'data/s1c6.txt', 'utf8', (err, data) ->
        return console.log err if err
        a = new CryptoData base64: data
        keysize = a.findKeysize()
        # console.log "keysize: #{keysize}"

        blocks = CryptoUtils.partitionBuffer(a.buffer, keysize)
        transposed = (new Buffer(block) for block in _.zip.apply(_, blocks))

        key = ""
        for block in transposed
          b = new CryptoData buffer: block
          result = b.singleBitXORDecode()
          # console.log inspect result
          key += result.decodeKey

        expect(key).to.be "Terminator X: Bring the noise"
        # decoded = a.xorWith string: key
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

        bestResult = {count: 0}
        for line, i in data.split('\n')
          blocks = CryptoUtils.partitionBuffer(new Buffer(line, 'base64'), 4)
          counts = {}
          for b in blocks
            hex = b.toString('hex')
            counts[hex] = (counts[hex] + 1) || 1

          for key, count of counts
            if count > bestResult.count
              bestResult = { count: count, line: line, hex: key, lineNumber: i+1 }
        expect(bestResult.lineNumber).to.be 133
        done()