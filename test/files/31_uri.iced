
{URI} = require '../../'

test = (T, i, {inp, outp, full}) ->
  outp or= inp
  uri = URI.parse inp
  outp2 = uri.format { full }
  T.equal outp, outp2, "test #{i}"

exports.test_good_uris = (T,cb) ->
  test T, 1, { inp : "keybase://max@", outp : "keybase://max@/0" , full : false }
  cb()