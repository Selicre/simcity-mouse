# SimCity mouse patch

This patch adds minimal SNES mouse support to SimCity. Note that so far there is lots of jank and it's likely that moving around in places where that's not intended can crash or softlock your game.

# Usage

Use [asar](https://github.com/RPGHacker/asar) to patch the existing game:

`$ /path/to/asar main.asm game.sfc`

Make sure to connect the mouse to the second controller, as the primary controller is still used for most input.

# Known issues

* You can move the mouse inside menus, but it's purely visual and will be reset when you use the D-pad.
* Mouse buttons don't work.
* The targeted tile is not evident.
* The cursor position resets to origin occasionally.
* The framerate is way too low for comfortable use.

Pull requests welcome.
