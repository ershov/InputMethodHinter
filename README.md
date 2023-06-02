# MacOS Input Method Hinter

Hint the current input method where and when you need it.

<!--![Logo](https://upload.wikimedia.org/wikipedia/commons/4/4e/%E6%96%87-order.gif)-->
<!--![Logo](https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/%E6%96%87-order.gif/120px-%E6%96%87-order.gif)-->
![Logo](https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/OOjs_UI_icon_language-ltr.svg/240px-OOjs_UI_icon_language-ltr.svg.png)

## Problem Statement

MacOS is a great OS for everyday life. Unfortunately, it's notorious for
screwing up per document/window keyboard layouts.
In MacOS 13 (Ventura) the bright and colorful flags indicators were changed to
unremarkable grayish symbols which are hard to spot in the system menu.
Oftentimes, you only find out the language you use once you start typing.

What **MacOS Input Method Hinter** does is augmenting the system language
indicator with one that appears next to the mouse cursor at times when the
keyboard layout is switched or when the you are activating a text input.

Pressing `Fn+Ctrl` will flash the current input language at any time.

DISCLAIMER: I tried various methods of detecting the text cursor locations
but it seems like none of the methods work reliably in 2023.
If you know how to detect the text cursor screen location, please let me know.

## Screencasts

[![Light Theme](https://img.youtube.com/vi/XJppp_UX2UE/0.jpg)](https://youtu.be/XJppp_UX2UE)

[![Dark Theme](https://img.youtube.com/vi/KtnMjfMwhkc/0.jpg)](https://youtu.be/KtnMjfMwhkc)

## Installing

Either method requires enabling the app in the System Settings Accessibility list.

### From Release

1. Download from [Releases](https://github.com/ershov/InputMethodHinter/releases)
2. Unzip and drag to `/Applications`.

### Building from Source

1. Check out the source
```
$ git clone https://github.com/ershov/InputMethodHinter.git
```
2. Build
```
$ cd InputMethodHinter
$ make
```
3. Copy executables `InputMethodHinter-app` and `InputMethodHinter-console`
to your `$PATH`.
4. `open .` and copy the the app to `/Applications`

NOTE that in order to be able to use the app normally you'll need to self-sign it.
