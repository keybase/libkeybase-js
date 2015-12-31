{bufeq_fast} = require('pgp-utils').util

#=========================

class Finder

  constructor : (corpus) ->
    @rxx = new RegExp '\\s*(([a-zA-Z0-9/+_-]+)(={0,3}))\\s*$'
    @lines = corpus.split /\r*\n/

  find_one_block : (start) ->
    found = false
    ln_out = start
    parts = []
    for line,i in @lines[start...]
      ln_out++
      if (m = line.match @rxx)?
        found = true
        parts.push m[1]
        if m[3].length > 0
          ln_out++
          break
      else if found
        break
    [(parts.join ""), ln_out]

  find : (needle) ->
    i = 0
    while i < @lines.length
      [msg, i] = @find_one_block i
      if msg.length
        try
          buf = new Buffer msg, 'base64'
          return true if bufeq_fast buf, needle
        catch e
          # noop
    return false

#============================

exports.b64find = (haystack, needle) -> (new Finder haystack).find needle

