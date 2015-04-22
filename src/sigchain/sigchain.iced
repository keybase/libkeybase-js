

## 
## Sigchain
## 
##   The main class to access the Keybase sigchain.
##
exports.Sigchain = class Sigchain

  #-----------------

  constructor : ({uid, merkle_triple, storage, api}) ->
    @_uid = uid
    @_merkle_triple = merkle_triple
    @_storage = storage
    @_api = api

  #-----------------

  save : ({}, cb) ->
    cb null

  #-----------------

  @load : ({uid, merkle_triple, storage, api}, cb) ->
    ch = new Sigchain { uid, merkle_triple, storage, api }
    await ch._load {}, defer err
    cb err, ch

  #-----------------

  _load : ({}, cb) ->
    cb null

##-------------------------------------------------------------
