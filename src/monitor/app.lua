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
  local config = {}

  if args and args[1] then
    -- Command line mode: mode [server_id] [locale] [preset]
    -- Or: mode [locale] [preset] for server
    config.mode = args[1]
    config.locale = args[2] or "en"
    config.preset = args[3] or "default"

    -- For client mode, args[2] can be server_id
    if config.mode == "client" and args[2] and not string.find(args[2], "^%d+$") then
      -- If args[2] is not a number, treat as locale
      config.locale = args[2] or "en"
      config.preset = args[3] or "default"
      config.server_id = nil
    else
      config.server_id = nil
    end

    -- Check if second arg is a number (server_id)
    if config.mode == "client" and args[2] then
      local sid = tonumber(args[2])
      if sid then
        config.server_id = sid
        config.locale = args[3] or "en"
        config.preset = args[4] or "default"
      end
    end
  else
    -- Interactive mode
    config.mode = selector.select_mode()
    config.locale = selector.select_locale()
    config.preset = selector.select_preset()
  end

  if config.mode == "server" then
    -- Server needs assets for rendering
    local assets, assets_error = load_assets({
      locale = config.locale,
      preset = config.preset,
    })
    if not assets then
      return false, assets_error
    end
    return app.run_server(config, assets)
  elseif config.mode == "client" then
    -- Client needs only monitor selection, no locale/preset
    config.scale = 1
    return app.run_client(config)
  else
    return false, "unknown mode: " .. tostring(config.mode)
  end
end

function app.run_server(config, assets)
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

function app.run_client(config)
  print()

  local monitor_states, monitor_error = monitor_selector.select({
    scale = config.scale or 1,
  })

  if not monitor_states then
    return false, monitor_error
  end

  if #monitor_states > 1 then
    print("Using first selected monitor.")
  end

  local monitor_state = monitor_states[1]

  print()
  print("Computer ID: " .. os.getComputerID())
  print()

  return client_module.start(config, monitor_state)
end

return app