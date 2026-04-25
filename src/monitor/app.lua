local selector = require("config.selector")
local monitor_selector = require("monitor.selector")
local preset_loader = require("presets.loader")
local locale_loader = require("locales")
local server_module = require("monitor.server")
local client_module = require("monitor.client")

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

function app.run(args)
  -- Parse arguments or show selector
  local config = {}

  if args and args[1] then
    -- Command line mode: mode [locale] [preset]
    -- Or: server/client [locale] [preset]
    config.mode = args[1]
    config.locale = args[2] or "en"
    config.preset = args[3] or "default"
  else
    -- Interactive mode: show all selectors
    config.mode = selector.select_mode()
    config.locale = selector.select_locale()
    config.preset = selector.select_preset()
  end

  -- Load assets
  local assets, assets_error = load_assets({
    locale = config.locale,
    preset = config.preset,
  })

  if not assets then
    return false, assets_error
  end

  if config.mode == "server" then
    return app.run_server(config, assets)
  elseif config.mode == "client" then
    return app.run_client(config, assets)
  else
    return false, "unknown mode: " .. tostring(config.mode)
  end
end

function app.run_server(config, assets)
  -- Server needs to select which monitors to use
  print()
  print("Select monitors for server display:")

  local monitor_states, monitor_error = monitor_selector.select({
    scale = assets.preset.text_scale,
  })

  if not monitor_states then
    return false, monitor_error
  end

  print()
  print("Selected " .. #monitor_states .. " monitor(s) for server")

  return server_module.start(config, monitor_states)
end

function app.run_client(config, assets)
  -- Client needs a single monitor
  print()
  print("Select monitor for client display:")

  local monitor_states, monitor_error = monitor_selector.select({
    scale = assets.preset.text_scale,
  })

  if not monitor_states then
    return false, monitor_error
  end

  if #monitor_states > 1 then
    print("Client mode only supports one monitor. Using first selected.")
  end

  local monitor_state = monitor_states[1]

  print()
  print("Starting client mode...")
  print("Computer ID: " .. os.getComputerID())
  print()

  return client_module.start(config, monitor_state)
end

return app