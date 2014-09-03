

# Loads a list of recruited users who are now ready to be verified.
await me.load_recruited_user_list {}, defer err, recruits

for r in recruits

  # The recruits are skeletons, so we still need to load their signature chain
  # from the server.
  await r.load {}, defer err
  idtab = r.get_identity_table()

  # Check the remote tabs as usual
  await idtab.check_remotes {}, defer err

  # Our assertions are preloaded in the object
  await idtab.assert {}, defer err

  # Does the following:
  #   1. Gets the needed KeyManager from me
  #   2. Gets the user's keymanager for encryption for the given app
  #   3. Decrypts and reencrypts
  await r.release { me } , defer err, secret

  # And now perform app-specific information with the secret...
