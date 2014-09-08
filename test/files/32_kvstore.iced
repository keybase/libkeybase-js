

{FlatMemory,Memory}= require('../..').kvstore

#========================================================

class Tester

  constructor : ({@T, klass}) ->
    @obj = new klass()
    @name = klass.name

  test : (cb) ->
    await @open defer()
    await @close defer()
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