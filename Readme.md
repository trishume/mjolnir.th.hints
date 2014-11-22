# Mjolnir Window Hints Module

Provides a fancy method of window switching for [Mjolnir](http://mjolnir.io).
Pressing a shortcut brings up "hints" which are app icons with a letter,
typing that letter focuses the corresponding window.

Currently it is in a very hacky state, it works for me but is not packaged
for use by others.

## Installation

Not on luarocks yet so you have to compile it yourself. You'll need to install Mjolnir
and possibly moonrocks (`luarocks install --server=http://rocks.moonscript.org moonrocks`).

Then just run `luarocks make` in a clone of this git repo and it should install.

## Usage

Bind the function `mjolnir.th.hints.windowHints` in your `init.lua` to a key like this:

```lua
local hints = require "mjolnir.th.hints"
hotkey.bind({"cmd"},"e",hints.windowHints)
```

## Screenshot

![Screenshot](http://i.imgur.com/ktLgBWO.jpg)

Hints are centered on the window they will switch to and have a unique key.

Note that the hints still show for hidden windows, this means you can switch
to ANY currently open window in 2 key strokes.

Also note the vertical line of hints in the center, these are all maximized
windows but the hints are spread out so they don't collide.
