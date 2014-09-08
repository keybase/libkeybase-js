
log = require 'iced-logger'
{E} = require './err'
{make_esc} = require 'iced-error'

##=======================================================================

exports.Base = class Base

  constructor : () ->
    @lock = new Lock

  #========================

  unimplemented : (n, cb) -> cb new E.UnimplementedError "BaseKvStore::#{n}: unimplemented"

  #========================

  # Base classes need to implement these...
  open : (cb) -> @unimplemented('open', cb)
  nuke : (cb) -> @unimplemented('nuke', cb)
  close : (cb) -> @unimplemented('close', cb)
  _put : ({key,value},cb) -> @unimplemented('_put', cb)
  _get : ({key}, cb) -> @unimplemented("_get", cb)
  _resolve : ({name}, cb) -> @unimplemented("_resolve", cb)
  _link : ({name,key}, cb) -> @unimplemented('_link', cb) 
  _unlink : ({name}, cb) -> @unimplemented('_unlink', cb)
  _unlink_all : ({key}, cb) -> @unimplemented('_unlink_all', cb)
  _remove : ({key}, cb) -> @unimplemented('_remove', cb)

  #=========================

  make_kvstore_key : ( {type, key } ) -> [ type, key ].join(":").toLowerCase()
  make_lookup_name : ( {type, name} ) -> [ type, name ].join(":").toLowerCase()

  #=========================

  link : ({type, name, key}, cb) -> @_link { name : @make_lookup_name({ type, name }), key }, cb
  unlink : ({type, name}, cb) -> @_unlink { name : @make_lookup_name({ type, name }) }, cb
  unlink_all : ({type, key}, cb) -> @_unlink_all { key : @make_kvstore_key({type, key}) }, cb
  get : ({type,key}, cb) -> @_get { key : @make_kvstore_key({type, key}) }, cb
  resolve : ({type, name}, cb) -> @_resolve { name : @make_lookup_name({type,name})}, cb

  #=========================
  
  put : ({type, key, value, name, names}, cb) ->
    esc = make_esc cb, "BaseKvStore::put"
    kvsk = @make_kvstore_key {type,key}
    log.debug "+ KvStore::put #{key}/#{kvsk}"
    await @_put { key : kvsk, value }, esc defer()
    log.debug "| hkey is #{hkey}"
    names = [ name ] if name? and not names?
    if names and names.length
      for name in names
        log.debug "| KvStore::link #{name} -> #{key}"
        await @link { type, name, key : kvsk }, esc defer()
    log.debug "- KvStore::put #{key} -> ok"
    cb null

  #-----

  remove : ({type, key, optional}, cb) ->
    k = @make_kvstore_key { type, key }
    await @lock.acquire defer()

    log.debug "+ DB remove #{key}/#{kvsk}"

    await @_remove { key : k }, defer err
    if err? and (err instanceof E.NotFoundError) and optional
      log.debug "| No object found for #{k}"
      err = null
    if not err?
      await @_unlink_all { type, key : k }, defer err

    log.debug "- DB remove #{key}/#{kvsk} -> #{if err? then 'ok' else #{err.message}}"
    @lock.release()

    cb err

  #-----

  lookup : ({type, name}, cb) ->
    esc = make_esc cb, "BaseKvStore::lookup"
    await @resolve { name, type }, esc defer key
    await @_get { key }, esc defer value
    cb null, value

##=======================================================================

exports.Flat = class Flat extends Base

  make_kvstore_key : ({type,key}) -> 
    type or= key[-2...]
    "kv:" + super { type, key }

  make_lookup_name : ({type,name}) ->
    "lo:" + super { type, name }

  _link : ({key, name}, cb) ->
    await @_put { key : name, value : key }, defer err
    cb err

  _unlink : ({name}, cb) ->
    await @_remove { key : name }, defer err
    cb err

  _unlink_all : ({key}, cb) ->
    log.debug "| Can't _unlink_all names for #{key} in Flat kvstore"
    cb null

  _resolve : ({name}, cb) ->
    await @_get { key : name }, defer err, value
    if err? and (err instanceof E.NotFoundError)
      err = new E.LookupNotFoundError "No lookup available for #{name}"

##=======================================================================

# A memory-backed store, mainly for testing...
exports.Memory = class Memory extends Base

##=======================================================================
