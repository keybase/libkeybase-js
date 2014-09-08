

top = require '../..'
{FlatMemory,Memory} = top.kvstore 
{E} = top.err

# Turn this on for debugging output...
# log = require 'iced-logger'
# log.package().env().set_level(0)

#========================================================

OBJS = [
  { type : "a", key : "1", value : "a1", name : "name-a1" },
  { type : "a", key : "2", value : "a1a2", name : "name-a2" },
  { type : "a", key : "3", value : "a1a2a3", name : "name-a3" },
  { type : "b", key : "1", value : "b1", name : "name-b1" },
  { type : "b", key : "2", value : "b1b2", name : "name-b2" },
  { type : "b", key : "3", value : "b1b2b3", names : [ "name-b3" ] },
]

#========================================================

class Tester

  constructor : ({@T, klass}) ->
    @obj = new klass()
    @name = klass.name

  test : (cb) ->
    await @open defer()
    await @close defer()
    await @puts defer()
    await @gets defer()
    await @lookups defer()
    await @relink defer()
    await @unlink defer()
    await @resolve defer()
    await @remove defer()
    cb null

  close : (cb) ->
    await @obj.close {}, defer err
    @T.waypoint "close"
    @T.no_error err
    cb()

  open : (cb) ->
    await @obj.open {}, defer err
    @T.waypoint "open"
    @T.no_error err
    cb()

  puts : (cb) ->
    for o in OBJS
      await @obj.put o, defer err
      @T.no_error err
    @T.waypoint "puts"
    cb()

  gets : (cb) ->
    for o,i in OBJS
      await @obj.get o, defer err, value
      @T.no_error err
      @T.equal value, o.value, "get test object #{i}"
    @T.waypoint "gets"
    cb()

  lookups : (cb) ->
    for o,i in OBJS
      o.name = o.names[0] unless o.name?
      await @obj.lookup o, defer err, value
      @T.no_error err
      @T.equal value, o.value, "lookup test object #{i}"
    @T.waypoint "lookups"
    cb()

  relink : (cb) ->
    await @obj.link { type : "a", name : "foob", key : "1" }, defer err
    @T.no_error err
    await @obj.lookup { type : "a", name : "foob" }, defer err, value
    @T.no_error err
    @T.equal value, "a1", "relink worked (1)"
    await @obj.lookup { type : "a", name : "name-a1" }, defer err, value
    @T.no_error err
    @T.equal value, "a1", "relink worked (2)"
    @T.waypoint "relink"
    cb()

  unlink : (cb) ->
    await @obj.unlink { type : "a", name : "foob" }, defer err
    @T.no_error err
    await @obj.lookup { type : "a", name : "name-a1" }, defer err, value
    @T.no_error err
    @T.equal value, "a1", "unlink left original link in place"
    await @obj.lookup { type : "a", name : "foob" }, defer err, value
    @T.assert not(value?), "no value after unlink"
    @T.assert (err? and err instanceof E.LookupNotFoundError), "right lookup error"
    @T.waypoint "unlink"
    cb()

  resolve : (cb) -> 
    await @obj.resolve { type : "a", name : "name-a3" }, defer err, key
    @T.no_error err
    @T.equal key, "3"
    @T.waypoint "resolve"
    cb()

  remove : (cb) ->
    await @obj.remove { type : "a" , key : "3" }, defer err
    @T.no_error err
    await @obj.get { type : "a", key : "3" }, defer err, value
    @T.assert not(value?), "No value should be found for a:3"
    @T.assert (err? and err instanceof E.NotFoundError), "NotFound for 'a:3'"
    await @obj.resolve { type : "a", name : "name-a3" }, defer err, key
    if @obj.can_unlink()
      @T.assert not(key?), "cannot resolve name 'name-a3'"
      @T.assert (err? and err instanceof E.LookupNotFoundError), "right lookup error"
    else
      @T.no_error err
      @T.equal key, "3", "still is there as a dangling pointer"
    @T.waypoint "remove"
    cb()

#========================================================

test_store = ({T,klass},cb) ->
  tester = new Tester { T, klass }
  await tester.test defer()
  cb()

exports.test_flat_memory = (T,cb) ->
  await test_store { T, klass : FlatMemory }, defer()
  cb()

exports.test_memory = (T,cb) ->
  await test_store { T, klass : Memory }, defer()
  cb()