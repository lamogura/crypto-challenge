inspect = require('util').inspect
_ = require 'underscore'

class StringAnalysisException
  constructor: (@message) -> @name = "StringAnalysisException"

class StringAnalysis
  constructor: (@baseString) ->
    # histogram = {}
    # for char in @baseString
    #   c = char.toLowerCase()
    #   if _.has(histogram, c)
    #     histogram[c]++
    #   else
    #     histogram[c] = 0

    # sorted = _.sortBy _.pairs(histogram), (item) -> -item[1]
    # topTen = (item[0] for item in sorted[0...8]).join('')
    # # console.log topTen
    
    # freqScore = 0
    # freqOrder = "etaoinshrdlu"
    # for i in [0...freqOrder.length]
    #   letter = freqOrder[i]
    #   idx = topTen.indexOf(letter)
    #   if idx > -1
    #     freqScore += (2 - i - idx)
    matchCount = (@baseString.match(/[etaoinshrdlu]/g) || []).length
    @englishScore = Math.ceil(matchCount / @baseString.length)

  @hammingDistance: (a, b) ->
    throw new StringAnalysisEuxception("a and b string lengths differe!") if a.length isnt b.length
    count = 0
    count++ for i in [0...a.length] when a[i] isnt b[i]
    return count

module.exports = StringAnalysis