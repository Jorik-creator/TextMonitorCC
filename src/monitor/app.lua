local manager = require("monitor.manager")
local renderer = require("render.renderer")
local preset_loader = require("presets.loader")
local locale_loader = require("locales")
local selector = require("config.selector")
local modem = require("monitor.modem")

local app = {}

local function load_assets(config)
  local preset, preset_error = preset_loader.load(config.preset)

  if not preset then
    return nil, preset_error
  end

  local locale, locale_error = locale_loader.load(config.locale)

  if not locale then
    return nil, locale_error
  end

  return {
    preset = preset,
    locale = locale,
  }
end

-- Renders on every monitor state in the list.
local function render_all(monitor_states, assets)
  for _, state in ipairs(monitor_states) do
    local ok, err = renderer.render_home(state, assets)
    if not ok then
      return false, err
    end
  end
  return true
end

-- If a wireless modem is present, enters a rednet server loop.
-- Accepts { action="render", locale=..., preset=... } commands and re-renders all monitors.
-- Falls back to a single render-and-exit when no modem is found.
local function run_server(monitor_states, initial_assets)
  local modem_side, modem_error = modem.open()

  if not modem_side then
    -- No wireless modem attached — render once and exit normally.
    return render_all(monitor_states, initial_assets)
  end

  local ok, err = render_all(monitor_states, initial_assets)
  if not ok then
    modem.close(modem_side)
    return false, err
  end

  print("Wireless server active (protocol: textmonitor)")
  print("Computer ID: " .. tostring(os.getComputerID()))

  modem.listen(function(sender_id, command)
    if command.action == "render" then
      local assets, assets_error = load_assets({
        locale = command.locale or "en",
        preset = command.preset or "default",
      })

      if not assets then
        return { status = "error", message = assets_error }
      end

      local render_ok, render_error = render_all(monitor_states, assets)

      if not render_ok then
        return { status = "error", message = render_error }
      end

      return { status = "ok" }
    end
  end)

  modem.close(modem_side)
  return true
end

function app.run(args)
  local selection

  if args and args[1] then
    selection = {
      locale = args[1] or "en",
      preset = args[2] or "default",
    }
  else
    selection = selector.run()
  end

  local assets, assets_error = load_assets(selection)

  if not assets then
    return false, assets_error
  end

  local config = {
    scale = assets.preset.text_scale,
    preset = selection.preset,
    locale = selection.locale,
  }

  local monitor_states, monitor_error = manager.attach_all(config)

  if not monitor_states then
    return false, monitor_error
  end

  return run_server(monitor_states, assets)
end

return app
