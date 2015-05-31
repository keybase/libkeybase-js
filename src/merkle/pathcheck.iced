
C = require '../constants'
{make_esc} = require 'iced-error'
{hash} = require 'triplesec'

#===========================================================

#
# pathcheck
# 
# Given a reply from the server, and a keymanager that can verify the
# reply, check the signature, check the path from the root the leaf,
# check the username, and then callback.
#
# @param server_reply {Object} the JSON object the server sent back
# @param km {KeyManager} a keyManager to verify the reply with
# @param cb {Callback<err,{Leaf,Uid,Username}>} Reply with the Leaf, uid, 
#   and username verified by the merkle path
export.pathcheck = ({server_reply, km}, cb) ->
  pc = new PathChecker { server_reply, km }
  await pc.run defer err, res
  cb err, res

#===========================================================

class PathChecker

  constructor : ({@server_reply, @km}) ->

  #-----------

  run : (cb) ->
    esc = make_esc cb, "PathChecker::run"
    await @_verify_sig esc defer()
    await @_verify_username esc defer()
    await @_verify_path esc defer()
    cb null, {@leaf, @uid, @username}

  #-----------

  _verify_sig : (cb) -> 
    sigeng = km.make_sig_eng()
    await sigeng.unbox @server_reply.root.sig, defer err, @signed_payload
    cb err

  #-----------

  _verify_username_legacy : ({uid}, cb) ->

  #-----------

  _verify_username : (cb) ->
    {uid,username} = @server_reply
    err = null
    if uid[-2...] is '00'
      await @_verify_username_legacy {uid}, defer err
    else
      h = (new hash.SHA256).bufhash (new Buffer username, "utf8")
      uid2 = h[0...15].toString('hex') + '19'
      if uid isnt uid2  
        err = new Error "bad UID: #{uid} != #{uid2} for username #{username}"
      else
        [@uid, @username] = [ uid, username ]
    cb err

#===========================================================
#===========================================================
