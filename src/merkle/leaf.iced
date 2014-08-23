

#===========================================================

exports.Triple = class Triple 
  constructor : ({@seqno, @payload_hash, @sig_id}) ->

#--------------------------

class Parser 

  constructor : (@val) ->

  parse : () ->

    if not Array.isArray(@val) or @val.length < 2
      throw new Error "Expected an array of length 2 or more"
    else if typeof(@val[0]) isnt 'number'
      throw new Error "Need a number for first slot"
    else if typeof(@val[1]) is 'string'
      # We messed up and didn't version the initial leafs of the tree
      version = 1
    else
      version = @val[0]

    switch version
      when 1 then @parse_v1()
      when 2 then @parse_v2()
      else throw new Error "unknown leaf version: #{version}"

  parse_v1 : () ->
    pub = @parse_triple @val
    new Leaf { pub }

  parse_v2 : () -> 
    if @val.length < 2 then throw new Error "No public chain"
    pub = @parse_triple @val[1]
    semipriv = if (@val.length > 2) and @val[2]?.length then @parse_triple(@val[2]) else null
    return new Leaf { pub, semipriv }

  match_hex : (s) ->
    (typeof(s) is 'string') and !!(s.match(/^([a-fA-F0-9]*)$/)) and (s.length % 2 is 0)

  parse_triple : (val) ->
    msg = if (val.length < 2) then "Bad triple with < 2 values"
    else if val.length > 3 then "Bad triple with > 3 values"
    else if typeof(val[0]) isnt 'number' then "Bad sequence #"
    else if not @match_hex(val[1]) then "bad value[1]"
    else if val.length > 2 and val[2].length and not @match_hex(val[2]) then "bad value[2]"
    else null
    throw new Error msg if msg?
    new Triple { seqno : val[0], payload_hash : val[1], sig_id : val[2] }

#--------------------------

exports.Leaf = class Leaf

  constructor : ({@pub, @semipriv}) ->

  get_public : () -> @pub
  get_semi_private : () -> @semipriv

  @parse: (version, val) ->
    parser = new Parser version, val
    err = leaf = null
    try leaf = parser.parse()
    catch e then err = e
    [err, leaf]

#===========================================================
