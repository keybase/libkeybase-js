{make_esc} = require 'iced-error'
fs = require('fs')
{ParsedKeys, SigChain, key_managers_from_all_keys} = require('../..')
C = require('../..').constants
execSync = require('child_process').execSync
fs = require('fs')

ralph_all_sigs = require '../data/ralph_sig_chain.json'
ralph_all_keys = require '../data/ralph_all_keys.json'
simple_chain = require '../data/simple_chain.json'

#====================================================

exports.test_ralph_sig_chain = (T,cb) ->
  # Ralph is a test user I created by hand on my local server. This test is
  # mainly to make sure that the generated chains we're using in other tests
  # bear some relationship to reality.  - Jack
  esc = make_esc cb, "test_ralph_sig_chain"
  bundles_list = (blob.bundle for kid, blob of ralph_all_keys)
  await ParsedKeys.parse {bundles_list}, esc defer parsed_keys
  await SigChain.replay {
    sig_blobs: ralph_all_sigs
    parsed_keys
    uid: "bf65266d0d8df3ad5d1b367f578e6819"
    username: "ralph"
    eldest_kid: "0101c304e8c86c8f4b6773478eed4d05e9ffdddc81c7068c50db1b5bad9a904f5f890a"
  }, esc defer sigchain
  links = sigchain.get_links()
  T.assert links.length == 5, "Expected exactly 5 links, got #{links.length}"
  cb()

exports.test_simple_chain = (T, cb) ->
  esc = make_esc cb, "test_simple_chain"
  {chain, keys} = simple_chain
  await ParsedKeys.parse {bundles_list: (bundle for kid, bundle of keys)}, esc defer parsed_keys
  await SigChain.replay {
    sig_blobs: chain
    parsed_keys
    uid: "74c38cf7ceb947f5632045d8ca5d48d3017eab8590bb96ead58d317b0eb709df19"
    username: "max32"
    eldest_kid: "0120224a6cc658cba6a6d2feac1a930b4d907598daa382063ce79150c343b82fca360a"
  }, esc defer sigchain
  links = sigchain.get_links()
  T.assert links.length == 1, "Expected exactly 1 link, got #{links.length}"
  cb()
