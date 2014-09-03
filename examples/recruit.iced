
libkb = require 'libkeybase'
assert = require 'assert'
{User,E} = libkb

# Your app needs to provide some idea of local storage that meets our requirements.
{LocalStore} = require 'myapp'

# Open the LocalStore, which can create one if none existed beforehand.
await LocalStore.open defer err, store

# What if we fail to load a user?
await User.load { store, query : { keybase : "chris_paradise" } }, defer err, user

# This example is only for users who aren't found
assert (err? and (err instanceof E.NotFoundError))

# Still should be able to load me...
await User.load { store, query : { keybase : "max" } }, defer err, me

# Come up with some secret to later release to the user...
secret = # ....
app = # id of our app.  Question: namespace or ID or what?

assertion = Assertion.compile "twitter://maxtaco || github://maxtaco || reddit://peterpan"

#
# Alternative assertion representation in JSON-lisp form:
#
assertion = Assertion.create [ "and"
  [ "or"
    [ "p", "twitter", "maxtaco" ],
    [ "p", "github",  "dbag2"   ]
  ],
  [ "or"
    [ "p", "http",  "eatabag.com" ],
    [ "p", "https", "eatabag.com" ],
    [ "p", "dns",   "eatabag.com" ]
  ],
  [ "p", "https",   "securedump.com" ]
]

#
# Will perform the following steps:
#
#   1. Load the key manager for me with (ENCRYPT|SIGN) ops flags.
#   2. Make a JSON object with my assertions, and my encrypted secret
#   3. Sign the JSON object with my public key
#   4. Post it to the server, yielding the given ID
#
# Note that you can provide an optional expire_in, which will tell the server when
# to throw it away (and allows you to know when you're done with it.)
#
await me.recruit_user { assertion, expire_in, app, secret }, defer err, id

