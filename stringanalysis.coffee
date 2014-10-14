class StringAnalysis
  constructor: (string) ->
    @englishScore = (string.match(/[etaoinshrdlu]/g) || []).length

module.exports = StringAnalysis