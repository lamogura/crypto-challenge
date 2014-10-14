expect         = require 'expect.js'
inspect        = require('util').inspect
fs             = require 'fs'
CryptoData     = require '../cryptodata'
StringAnalysis = require '../stringanalysis'

describe 'CryptoData', ->
  describe 'creating', ->
    it 'should create object from a given hex string', ->
      a = new CryptoData hex:'49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d'
      expect(a.toString('base64')).to.be 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t'

  describe 'xorWith', ->
    it 'should be able to xor with another hex string', ->
      a = new CryptoData hex: '1c0111001f010100061a024b53535009181c'
      b = a.xorWith hex: '686974207468652062756c6c277320657965'
      expect(b.toString('hex')).to.be '746865206b696420646f6e277420706c6179'

    it 'should be able to xor with a character', ->
      a = new CryptoData hex:'1c0111001f010100061a024b53535009181c'
      b = new CryptoData hex:'1c0111001f010100061a024b53535009181c'
      a2 = a.xorWith(string: 'a')
      b2 = b.xorWith(hex: '61')
      expect(a2.toString('hex')).to.be b2.toString('hex')

    it 'can solve a xor single byte encryption (challenge#3)', ->
      a = new CryptoData hex:'1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'
      result = a.singleBitXORDecode()
      expect(result.decodeKey).to.be 'X'

    it 'can find the encrypted string in challenge#4', ->
      fs.readFile 'data/s1c4.txt', 'utf8', (err, data) ->
        return console.log err if err
        decoded = []
        for line in data.split('\n')
          a = new CryptoData hex: line
          result = a.singleBitXORDecode()
          decoded.push result

        bestDecoded = {score: 0}
        for attempt in decoded
          if attempt.score > bestDecoded.score
            bestDecoded = attempt

        # console.log inspect bestDecoded
        expect(bestDecoded.decodedString).to.be "Now that the party is jumping\n"








