# Mjolnir Window Hints Module

Provides a fancy method of window switching for [Mjolnir](http://mjolnir.io).
Pressing a shortcut brings up "hints" which are app icons with a letter,
typing that letter focuses the corresponding window.

Currently it is in a very hacky state, it works for me but is not packaged
for use by others.

## Installation

You can install from luarocks by running the command below. You'll need to install Mjolnir and luarocks beforehand.

    luarocks install mjolnir.th.hints

You can also install from source. You'll need to install Mjolnir
and possibly moonrocks (`luarocks install --server=http://rocks.moonscript.org moonrocks`).

Then just run `luarocks make` in a clone of this git repo and it should install.

## Usage

Bind the function `mjolnir.th.hints.windowHints` in your `init.lua` to a key like this:

```lua
local hints = require "mjolnir.th.hints"
hotkey.bind({"cmd"},"e",hints.windowHints)
```

By default, the hint keys used are: `A O E U I D H T N S P G M W V J K X B Y F`. To customize the hint keys, change the `hints.HINTCHARS` value to the prefered keys before declaring any bindings:

```lua
local hints = require "mjolnir.th.hints"
hints.HINTCHARS = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}
```

You can also use `hints.appHints` to switch between windows in an app:

```lua
-- This switches between windows of the focused app
hotkey.bind({"ctrl","cmd"},"j",function() hints.appHints(window.focusedwindow():application()) end)

-- You can also use this with appfinder to switch to windows of a specific app
local appfinder = require "mjolnir.cmsj.appfinder"
hotkey.bind({"ctrl","cmd"},"k",function() hints.appHints(appfinder.app_from_name("Emacs")) end)
```

## Screenshot

![Screenshot](http://i.imgur.com/ktLgBWO.png)

Hints are centered on the window they will switch to and have a unique key.

Note that the hints still show for hidden windows, this means you can switch
to ANY currently open window in 2 key strokes.

Also note the vertical line of hints in the center, these are all maximized
windows but the hints are spread out so they don't collide.

![App switching](http://i.imgur.com/Fb1a0T0.png)

You can also switch windows within an app, in this case the window titles are also shown.
