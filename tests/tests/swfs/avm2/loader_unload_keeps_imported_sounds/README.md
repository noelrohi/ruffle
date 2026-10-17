An importer takes the sound `beep` from `asset.swf` by ImportAssets2 and is unloaded with `unloadAndStop(true)`. The Rust test `released_importer_keeps_imported_sound` checks that releasing the importer's library leaves the sound playable, since `asset.swf` defined it, and that a sound that is no longer registered fails to start.

`asset.swf` and `importer.swf` are written by `make_swfs.py` (`python3 make_swfs.py .`): mxmlc cannot emit ImportAssets. `test.swf` is built with Apache Flex SDK 4.16.1 and playerglobal 32.0:

    mxmlc -target-player 32.0 -swf-version 15 -default-size 550 400 -omit-trace-statements=false -debug=false -static-link-runtime-shared-libraries=true -source-path . -output test.swf Test.as
