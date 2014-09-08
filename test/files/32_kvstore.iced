

stores_klasses = require('../..').kvstore

stores = {}

exports.init = (T,cb) ->
  for klassname in [ "FlatMemory", "Memory"] 
    klass = stores_klasses[klassname]
    obj = new klass()
    stores[klassname] = obj
    await obj.init {}, defer err
    T.no_error err
  cb()

test_store = ({T,store,name},cb) ->
  tester = new Tester { T, store, name }
  await tester.test defer()
  cb()

exports.test_flat_memory = (T,cb) ->
  await test_store { T, store : stores.FlatMemory, name : "flat_memory" }, defer()
  cb()

exports.test__memory = (T,cb) ->
  await test_store { T, store : stores.Memory, name : "memory" }, defer()
  cb()