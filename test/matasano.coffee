Matasano = require '../matasano'
expect   = require 'expect.js'

describe 'Matasano', ->
  describe 'creating', ->
    it 'should create object from a given hex string', ->
      mat = new Matasano('49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d')
      b64 = mat.toBase64()
      expect(b64).to.be 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t'

  describe 'xorWith', ->
    it 'should be able to xor with another hex string', ->
      mat = new Matasano('1c0111001f010100061a024b53535009181c')
      mat.xorWith(hex: '686974207468652062756c6c277320657965')
      expect(mat.toHex()).to.be '746865206b696420646f6e277420706c6179'

    it 'should be able to xor with a character', ->
      mat1 = new Matasano('1c0111001f010100061a024b53535009181c')
      mat2 = new Matasano('1c0111001f010100061a024b53535009181c')
      mat1.xorWith(string: 'a')
      mat2.xorWith(hex: '61')
      expect(mat1.toHex()).to.be mat2.toHex()

    it 'can solve a xor single byte encryption (challenge#3)', ->
      candidates = {}
      for i in ['1'.charCodeAt(0)..'z'.charCodeAt(0)]
        mat = new Matasano('1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736')
        mat.xorWith(string: String.fromCharCode(i))
        candidates[String.fromCharCode(i)] = mat.toString()

      maxSpaces = 0
      bestGuessKey = ''
      for key, value of candidates
        count = (value.match(/\s/g) || []).length
        if count > maxSpaces
          maxSpaces = count
          bestGuessKey = key
      console.log "best guess is using key: " + bestGuessKey
      mat = new Matasano('1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736')
      mat.xorWith(string: bestGuessKey)
      console.log mat.toString()


        
