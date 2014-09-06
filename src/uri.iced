
#
#  Key-identier URIs, like:
#
#    keybase://max@/aabbccee20/iphone+2
#    keybase://max@keybase.io/aabbccee20/iphone+2   [equivalent to the above]
#    keybase://max;fingerprint=8EFBE2E4DD56B35273634E8F6052B2AD31A6631C@/aabbccee20/iphone+3 [pinning a key]
#
#  We're going off of URI-scheme as in this page:
#     - official: http://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml
#     - conventional: http://en.wikipedia.org/wiki/URI_scheme
#
#  Within those schemes, that for SSH looks sort of like the above:
#     - https://tools.ietf.org/html/draft-ietf-secsh-scp-sftp-ssh-uri-04
#
#  In the above examples, 'aabbccee20' is an App ID.     
#

exports.URI = class URI

  #--------------------------
  
  constructor : ({@username, @fingerprint, @app_id, @device_id, @host, @port}) ->

  #--------------------------
  
  format : ({full}) -> 
    parts = [ "keybase:/" ]

    throw new Error "need username" unless @username

    where = @username
    where += ";fingerprint=#{@fingerprint}" if @fingerprint?
    host = @host or (if full then "keybase.io" else null)
    if host? then where += "@#{host}"
    if @port? then where += ":#{@port}"
    parts.push where

    app_id = @app_id or 0
    parts.push app_id
    parts.push @device_id if @device_id

    return parts.join "/'"



