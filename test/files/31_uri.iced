
{URI} = require '../../'

test = (T, i, {inp, outp, full}) ->
  outp or= inp
  uri = URI.parse inp
  outp2 = uri.format { full }
  T.equal outp, outp2, "test #{i}"

exports.test_good_uris = (T,cb) ->
  test T, 1, { inp : "keybase://max@", outp : "keybase://max@/0" , full : false }
  test T, 2, { inp : "keybase://max@/aabb/ccdd", full : false }
  test T, 3, { inp : "keybase://max@/aabb/ccdd/eeff", full : false }
  test T, 4, { inp : "keybase://max@foo.io/aabb/ccdd/eeff", full : false }
  test T, 5, { inp : "keybase://max@foo.io:400/aabb/ccdd/eeff", full : false }
  test T, 6, { inp : "keybase://max@foo.io:400/aabb/ccdd/eeff", full : true }
  test T, 7, { inp : "keybase://max@foo.io:443", outp : "keybase://max@foo.io/0", full : true }
  test T, 8, { inp : "keybase://max@", outp : "keybase://max@keybase.io/0", full : true }
  test T, 9, { inp : "keybase://max;fingerprint=aa@/aa", full : false }
  test T, 10, { inp : "keybase://max;fingerprint=aa@foo.io/0", full : false }
  cb()

bad_parse = (T, i, uri, msg) ->
  try 
    u = URI.parse uri
    T.assert false, "should have failed to parse #{i}"
  catch err
    T.assert err.message.indexOf(msg) >= 0, "found message #{msg} in #{i}"

exports.test_bad_format = (T,cb) ->
  try
    x = (new URI {}).format {}
    T.assert false, "shouldn't have parsed"
  catch err
    T.equal err.message, "need username", "right error"
  cb()

exports.test_bad_uris = (T,cb) ->
  bad_parse T, 1, "http://yahoo.com", "can't parse keybase URI that doesn't start with keybase://"
  bad_parse T, 2, "keybase://foo/bar", "'authority' section must be username@[host]"
  bad_parse T, 3, "keybase://@foo.io/bar", "'username' section is required"
  bad_parse T, 4, "keybase://max;boo=44@foo.io/bar", "'fingerprint=' is the only userinfo now allowed"
  bad_parse T, 5, "keybase://max@foo.io:a:4/bar", "[hostname[:port]] did not parse"
  bad_parse T, 6, "keybase://max@foo.io:aa/bar", "bad port given"
  cb()

test_eq = (T,i,[a,b],expected) ->
  res = (URI.parse(a).eq(URI.parse(b)))
  T.equal res, expected, "Test eq #{i}"

exports.test_eq = (T,cb) ->
  test_eq T, 1, [ "keybase://max@", "keybase://max@keybase.io:443/0" ], true
  test_eq T, 2, [ "keybase://max@:44/a/b/c", "keybase://max@keybase.io/a/b/c "], false
  cb()

#exports.test_base = (T,cb) ->
#  abstracts = [ "open", "nuke", "close", "_unlink", "_unlink_all", "_remove", "_put", "_get" ]
#  # b = new Base {}
#  # for method in abstracts
#  #   await b[method] {}, defer err
#  #   T.assert (err? and err instanceof E.UnimplementedError), "method #{method} failed"
#  cb()
#