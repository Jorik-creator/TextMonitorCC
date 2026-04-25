# textmonitorcc

Small CC:Tweaked starter project for showing styled text on an attached monitor.

## project layout

- `src/main.lua` — app entrypoint
- `src/monitor/` — monitor discovery and app bootstrap
- `src/render/` — pure layout and rendering helpers
- `src/themes/` — theme tokens
- `src/templates/` — reusable screen templates
- `src/locales/` — language tables
- `docs/` — architecture notes
- `examples/` — run notes and future examples

## quick start

1. Copy this project onto a CC:Tweaked computer.
2. Attach a monitor.
3. Run:

```lua
shell.run("src/main.lua")
```

The first version uses built-in CC:Tweaked APIs only: `peripheral`, monitor methods, `window`, `colors`, and small pure Lua modules.

## starter flow

`src/main.lua` loads `monitor.app`, finds a monitor, applies the default theme and template, and renders a simple welcome screen.

## notes

- naming stays lowercase
- modules keep one responsibility each
- built-in APIs are preferred over external UI frameworks for v1
