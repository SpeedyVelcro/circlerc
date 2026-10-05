# CircleRC
CircleRC was originally a Ludum Dare 47 entry on the theme "stuck in a loop". You control an RC car with broken steering that can only go in loops/circles.

![CircleRC Screenshot](readme-screenshot.png)
## Ludum Dare 47

This repository includes post-LD improvements. If you want to see the source code as it was when I submitted the game to Ludum Dare, please see the v1.0.0 tag.

## License
See [`LICENSE.txt`](./LICENSE.txt) for the repository license.

Note that some parts of the repository are licensed under different (but
compatible) licenses. You will have to comply with all applicable licenses.

The following directories have different licenses:
```
/addons/sv_about_menu
/Font
/Sound
/Art/CircleRC
```

These directories (or their subdirectories) have their own LICENSE.txt file which
specifies the license of the files therein.

Also note that the directory `Art/Icons` contains third-party brand icons. These are
the property of their respective owners, who likely have their own terms for
usage. They are used here in a descriptive capacity for linking social media
pages and websites.

## Release Process
The pipeline will automatically create releases and tags when you push
a main version tag to the repository. A main version tag is a tag in
the form `vX.X.X`, with no extra information appended.

Creating a tag or a release using a tag `vX.X.X` will automatically
create tags and releases for Newgrounds and Game Jolt via the
pipelines. These releases will be tagged `vX.X.X-ng` and `vX.X.X-gj`
respectively.

While creating the tag directly and creating the release have the same
effects, creating the tag directly makes the pipelines look a little
nicer and less confusing. GitHub doesn't have a way to create tags
directly, so run the following commands:
```bash
git tag vX.X.X
git push origin tag v0.0.0
```
