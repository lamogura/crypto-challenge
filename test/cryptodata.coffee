CryptoData = require '../CryptoData'
expect     = require 'expect.js'
inspect = require('util').inspect

class StringAnalysis
  constructor: (string) ->
    @englishScore = 0
    @englishScore++ for char in string when "1".charCodeAt(0) <= char.charCodeAt(0) <= "z".charCodeAt(0)
    @englishScore += (string.match(/\s/g) || []).length

describe 'CryptoData', ->
  describe 'creating', ->
    it 'should create object from a given hex string', ->
      a = new CryptoData hex:'49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d'
      expect(a.toString('base64')).to.be 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t'

  describe 'xorWith', ->
    it 'should be able to xor with another hex string', ->
      a = new CryptoData hex: '1c0111001f010100061a024b53535009181c'
      a.xorWith hex: '686974207468652062756c6c277320657965'
      expect(a.toString('hex')).to.be '746865206b696420646f6e277420706c6179'

    it 'should be able to xor with a character', ->
      a = new CryptoData hex:'1c0111001f010100061a024b53535009181c'
      b = new CryptoData hex:'1c0111001f010100061a024b53535009181c'
      a.xorWith(string: 'a')
      b.xorWith(hex: '61')
      expect(a.toString('hex')).to.be b.toString('hex')

    it.only 'can solve a xor single byte encryption (challenge#3)', ->
      candidates = []
      for i in ['1'.charCodeAt(0)..'z'.charCodeAt(0)]
        mat = new CryptoData hex:'1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'
        mat.xorWith(string: String.fromCharCode(i))
        decoded = mat.toString('string')
        candidates.push {
          decodeKey: String.fromCharCode(i)
          decodedString: decoded
          score: (new StringAnalysis(decoded)).englishScore
        }

      bestCandidate = {score: 0}
      for candidate in candidates
        if candidate.score > bestCandidate.score
          bestCandidate = candidate
      console.log "best guess is using key: " + bestCandidate.decodeKey
      console.log "best guess is: " + bestCandidate.decodedString