#!/bin/bash

rm -rf icon.iconset || exit 1
mkdir icon.iconset || exit 1
mkdir -p InputMethodHinter.app/Contents/Resources || exit 1
perl -E '
    for (qw/16 32 48 128 256 512/) {
        system qq{sips -s format png -z $_ $_ logo.svg -o icon.iconset/icon_${_}x${_}.png};
        $x = $_ * 2;
        system qq{sips -s format png -z $x $x logo.svg -o icon.iconset/icon_${_}x${_}\@2x.png};
    }
' || exit 1
iconutil -c icns icon.iconset -o InputMethodHinter.app/Contents/Resources/InputMethodHinter.icns || exit 1
rm -rf icon.iconset
