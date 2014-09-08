
log = require 'iced-logger'
{E} = require './err'
{make_esc} = require 'iced-error'

##=======================================================================

class BaseKvStore

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

    log.debug "+ DB remove #{key}/#{kvsk}"

    await @_remove { key : k }, defer err
    if err? and (err instanceof E.NotFoundError) and optional
      log.debug "| No object found for #{k}"
      err = null
    if not err?
      await @_unlink_all { type, key : k }, defer err

    log.debug "- DB remove #{key}/#{kvsk} -> #{if err? then 'ok' else #{err.message}}"
    cb err

  #-----

  lookup : ({type, name}, cb) ->
    esc = make_esc cb, "BaseKvStore::lookup"
    await @resolve { name, type }, esc defer key
    await @_get { key }, esc defer value
    cb null, value

##=======================================================================
