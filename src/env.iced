
constants = require './constants'
{make_email,make_full_username} = require './util'
SRV = constants.server
log = require 'iced-logger'

##=======================================================================

class RunMode

  DEVEL : 0
  PROD : 1

  constructor : (s) ->
    t =
      devel : @DEVEL
      prod : @PROD

    [ @_v, @_name, @_chosen ] = if (s? and (m = t[s])?) then [m, s, true ]
    else [ @PROD, "prod", false ]

  is_devel : () -> (@_v is @DEVEL)
  is_prod : () -> @_v is @PROD

  toString : () -> @_name
  chosen : () -> @_chosen

##=======================================================================

class Strictness

  NONE : 0
  SOFT : 1
  STRICT : 2

  constructor : (s, def = "soft") ->
    t =
      none : @NONE
      soft : @SOFT
      strict : @STRICT

    [ @_v, @_name, _chosen ] = if (s? and (m = t[s])?) then [ m, s, true ]
    else [ t[def], def, false ]

  is_soft : () -> (@_v is @SOFT)
  is_none : () -> (@_v is @NONE)
  is_strict : () -> (@_v is @STRICT)
  toString : () -> @_name
  chosen : () -> @_chosen

##=======================================================================

class Env

  # Environment shoudl still function without a configuration, since the
  # environment might tell us how to load the configuration.  But it should
  # work better with it....
  constructor : () ->
    @config = null
    @kvstore = null

  # Override this if your app has a configuration
  open_config_file : (opts, cb) ->
    cb null

  #---------------------------------------

  config_logger : () ->
    p = log.package()
    if @get_debug()
      p.env().set_level p.DEBUG
    else if @get_quiet()
      p.env().set_level p.ERROR
    if @get_no_color()
      p.env().set_use_color false

  #---------------------------------------

  get_opt : ({config, dflt}) ->
    co = @config?.get_obj()
    return (co? and config? co) or dflt?() or null

  get_port   : () ->
    @get_opt
      config  : (c) -> c?.server?.port
      dflt    :     -> SRV.port

  get_host   : ( ) ->
    @get_opt
      config : (c) -> c.server?.host
      dflt   : ( ) -> SRV.host

  get_debug  : ( ) ->
    @get_opt
      config : (c) -> c.run?.d
      dflt   : ( ) -> false

  get_quiet :  () ->
    @get_opt
      config : (c) -> c.run?.quiet
      dflt   : ( ) -> false

  get_no_tls : ( ) ->
    @get_opt
      config : (c) -> c.server?.no_tls
      dflt   : ( ) -> SRV.no_tls

  get_api_uri_prefix : () ->
    @get_opt
      config : (c) -> c.server?.api_uri_prefix
      dflt   : ( ) -> SRV.api_uri_prefix

  get_run_mode : () ->
    unless @_run_mode
      raw = @get_opt
        config : (c) -> c.run?.mode
        dflt   : null
      @_run_mode = new RunMode raw
    return @_run_mode

  get_username : () ->
    @get_opt
      config : (c) -> c.user?.name
      dflt   : -> null

  is_me : (u2) ->
    u2? and (u2.toLowerCase() is @get_username().toLowerCase())

  get_uid : () ->
    @get_opt
      config : (c) -> c.user?.id
      dflt   : -> null

  get_email : () ->
    @get_opt
      config : (c) -> c.user?.email
      dflt   : -> null

  get_proxy : () ->
    @get_opt
      config : (c) -> c.proxy?.url
      dflt   : -> null

  get_proxy_ca_certs : () ->
    @get_opt
      config : (c) -> c.proxy?.ca_certs
      dflt   : -> null

  get_merkle_checks : () ->
    unless @_merkle_mode
      raw = @get_opt
        config : (c) -> c.merkle_checks
        dflt   :     -> false
      @_merkle_mode = new Strictness raw, (if @is_test() then 'strict' else 'soft')
    return @_merkle_mode

  get_merkle_key_fingerprints : () ->
    split = (x) -> if x? then x.split(/:,/) else null
    @get_opt
      config : (c) -> c?.keys?.merkle
      dflt   :     => if @is_test() then constants.testing_keys.merkle else constants.keys.merkle

  get_no_color : () ->
    @get_opt
      config : (c) -> c.no_color
      dflt   :     -> false

  #---------------

  is_configured : () -> @get_username()?

  #---------------

  is_test : () -> (@get_run_mode().is_devel()) or (@get_host() in [ 'localhost', '127.0.0.1' ])

  #---------------

  keybase_email : () -> make_email @get_username()

  #---------------

  keybase_full_username : () -> make_full_username @get_username()

##=======================================================================

_env = null
exports.init_env = (a) -> _env = new Env
exports.env      = ()  -> _env

