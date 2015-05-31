
C = require '../constants'
{make_esc} = require 'iced-error'
{hash} = require 'triplesec'
merkle = require 'merkle-tree'
{a_json_parse} = require('iced-utils').util

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
module.exports = pathcheck = ({server_reply, km}, cb) ->
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
    await @_verify_username esc defer uid, username
    await @_verify_path {uid}, esc defer leaf
    cb null, {leaf, uid, username}

  #-----------

  _verify_sig : (cb) -> 
    esc = make_esc cb, "_verify_sig"
    sigeng = @km.make_sig_eng()
    await sigeng.unbox @server_reply.root.sig, esc defer raw
    await a_json_parse raw.toString('utf8'), esc defer @_signed_payload
    cb null

  #-----------

  _extract_nodes : (list) ->
    ret = {}
    for {node} in list
      ret[node.hash] = JSON.parse node.val
    return ret

  #-----------

  _verify_username_legacy : ({uid, username}, cb) ->
    esc = make_esc cb, "PathChecker::_verify_username_legacy"
    root = @_signed_payload.body.legacy_uid_root
    nodes = @_extract_nodes @server_reply.uid_proof_path
    tree = new LegacyUidNameTree { root, nodes }
    await tree.find {key : username}, esc defer leaf
    err = if (leaf is uid) then null 
    else new Error "UID mismatch #{leaf} != #{uid} in tree for #{username}"
    cb err

  #-----------

  _verify_path : ({uid}, cb) ->
    root = @_signed_payload.body.root
    nodes = @_extract_nodes @server_reply.path
    tree = new MainTree { root, nodes }
    await tree.find {key : uid}, defer err, leaf
    cb err, leaf

  #-----------

  _verify_username : (cb) ->
    {uid,username} = @server_reply
    err = null
    if uid[-2...] is '00'
      await @_verify_username_legacy {username,uid}, defer err
    else
      h = (new hash.SHA256).bufhash (new Buffer username, "utf8")
      uid2 = h[0...15].toString('hex') + '19'
      if uid isnt uid2  
        err = new Error "bad UID: #{uid} != #{uid2} for username #{username}"
    cb err

#===========================================================

class BaseTree extends merkle.Base

  constructor : ({@root, @nodes}) ->
    super {}

  cb_unimplemented : (cb) ->
    cb new Error "not a storage engine"

  store_node : (args, cb) -> @cb_unimplemented cb
  store_root : (args, cb) -> @cb_unimplemented cb

  lookup_root : (cb) ->
    cb null, @root

  lookup_node : ({key}, cb) ->
    ret = @nodes[key]
    err = if ret? then null else new Error "key '#{key}' not found"
    cb err, ret

#===========================================================

class LegacyUidNameTree extends BaseTree

  hash_fn : (s) -> (new hash.SHA256).bufhash(new Buffer s, 'utf8').toString('hex')

#===========================================================

class MainTree extends BaseTree

  hash_fn : (s) -> (new hash.SHA512).bufhash(new Buffer s, 'utf8').toString('hex')

#===========================================================
