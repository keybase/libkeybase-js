
urlmod = require 'url'
{Parser} = require './assertion_parser'

#==================================================================

class Expr

  toString : () ->

  match_set : (proof_set) -> false

#==================================================================

class URI extends Expr

  #----------------------------------------

  constructor : ( {@key, @value}) ->

  #----------------------------------------

  keys : () -> [ @key ]

  #----------------------------------------

  @parse : (s) ->
    obj = urlmod.parse(s)

    if not (key = obj.protocol)? or key.length is 0
      throw new Error "Bad URL, no 'protocol' found: #{s}"
    else if key[-1...] is ':'
      key = key[0...-1]
    key = key.toLowerCase()

    if not (value = obj.hostname)? or value.length is 0
      throw new Error "Bad URL, no 'hostname' found: #{s}"
    value = value.toLowerCase()

    klasses =
      web : Web
      http : Http
      fingerprint : Fingerprint

    klass = URI unless (klass = klasses[key])?
    new klass { key, value }

  #----------------------------------------

  toString : () -> "#{@key}://#{@value}"

  #----------------------------------------

  match_set : (proof_set) ->
    proofs = proof_set.get @keys()
    for proof in proofs
      return true if @match_proof(proof)
    return false

  #----------------------------------------

  match_proof : (proof) ->
    (proof.key.toLowerCase() in @keys()) and (@value is proof.value.toLowerCase())

#==================================================================

class Web extends URI
  keys : () -> [ 'http', 'https', 'dns' ]

class Http extends URI
  keys : () -> [ 'http', 'https' ]

class Fingerprint extends URI
  match_proof : (proof) ->
    ((@key is proof.key.toLowerCase()) and (@value is proof.value[(-1 * @value.length)...].toLowerCase()))

#==================================================================

class AND extends Expr

  constructor : (args...) -> @factors = args

  toString : () -> "(" + (f.toString() for f in @factors).join(" && ") + ")"

  match_set : (proof_set) ->
    for f in @factors
      return false unless f.match_set(proof_set)
    return true

#==================================================================

class OR extends Expr

  constructor : (args...) -> @terms = args

  toString : () -> "(" + (t.toString() for t in @terms).join(" || ") + ")"

  match_set : (proof_set) ->
    for t in @terms
      return true if t.match_set(proof_set)
    return false

#==================================================================

exports.Proof = class Proof

  constructor : ({@key, @value}) ->

#-----------------

exports.ProofSet = class ProofSet

  constructor : (@proofs) ->
    @make_index()

  get : (keys) ->
    out = []
    for k in keys when (v = @_index[k])?
      out = out.concat v
    return out

  make_index : () ->
    d = {}
    for proof in @proofs
      v = d[proof.key] = [] unless (v = d[proof.key])?
      v.push proof
    @_index = d

#==================================================================

exports.parse = parse = (s) ->
  parser = new Parser
  parser.yy = { URI, OR, AND }
  return parser.parse(s)

#==================================================================
