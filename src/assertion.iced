
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

    new URI {key, value}

  toString : () -> "#{@key}://#{@value}"

#==================================================================

class AND extends Expr

  constructor : (@a, @b) ->

  toString : () -> "(#{@a.toString()} && #{@b.toString()})"

#==================================================================

class OR extends Expr

  constructor : (@a, @b) ->

  toString : () -> "(#{@a.toString()} || #{@b.toString()})"

#==================================================================

exports.parse = parse = (s) ->
  parser = new Parser
  parser.yy = { URI, OR, AND }
  console.log parser.parse(s).toString()


parse "http://foo.com && a://b && c://d || twitter://shit || reddit://bar && github://foo && http://a1 && http://b2"
