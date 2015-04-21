
C = require '../constants'

#===========================================================

exports.ChainTail = class ChainTail
  constructor : ({@seqno, @payload_hash, @sig_id, @eldest_kid }) ->
  to_json : () -> 
    ret = [ @seqno, @payload_hash, @sig_id ]
    ret.push @eldest_kid if @eldest_kid?
    return ret

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
      when C.versions.leaf.v1 then @parse_v1()
      when C.versions.leaf.v2 then @parse_v2()
      else throw new Error "unknown leaf version: #{version}"

  parse_v1 : () ->
    pub = @parse_chain_tail @val
    new Leaf { pub }

  parse_v2 : () ->
    if @val.length < 2 then throw new Error "No public chain"
    pub = @parse_chain_tail @val[1]
    semipriv = if (@val.length > 2) and @val[2]?.length then @parse_chain_tail(@val[2]) else null
    return new Leaf { pub, semipriv }

  match_hex : (s) ->
    (typeof(s) is 'string') and !!(s.match(/^([a-fA-F0-9]*)$/)) and (s.length % 2 is 0)

  parse_chain_tail : (val) ->
    msg = null
    if (val.length < 2) then msg = "Bad chain tail with < 2 values"
    else if typeof(val[0]) isnt 'number' then msg = "Bad sequence #"
    else 
      for v,i in val[1...] when v? and v.length
        unless @match_hex v 
          msg = "bad value[#{i}]"
          break
    throw new Error msg if msg?
    new ChainTail { seqno : val[0], payload_hash : val[1], sig_id : val[2], eldest_kid : val[3] }

#--------------------------

exports.Leaf = class Leaf

  constructor : ({@pub, @semipriv}) ->

  get_public : () -> @pub
  get_semiprivate: () -> @semipriv

  to_json : () ->
    # Save some space by not including semipriv if it's empty...
    ret = [ C.versions.leaf.v2, (if @pub then @pub.to_json() else []) ]
    if @semipriv? then ret.push @semipriv.to_json()
    return ret

  to_string : () -> JSON.stringify(@to_json())

  @parse: ( val) ->
    parser = new Parser val
    err = leaf = null
    try leaf = parser.parse()
    catch e then err = e
    [err, leaf]

  seqno_assertion : () -> (rows) =>
    found = {}

    # Make sure that every sequence found in the DB is also in the LOL
    for {seqno_type, seqno} in rows
      chain_tail = switch seqno_type
        when C.seqno_types.PUBLIC then @pub
        when C.seqno_types.SEMIPRIVATE then @semipriv
        else null
      if not chain_tail? or (chain_tail.seqno isnt seqno) then return false
      found[seqno_type] = true

    # Make sure that every sequence found in the LOL is also in the DB.
    if @semipriv?.seqno and (not found[C.seqno_types.SEMIPRIVATE]) then return false
    if @pub?.seqno and (not found[C.seqno_types.PUBLIC]) then return false

    return true

#===========================================================
