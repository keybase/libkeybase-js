##### Signed by https://keybase.io/max
```
-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.22 (Darwin)
Comment: GPGTools - https://gpgtools.org

iQEcBAABCgAGBQJT/MQnAAoJEJgKPw0B/gTf7AkH/j5yPpjziXIEbBoQavNBietF
1Pn6BgoZ/eRAfKg8QLBJ79nwcD281Kvyno+6IflFhlZeUOw+tYvbWBbdIyVDANZs
4o5XkvralBDGAPxK1nPjLNDYn05QlSehrAnJbyqHU7G708Cr6I6zQVuyWD+o7AJ/
AYn4lE4Hr80G0psHaMxJlf03046oWQlZ8HjCB6EJAaEmY3kGt9PEWDsPuKgCg8uB
ZIo6XRkNj1UAlPP1Wc1/74ePhjfMFv7r5tqWoQSi4cWQNq0uWCSIX8SnHseuXnUt
kSWlUjVF4cKJmEE4GdTo1RXHoViobN8EVuMpP+ljP9rYv/jurETkZwpJty5JE1Q=
=oaaN
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size    exec  file                       contents                                                        
              ./                                                                                         
587             .gitignore               558dd5f4ada1e956eaacd41ea72f4049037edc7a1973f9c3819c01eb349efb60
1484            LICENSE                  20a8a5de57bfaf6870517c52265d4469770a23cbc1af85eb9973ce639b0abff2
1039            Makefile                 d0dc3fc7c361d204d94ee3ead4097b7434657eb090eebd3a13622da1858f0b40
                browser/                                                                                 
6045              libkeybase.js          92b7c0f624b90754f89aa55f19a7cd6d45dc22cdac2c8e5ed9a353e26d498c89
                lib/                                                                                     
267               constants.js           d53b266f88a692da238b75eca7edf4299f4869853219bcbc4e624604d22c4f11
179               main.js                aa9508f13459b0644abd3437352e970d01ade1596e7f311c9600bfea012f1b22
                  merkle/                                                                                
4618                leaf.js              5d1b73ac2ab2f95c0c6ba000ba6a3bbb4f20395554172b4662838ed1771a0a68
760             package.json             78629f67ebd7149a5c09cfd14c3d4b648fe3aefd34d7d8b39e0456a85f59dbeb
                src/                                                                                     
150               constants.iced         51334d9c4a8809755185ffa9363bc2bfd40582a78b18bf048136961b4385dfae
97                main.iced              1dd0becdd1418bf1431607428152892aa0daf12d102a5c6aece232f55c5195e8
                  merkle/                                                                                
3035                leaf.iced            259540db4476512840f1bdde61c414d170195cb7ca38470b35ac14aef101eced
                test/                                                                                    
                  browser/                                                                               
287                 index.html           e31387cfd94034901e89af59f0ad29a3e2f494eb7269f1806e757be21b3cf33e
208                 main.iced            4eb5b1aa5b9fdcd6d5c83f83a74e546cb851f85cb81b275b02aeead305d130d6
121956              test.js              df61493b34ade7ac158e9c4e28589a6c5d7789574546d200f1ae0ecc14c4e7ae
                  files/                                                                                 
1455                30_merkle_leaf.iced  42cdc3923ef965f96c43912206efc469aeb0d39b7bedabff18def881a575bfd7
52                run.iced               8e58458d6f5d0973dbb15d096e5366492add708f3123812b8e65d49a685de71c
```

#### Ignore

```
/SIGNED.md
```

#### Presets

```
git      # ignore .git and anything as described by .gitignore files
dropbox  # ignore .dropbox-cache and other Dropbox-related files    
kb       # ignore anything as described by .kbignore files          
```

<!-- summarize version = 0.0.9 -->

### End signed statement

<hr>

#### Notes

With keybase you can sign any directory's contents, whether it's a git repo,
source code distribution, or a personal documents folder. It aims to replace the drudgery of:

  1. comparing a zipped file to a detached statement
  2. downloading a public key
  3. confirming it is in fact the author's by reviewing public statements they've made, using it

All in one simple command:

```bash
keybase dir verify
```

There are lots of options, including assertions for automating your checks.

For more info, check out https://keybase.io/docs/command_line/code_signing