local manager = require("monitor.manager")
local renderer = require("render.renderer")
local preset_loader = require("presets.loader")
local locale_loader = require("locales")
local selector = require("config.selector")
local modem = require("monitor.modem")

local app = {}

local UPDATE_INTERVAL = 1

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

local function render_all(monitor_states, assets)
  for _, state in ipairs(monitor_states) do
    local ok, err = renderer.render_home(state, assets)
    if not ok then
      return false, err
    end
  end
  return true
end

-- Main loop with timer and optional rednet events
local function run_loop(monitor_states, assets, modem_side)
  os.startTimer(UPDATE_INTERVAL)

  while true do
    local event, p1, p2 = os.pullEvent()

    if event == "timer" then
      render_all(monitor_states, assets)
      os.startTimer(UPDATE_INTERVAL)

    elseif event == "rednet_message" and modem_side then
      local sender_id, message = p1, p2

      if type(message) == "table" and message.action == "render" then
        local new_assets = load_assets({
          locale = message.locale or "en",
          preset = message.preset or "default",
        })

        if new_assets then
          render_all(monitor_states, new_assets)
          assets = new_assets
          rednet.send(sender_id, { status = "ok" }, "textmonitor")
        end
      end
    end
  end
end

function app.run(args)
  local selection

  if args and args[1] then
    selection = {
      locale = args[1],
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

  -- Try to open modem
  local has_modem, modem_error = modem.open()

  if has_modem then
    print("Wireless server active (protocol: textmonitor)")
    print("Computer ID: " .. os.getComputerID())
    render_all(monitor_states, assets)
    return run_loop(monitor_states, assets, has_modem)
  end

  -- No modem: run loop anyway
  render_all(monitor_states, assets)
  return run_loop(monitor_states, assets, nil)
end

return app