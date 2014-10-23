require './extensions' # load extensions
# lib
crypto  = require 'crypto'
inspect = require('util').inspect

log  = (msg) -> console.log msg
logi = (obj) -> console.log inspect obj

frequencies = { a: 8.17, b: 1.49, c: 2.78, d: 4.25, e: 12.70, f: 2.23, g: 2.02, h: 6.09, i: 6.97, j: 0.15, k: 0.77, l: 4.03, m: 2.41, n: 6.75, o: 7.51, p: 1.93, q: 0.10, r: 5.99, s: 6.33, t: 9.06, u: 2.76, v: 0.98, w: 2.36, x: 0.15, y: 1.97, z: 0.07, '\u0000': 0.0, ' ': 13.00 }

CryptoTools = 
  oneByteXORDecrypt: (cBuffer, startByte=0, finishByte=255) ->
    candidates = []
    for byte in [startByte..finishByte]
      xorResult = cBuffer.xorWith new Buffer [byte]
      plaintext = xorResult.toString('utf8')
      candidates.push {
        key: String.fromCharCode(byte)
        plaintext: plaintext
        score: @englishScore(plaintext)
      }
    bestCandidate = {score: 100000}
    for candidate in candidates
      # console.log inspect candidate if candidate.key.toLowerCase() is 'x'
      # console.log "'#{candidate.decodeKey}' -> '#{candidate.decodedString}'"
      bestCandidate = candidate if candidate.score < bestCandidate.score

    return bestCandidate

  determineEncryptedKeysize: (buffer, minKeyLength=2, maxKeyLength=40) ->
    bestResult = {distance: 100000}
    for keylength in [minKeyLength..maxKeyLength]
      sampleSize = 15
      blocks = buffer.partition(keylength, doPadLast=false, sampleSize)
      sum = 0
      firstBlock = blocks[0]
      for block in blocks[1...blocks.length]
        sum += firstBlock.hammingDistanceWith(block) / keylength / 8
      avgHammingDistance = sum / sampleSize

      # console.log "keylength: #{keylength}, distance: #{avgHammingDistance}"
      if avgHammingDistance < bestResult.distance
        bestResult = { keylength: keylength, distance: avgHammingDistance }
    return bestResult.keylength

  englishScore : (testString) ->
    countsHistogram = {}
    for char in testString
      c = char.toLowerCase()
      countsHistogram[c] = (countsHistogram[c] + 1) or 1

    normalizedHistogram = {}
    testStringLength = testString.length
    for char, count of countsHistogram
      normalizedHistogram[char] = 100 * count / testStringLength

    deltaSum = 0
    for char, freq of frequencies
      [expected, measured] = [freq, normalizedHistogram[char] or 0]
      # console.log "'#{char}': measured: #{measured}, expected: #{expected}"
      deltaSum += (expected-measured) ** 2

    return Math.sqrt(deltaSum) # rss

  cbcEncrypt: (plaintext, key, iv) ->
      # pBuffer = Buffer.concat [new Buffer(plaintext), (new Buffer(0)).pkcs7()]
      pBuffer = new Buffer(plaintext)
      blocks = pBuffer.partition(16, doPkcs7Pad=true)
      # log "original blocks"
      # log blocks

      # ok had to verify against their algorithm
      # cipher = crypto.createCipheriv('aes-128-cbc', key, iv)
      # cBuffer = Buffer.concat [cipher.update(pBuffer), cipher.final()]
      # log "expected encrypt result, length: " + cBuffer.length
      # log cBuffer

      cipher = crypto.createCipheriv('aes-128-ecb', key, new Buffer(0))
      cipher.setAutoPadding(false)

      encryptedBlocks = []
      for block in blocks
        xorResult = block.xorWith(iv)
        iv = cipher.update(xorResult)
        encryptedBlocks.push iv
      encryptedBlocks.push cipher.final()

      myEncrypt = Buffer.concat encryptedBlocks
      # log "my result, length: " + myEncrypt.length
      # log myEncrypt
      return myEncrypt

module.exports = CryptoTools
