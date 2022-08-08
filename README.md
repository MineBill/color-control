# Color Control
Color Control is way to allow you to change your Firefox theme and dark preference using the cli.

Changing to dark/light is as simple as:
```shell
$ echo "dark" | nc -w 0 -U $XDG_RUNTIME_DIR/colorchange.socket
```

## Installation
After installing the extension two additional steps need to be taken:
- Build `middleman.zig` with `$ zig build-exe middleman.zig -O ReleaseSafe` or download it from the releases page
- Copy `color_control_middleman.json` to `$HOME/.mozilla/native-messaging-hosts` and change `path`(has to be absolute) to point to the middleman executable
