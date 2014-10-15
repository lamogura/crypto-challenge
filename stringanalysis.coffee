inspect = require('util').inspect
_       = require 'underscore'

class StringAnalysisException
  constructor: (@message) -> @name = "StringAnalysisException"

class StringAnalysis
  frequencies: { ' ': 13.00, a: 8.17, b: 1.49, c: 2.78, d: 4.25, e: 12.70, f: 2.23, g: 2.02, h: 6.09, i: 6.97, j: 0.15, k: 0.77, l: 4.03, m: 2.41, n: 6.75, o: 7.51, p: 1.93, q: 0.10, r: 5.99, s: 6.33, t: 9.06, u: 2.76, v: 0.98, w: 2.36, x: 0.15, y: 1.97, z: 0.07
  }

  constructor: (@baseString) ->
    countsHistogram = {}
    for char in @baseString
      c = char.toLowerCase()
      countsHistogram[c] = (countsHistogram[c] + 1) || 1

    normalizedHistogram = {}
    length = @baseString.length
    for char, count of countsHistogram
      normalizedHistogram[char] = 100 * count / length

    deltaSum = 0
    for char in " etaoinshrdlu"
      [expected, measured] = [@frequencies[char] || 0, normalizedHistogram[char] || 0]
      # console.log "'#{char}': measured: #{measured}, expected: #{expected}"
      deltaSum += Math.pow(expected-measured, 2)

    @englishDeviationScore = Math.sqrt(deltaSum) # rss

module.exports = StringAnalysis