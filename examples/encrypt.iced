
libkb = require 'libkeybase'
{User} = libkb
{LocalStore} = require 'myapp'


# First load me from the server, and check that my signature chain checks out.
# Also, assert that my PGP key matches the give username.  This feature is optional.
# You can alternatively provide a key manager here, for the key assertion.
await User.fetch_user { query : { keybase : "max" }, assertions : [ { key : "aabbccdd" } ] }, defer err, me

# You can alternatively assert in a separate call
await user.assert [ { key : "aabbccdd" } ], defer err

await LocalStore.open defer err, store

mode = # Strict, or flexible.  If flexible, then we can return a "dummy" user
       # that implements the methods below.  If strict and not found, then we'll
       # raise an Error.

await User.fetch_user { query : { "twitter" : "malgorithms" }, mode }, defer err, user

# Check tracking for this use.  Check the local store, and/or check my tracking statements
# remotely fetched for 'me'.
await user.check_tracking { store, tracker : me }, defer err, summary

await user.fetch_key_manager { { app : "myencryptor" }, mode }, defer err, km
