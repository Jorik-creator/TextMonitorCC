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
| `%time%` | Current time (HH:MM:SS) | `14:30:45` |
| `%timer:X%` | Countdown from X (seconds) | `%timer:300%` → `4:59` |
| `%uptime%` | Computer uptime (H:MM:SS) | `1:23:45` |

Timer accepts: seconds (`300`), minutes (`5m`), or both (`2m30s`).

Example locale strings:
```lua
strings = {
  footer = "Started: %uptime% | Time: %time%",
  timer_line = "%timer:300% remaining",
}
```

## rednet server

When wireless modem present, accepts commands:

```lua
rednet.send(computer_id, {
  action = "render",
  locale = "en",
  preset = "default",
}, "textmonitor")
```

Server IP: `os.getComputerID()`
Protocol: `textmonitor`

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