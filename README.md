# textmonitorcc

CC:Tweaked project for displaying styled text on monitors with live addons.

## project layout

```
src/
├── main.lua          → entrypoint
├── addons/          → %addon% placeholders
│   ├── init.lua     → replace engine
│   ├── time.lua    → %time% current time
│   ├── timer.lua   → %timer:X% countdown
│   └── uptime.lua  → %uptime% computer uptime
├── monitor/         → discovery, app, manager, modem (rednet server)
├── render/         → renderer, screen, layout
├── presets/         → loader, default, minimal (tokens + template)
└── locales/        → loader, en, ru, alphabet/ru
```

## usage

```lua
shell.run("src/main.lua")
shell.run("src/main.lua", "en", "default")
shell.run("src/main.lua", "ru", "minimal")
```

## addons

Placeholders in locale strings get replaced on render:

| Placeholder | Output | Example |
|-------------|--------|----------|
| `%time%` | Current time (HH:MM) | `14:30` |
| `%timer:X%` | Countdown from X (seconds) | `%timer:300%` → `4:59` |
| `%uptime%` | Computer uptime (H:MM:SS or M:SS) | `1:23:45` or `5:02` |

Timer accepts: seconds (`300`), minutes (`5m`), or both (`2m30s`).

Example locale strings:
```lua
strings = {
  footer = "Started: %uptime% | Time: %time%",
  timer_line = "%timer:300% remaining",
}
```

## rednet server / client

When a wireless modem is present, the server broadcasts rendered screen data to
connected clients every second. Clients resolve addons server-side — all monitors
stay in sync.

**Protocol:** `textmonitor`  
**Server ID:** `os.getComputerID()`

Supported actions (sent to server):

| Action | Description |
|--------|-------------|
| `discover` | Find available servers; server replies with `status` |
| `connect` | Register as a client; server replies with `ack` |
| `disconnect` | Unregister from server |
| `status` | Request current client count |

Server broadcasts `{ action = "render", screen = { ... } }` to all connected
clients on every update tick (1 s) and on manual Enter press.

## preset structure

```lua
preset = {
  tokens = {
    background = colors.black,
    text = colors.white,
    title = colors.cyan,
    muted = colors.lightGray,
    accent = colors.magenta,
    border = colors.gray,
    success = colors.lime,
    warning = colors.yellow,
    error = colors.red,
  },
  text_scale = 1.0,
  home = {
    lines = {
      { text_key = "title", align = "center", color_token = "title" },
      { text_key = "body", align = "center", color_token = "text" },
    },
    footer = {
      text_key = "footer",
      align = "left",
      color_token = "muted",
    },
    footer_enabled = true,
    footer_height = 1,
  },
}
```

## creating an addon

```lua
-- src/addons/myaddon.lua
local myaddon = {}

function myaddon.create(param)
  return function(_)
    -- param = everything after colon (e.g. "5m" from "%myaddon:5m%")
    return "some value"
  end
end

return myaddon
```

Register in `addons/init.lua`:
```lua
local myaddon = require("addons.myaddon")
registry.myaddon = myaddon
```

## development

- Modules: single responsibility
- Naming: lowercase with dots
- APIs: require, return table with functions
- No external dependencies