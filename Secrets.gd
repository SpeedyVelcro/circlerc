class_name Secrets
extends Object
## Static class bearing sensitive secrets.
##
## Secrets such as encryption or API keys should be injected into this file.
## Changes to this file should NOT be committed to the repo once secrets have
## been injected.
##
## For builds with injected secrets, you should build the game with
## [url=https://docs.godotengine.org/en/stable/engine_details/development/compiling/compiling_with_script_encryption_key.html]PCK encryption[/url],
## as this will encrypt GDScript files. This is the reason secrets are stored
## here instead of project settings - I cannot find reliable information on whether
## project settings can be encrypted, but .gd files are one of the examples they
## give for PCK encryption. Plus, separating secrets off into their own file
## means you can be a bit more selective about what you encrypt if you so choose.
##
## Each secret is given a unique default string value to make find-and-replace
## operations easier for automatic secret injection. To inject secrets before
## compile time in an automated way, it is recommended to use the [code]sed[/code]
## command. For example:
## [code]sed -i 's/replace_me_newgrounds_app_id/12345:aBCdEfgH/ Secrets.gd'[/code]
##
## Note that this is not a silver-bullet and secrets can still be extracted
## from encrypted PCKs with a small amount of effort. Thus, this is best
## used for less sensitive secrets and only when it is absolutely necessary. e.g.
## the Newgrounds and Game Jolt APIs require you to use client-side secrets
## to identify your game client (making it necessary), and the only thing
## you can do with those secrets is cheat at medals and scoreboards (making it
## less sensitive). Of course, cheating isn't ideal, but I believe the platform
## maintainers are aware what devs can do to protect their secrets are limited,
## so it's more of an honour system anyway. Thus, this is only a best effort
## to protect the secrets as a courtesy to the Game Jolt and Newgrounds communities,
## and the hope is that members of those communities will play nice and not
## try to cheat achievement unlocks (there are probably much easier ways of
## causing mischief on Newgrounds and Game Jolt than stealing these keys).

## Newgrounds app ID. The app ID includes a small secret after the colon (though
## I assume it's primarily there to help games that don't support encryption),
## so it is indeed important to protect believe it or not.
const NEWGROUNDS_APP_ID := "replace_me_newgrounds_app_id"

## Newgrounds AES 128 encryption key. You must provide this as it is required
## by the plugin, and you must enable AES 128 encryption in your game's API
## tools page..
const NEWGROUNDS_AES_128_ENCRYPTION_KEY := "replace_me_newgrounds_aes_128_encryption_key"

## Game Jolt private key. Obtain this from your game's API settings page.
## Remember to supply the game ID as well, which can be provided directly
## through the project settings for the plugin as it is not a secret.
const GAME_JOLT_PRIVATE_KEY := "replace_me_game_jolt_private_key"
