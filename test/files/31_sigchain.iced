{make_esc} = require 'iced-error'
fs = require('fs')
node_sigchain = require('../..')
C = require('../..').constants
execSync = require('child_process').execSync
fs = require('fs')
path = require('path')
tv = require 'keybase-test-vectors'

#====================================================

exports.test_all_sigchain_tests = (T, cb) ->
  # This runs all the tests described in tests.json, which included many
  # example chains with both success parameters and expected failures.
  for test_name, body of tv.chain_tests.tests
    args = {T}
    for key, val of body
        args[key] = val
    T.waypoint test_name
    await do_sigchain_test args, defer err
    T.assert not err?, "Error in sigchain test '#{test_name}': #{err}"
  cb()

exports.test_eldest_key_required = (T, cb) ->
  # Make sure that if we forget to pass eldest key to SigChain.replay, that's
  # an error. Otherwise we could get confisingly empty results.
  esc = make_esc cb, "test_eldest_key_required"
  {chain, keys, username, uid} = tv.chain_test_inputs["ralph_chain.json"]
  await node_sigchain.ParsedKeys.parse {bundles_list: keys}, esc defer parsed_keys
  await node_sigchain.SigChain.replay {
    sig_blobs: chain
    parsed_keys
    uid
    username
    # OOPS! Forgot the eldest_kid!
  }, defer err, sigchain
  T.assert err, "Forgetting to pass the eldest_kid should fail the replay!"
  cb()

exports.test_chain_link_format = (T, cb) ->
  # The Go implementation is strict about details like UID length. This
  # implementation was lenient, so we ended up creating some test cases that
  # were unusable with Go. After fixing the test cases, we added
  # check_link_payload_format() to make sure we don't miss this again. This
  # test just provides coverage for that method. It's not necessarily a failure
  # that other implementations should reproduce.
  bad_uid_payload =
    body:
      key:
        uid: "wronglen"
  await node_sigchain.check_link_payload_format {payload: bad_uid_payload}, defer err
  T.assert err?, "short uid should fail"
  if err?
    T.assert err.code == node_sigchain.E.code.BAD_LINK_FORMAT, "wrong error type"
  cb()

do_sigchain_test = ({T, input, err_type, len, sibkeys, subkeys, eldest}, cb) ->
  esc = make_esc cb, "do_sigchain_test"
  input_blob = tv.chain_test_inputs[input]
  {chain, keys, username, uid} = input_blob
  await node_sigchain.ParsedKeys.parse {bundles_list: keys}, esc defer parsed_keys
  if not eldest?
    # By default, use the first key as the eldest.
    eldest_kid = parsed_keys.kids_in_order[0]
  else
    eldest_kid = input_blob.label_kids[eldest]
  await node_sigchain.SigChain.replay {
    sig_blobs: chain
    parsed_keys
    uid
    username
    eldest_kid
  }, defer err, sigchain
  if err?
    if not err_type? or err_type != node_sigchain.E.name[err.code]
      # Not an error we expected.
      cb err
      return
    else
      # The error we were looking for!
      cb null
      return
  else if err_type?
    # We expected an error, and didn't get one!
    cb new Error "Expected error of type #{err_type}"
    return
  # No error.
  # Check the number of unrevoked links.
  links = sigchain.get_links()
  if len?
    T.assert links.length == len, "Expected exactly #{len} links, got #{links.length}"
  # Use the creation time of the last sigchain link to get keys. (We don't want
  # tests to start breaking in a few years.) But also define a time in the
  # future that's guaranteed to expire all keys.
  now = 0  # For empty sigchains now doesn't matter, as long as it's a number.
  if links.length > 0
    last_link = links[links.length - 1]
    now = last_link.ctime_seconds
  far_future = now + 100 * 365 * 24 * 60 * 60  # 100 years from now
  # Check the number of unrevoked/unexpired sibkeys.
  sibkeys_list = sigchain.get_sibkeys {now}
  if sibkeys?
    T.assert sibkeys_list.length == sibkeys, "Expected exactly #{sibkeys} sibkeys, got #{sibkeys_list.length}"
  T.assert sigchain.get_sibkeys({now: far_future}).length == 0, "Expected no sibkeys in the far future."
  # Check the number of unrevoked/unexpired subkeys.
  subkeys_list = sigchain.get_subkeys {now}
  if subkeys?
    T.assert subkeys_list.length == subkeys, "Expected exactly #{subkeys} subkeys, got #{subkeys_list.length}"
  T.assert sigchain.get_subkeys({now: far_future}).length == 0, "Expected no subkeys in the far future."
  # Get keys with the default time parameter (real now), just to make sure
  # nothing blows up (and to improve coverage :-D)
  sigchain.get_sibkeys {}
  sigchain.get_subkeys {}
  cb()
