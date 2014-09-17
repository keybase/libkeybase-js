
urlmod = require 'url'
{Parser} = require './assertion_parser'

#==================================================================

class Expr

  toString : () ->

#==================================================================

class URI extends Expr

  constructor : ( {@key, @value}) ->

  @parse : (s) ->
    obj = urlmod.parse(s)

    if not (key = obj.protocol)? or key.length is 0
      throw new Error "Bad URL, no 'protocol' found: #{s}"
    else if key[-1...] is ':'
      key = key[0...-1]

    if not (value = obj.hostname)? or value.length is 0
      throw new Error "Bad URL, no 'hostname' found: #{s}"

    if key is 'web'
      new OR (new URI {key : k, value} for k in ['http', 'https', 'dns' ])...
    else if key is 'http'
      new OR (new URI {key : k, value} for k in ['http', 'https'])...
    else
      new URI {key, value}

  toString : () -> "#{@key}://#{@value}"

#==================================================================

class AND extends Expr

  constructor : (args...) -> @factors = args

  toString : () -> "(" + (f.toString() for f in @factors).join(" && ") + ")"

#==================================================================

class OR extends Expr

  constructor : (args...) -> @terms = args

  toString : () -> "(" + (t.toString() for t in @terms).join(" || ") + ")"

#==================================================================

exports.parse = parse = (s) ->
  parser = new Parser
  parser.yy = { URI, OR, AND }
  console.log parser.parse(s).toString()


parse "web://foo.com && http://nutflex.com && (reddit://maxtaco || twitter://maxtaco) && keybase://max && fingerprint://8EFBE2E4DD56B35273634E8F6052B2AD31A6631C"
