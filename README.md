# findphone — a stoandl extension boilerplate

**Find My Phone for the Pebble.** Open the watchapp, press **UP** to make your computer ring, **DOWN**
to stop. It's a watchapp (not a notification) because PebbleOS only offers a notification's action menu
while it's on screen — a watchapp's buttons work whenever you open it.

This doubles as a **working boilerplate** for [stoandl](https://github.com/yoxcu/stoandl) extensions: a
tiny watchapp that talks to a host-side companion over AppMessage, with the companion driven by
stoandl's extension protocol. Fork it to build your own watch↔host companion.

## How it works

```
 Pebble watchapp (src/c/findphone.c)            host companion (findphone.py)
   UP  → AppMessage {0: uint8 1}  ──────────▶   on_app_message → play a sound
   DOWN→ AppMessage {0: uint8 2}  ──────────▶   on_app_message → stop
```

- The watchapp sends a single `uint8` at AppMessage key `0` (`1` = ring, `2` = stop).
- `findphone.py` is a stoandl **extension**: a child process stoandl spawns that speaks a small
  JSON-RPC-over-stdio protocol. It `register_app(UUID)`s, receives `on_app_message`, and runs a sound
  player (`paplay`/`pw-play`/`ffplay`/`aplay`) in a loop until stopped.
- `stoandl_ext.py` is the (vendored) helper that wraps that protocol — see
  [stoandl/docs/extensions.md](https://github.com/yoxcu/stoandl/blob/main/docs/extensions.md).

App UUID: `de72f1d0-1111-4a17-9a6b-0123456789ab` (in `package.json`; the companion's `APP_UUID` must match).

## What you need

- **The Pebble SDK** to build the watchapp — install it from <https://developer.repebble.com/sdk/>
  (the `pebble` command-line tool). Check with `pebble --version`.
- **Python 3** on the machine running stoandl (for the companion).
- **stoandl** running, with a paired watch.

## Build, package, install

```sh
pebble build                     # compiles the watchapp → build/findphone.pbw
./package.sh                     # builds + bundles findphone.tar.gz (watchapp + companion)
stoandl ext install findphone.tar.gz   # extracts to ~/.config/stoandl/ext/findphone/, sideloads the
                                       # .pbw onto the watch, enables + starts it — no daemon restart
```

Then open **Find My Phone** on the watch → **UP** rings, **DOWN** stops.

(You can also install the watchapp by hand for testing: `pebble install --phone <watch-ip>`, or
`stoandl sideload build/findphone.pbw`.)

Manage it live: `stoandl ext list | disable findphone | enable findphone | restart findphone | uninstall findphone`.

Optional: set the ring sound in the extension's own config, `~/.config/stoandl/ext/findphone/config`
(copy the bundled `config.example`), then `stoandl ext restart findphone`:

```ini
sound = /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
```

(Setting `extension.findphone.sound` in `stoandl.conf` still works as an override.)

## Files

| file | what |
|------|------|
| `src/c/findphone.c`, `wscript`, `package.json` | the Pebble watchapp |
| `findphone.py` | the host companion (the stoandl extension) |
| `stoandl_ext.py` | vendored stoandl extension helper |
| `config.example` | optional per-extension config template (the ring `sound`) |
| `package.sh` | build + bundle into `findphone.tar.gz` |

## Fork it for your own extension

Rename the dir/UUID/`package.json`, change the watchapp UI and the `on_app_message` handler, and you
have a watch↔host companion. For notification-only extensions (Matrix/SMS/…, no watchapp), drop the
watchapp and use `ext.notify(...)` + `ext.on_reply` instead — see the stoandl docs and
`examples/extensions/` in the stoandl repo.

## License

GPLv3, same as [stoandl](https://github.com/yoxcu/stoandl). See [LICENSE](LICENSE).
