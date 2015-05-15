{make_esc} = require 'iced-error'
fs = require('fs')
node_sigchain = require('../..')
C = require('../..').constants
execSync = require('child_process').execSync
fs = require('fs')

ralph_chain = require '../data/ralph_chain.json'
simple_chain = require '../data/simple_chain.json'
missing_kid_chain = require '../data/missing_kid_chain.json'
missing_reverse_kid_chain = require '../data/missing_reverse_kid_chain.json'
mismatched_ctime_chain = require '../data/mismatched_ctime_chain.json'
mismatched_kid_chain = require '../data/mismatched_kid_chain.json'
mismatched_fingerprint_chain = require '../data/mismatched_fingerprint_chain.json'
bad_signature_chain = require '../data/bad_signature_chain.json'
bad_reverse_signature_chain = require '../data/bad_reverse_signature_chain.json'
example_revokes_chain = require '../data/example_revokes_chain.json'
signed_with_revoked_key_chain = require '../data/signed_with_revoked_key_chain.json'

#====================================================

exports.test_eldest_key_required = (T, cb) ->
  # Make sure that if we forget to pass eldest key to SigChain.replay, that's
  # an error. Otherwise we could confisingly empty results.
  esc = make_esc cb, "test_eldest_key_required"
  {chain, keys, username, uid} = ralph_chain
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

do_sigchain_test = ({T, input, err_type, len, sibkeys, eldest_index}, cb) ->
  esc = make_esc cb, "do_sigchain_test"
  if not eldest_index?
    # By default, use the first key as the eldest.
    eldest_index = 0
  {chain, keys, username, uid} = input
  await node_sigchain.ParsedKeys.parse {bundles_list: keys}, esc defer parsed_keys
  await node_sigchain.SigChain.replay {
    sig_blobs: chain
    parsed_keys
    uid
    username
    eldest_kid: parsed_keys.kids_in_order[eldest_index]
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
  links = sigchain.get_links()
  if len?
    T.assert links.length == len, "Expected exactly #{len} links, got #{links.length}"
  sibkeys_list = sigchain.get_sibkeys()
  if sibkeys?
    T.assert sibkeys_list.length == sibkeys, "Expected exactly #{sibkeys} sibkeys, got #{sibkeys_list.length}"
  cb()

exports.test_ralph_sig_chain = (T,cb) ->
  # Ralph is a test user I created by hand on my local server. I fetched his
  # sigs and keys from the API, and then massaged them into our input format.
  # This test is mainly to make sure that the generated chains we're using in
  # other tests bear some relationship to reality.  - Jack

  # The eldest key for this test is not the first in the list, it's the 2nd
  # (index 1).

  # TODO: Use labels instead of indices.
  do_sigchain_test {T, input: ralph_chain, len: 5, eldest_index: 1}, cb

exports.test_simple_chain = (T, cb) ->
  # Test a simple chain, just one link.
  do_sigchain_test {T, input: simple_chain, len: 1}, cb

exports.test_error_unknown_key = (T, cb) ->
  # Check the case where a signing kid is simply missing from the list of
  # available keys (as opposed to invalid for some other reason, like having
  # been revoked).
  do_sigchain_test {T, input: missing_kid_chain, err_type: "NONEXISTENT_KID"}, cb

exports.test_error_unknown_reverse_sig_key = (T, cb) ->
  # As above, but for a reverse sig.
  do_sigchain_test {T, input: missing_reverse_kid_chain, err_type: "NONEXISTENT_KID"}, cb

exports.test_error_bad_signature = (T, cb) ->
  # Change some bytes from the valid signature, and confirm it gets rejected.
  do_sigchain_test {T, input: bad_signature_chain, err_type: "VERIFY_FAILED"}, cb

exports.test_error_bad_reverse_signature = (T, cb) ->
  # Change some bytes from the valid reverse signature, and confirm it gets rejected.
  do_sigchain_test {T, input: bad_reverse_signature_chain, err_type: "VERIFY_FAILED"}, cb

exports.test_error_mismatched_ctime = (T, cb) ->
  # We need to use the server-provided ctime to unbox a signature (PGP key
  # expiry is checked at the signature level, although NaCl expiry is checked
  # as we replay the chain). We always need to check back after unboxing to
  # make sure the internal ctime matches what the server said. This test
  # exercises that check.
  do_sigchain_test {T, input: mismatched_ctime_chain, err_type: "CTIME_MISMATCH"}, cb

exports.test_error_mismatched_kid = (T, cb) ->
  # We need to use the server-provided KID to unbox a signature. We always need
  # to check back after unboxing to make sure the internal KID matches the one
  # we actually used. This test exercises that check.
  # NOTE: I generated this chain by hacking some code into kbpgp to modify the
  # payload right before it was signed.
  do_sigchain_test {T, input: mismatched_kid_chain, err_type: "KID_MISMATCH"}, cb

exports.test_error_mismatched_fingerprint = (T, cb) ->
  # We don't use fingerprints in unboxing, but nonetheless we want to make sure
  # that if a chain link claims to have been signed by a given fingerprint,
  # that does in fact correspond to the KID of the PGP key that signed it.
  # NOTE: I generated this chain by hacking some code into kbpgp to modify the
  # payload right before it was signed.
  do_sigchain_test {T, input: mismatched_fingerprint_chain, err_type: "FINGERPRINT_MISMATCH"}, cb

exports.test_revokes = (T, cb) ->
  # The chain is length 10, but after 2 sig revokes it should be length 8.
  # Likewise, 6 keys are delegated, but after 2 sig revokes and 2 key revokes
  # it should be down to 2 keys.
  do_sigchain_test {T, input: example_revokes_chain, len: 8, sibkeys: 2}, cb

exports.test_error_revoked_key = (T, cb) ->
  # Try signing a link with a key that was previously revoked.
  do_sigchain_test {T, input: signed_with_revoked_key_chain, err_type: "INVALID_SIBKEY"}, cb
