# textmonitorcc

CC:Tweaked project for displaying styled text on monitors with live addons.

## project layout

```
src/
├── main.lua          → entrypoint
├── addons/          → %addon% placeholders
│   ├── init.lua     → replace engine
│   ├── time.lua     → %time% current time
│   ├── timer.lua    → %timer:X% countdown
│   └── uptime.lua   → %uptime% computer uptime
├── monitor/         → app, discovery, selector, manager, server, client, modem
├── render/          → renderer, screen, layout
├── presets/         → loader, default, minimal (tokens + template)
├── locales/         → loader, en, ru, alphabet/ru
└── config/          → selector (interactive mode picker)
```

## usage

```lua
-- interactive: pick mode, locale and preset via menu
shell.run("src/main.lua")

-- server: display text on attached monitors, broadcast to clients
shell.run("src/main.lua", "server", "en", "default")
shell.run("src/main.lua", "server", "ru", "minimal")

-- client: receive and display data from a server computer
shell.run("src/main.lua", "client", 42)
```

`locale` defaults to `en`, `preset` defaults to `default` if omitted.

## server / client

The server renders text on its own monitors and broadcasts the screen data to
all connected clients every second. Addons (`%time%`, `%uptime%`, etc.) are
resolved server-side — all displays stay in sync.

Clients pick one monitor and receive render data over rednet. No locale or
preset needed on the client side.

**Protocol:** `textmonitor`  
**Server ID:** `os.getComputerID()`

Client actions sent to server:

| Action | Description |
|--------|-------------|
| `discover` | Find available servers; server replies with `status` |
| `connect` | Register as a client; server replies with `ack` |
| `disconnect` | Unregister from server |
| `status` | Request current client count |

Server broadcasts `{ action = "render", screen = { ... } }` to all connected
clients on every update tick (1 s) and on manual Enter press.

## addons

Placeholders in locale strings get replaced on every render:

| Placeholder | Output | Example |
|-------------|--------|---------|
| `%time%` | Current time (H:MM) | `14:30` |
| `%timer:X%` | Countdown from X | `%timer:300%` → `4:59` |
| `%uptime%` | Computer uptime | `1:23:45` or `5:02` |

Timer accepts: seconds (`300`), minutes (`5m`), or both (`2m30s`).

Example locale strings:
```lua
strings = {
  footer = "Started: %uptime% | Time: %time%",
  timer_line = "%timer:300% remaining",
}
```

## preset structure

```lua
preset = {
  tokens = {
    background = colors.black,
    text       = colors.white,
    title      = colors.cyan,
    muted      = colors.lightGray,
    accent     = colors.magenta,
    border     = colors.gray,
    success    = colors.lime,
    warning    = colors.yellow,
    error      = colors.red,
  },
  text_scale = 1.0,
  home = {
    lines = {
      { text_key = "title", align = "center", color_token = "title" },
      { text_key = "body",  align = "center", color_token = "text"  },
    },
    footer = {
      text_key    = "footer",
      align       = "left",
      color_token = "muted",
    },
    footer_enabled = true,
    footer_height  = 1,
  },
}
```

## creating an addon

```lua
-- src/addons/myaddon.lua
local myaddon = {}

-- parametric addon (%myaddon:param%)
function myaddon.create(param)
  return function(_)
    return "computed: " .. param
  end
end

-- or simple addon (%myaddon%)
function myaddon.get()
  return "static value"
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
- Naming: lowercase with dots (`require("monitor.app")`)
- APIs: `require`, return table with functions
- No external dependencies
