local manager = require("monitor.manager")
local renderer = require("render.renderer")
local preset_loader = require("presets.loader")
local locale_loader = require("locales")
local selector = require("config.selector")

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

  local monitor_state, monitor_error = manager.attach(config)

  if not monitor_state then
    return false, monitor_error
  end

  return renderer.render_home(monitor_state, assets)
end

return app
