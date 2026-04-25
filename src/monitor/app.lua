local manager = require("monitor.manager")
local renderer = require("render.renderer")
local theme_loader = require("themes.loader")
local template_loader = require("templates.loader")
local locale_loader = require("locales")

local app = {}

local function create_config()
  return {
    scale = 1,
    theme = "default",
    template = "basic",
    locale = "en",
  }
end

local function load_assets(config)
  local theme, theme_error = theme_loader.load(config.theme)

  if not theme then
    return nil, theme_error
  end

  local template, template_error = template_loader.load(config.template)

  if not template then
    return nil, template_error
  end

  local locale, locale_error = locale_loader.load(config.locale)

  if not locale then
    return nil, locale_error
  end

  return {
    theme = theme,
    template = template,
    locale = locale,
  }
end

function app.run()
  local config = create_config()
  local monitor_state, monitor_error = manager.attach(config)

  if not monitor_state then
    return false, monitor_error
  end

  local assets, assets_error = load_assets(config)

  if not assets then
    return false, assets_error
  end

  return renderer.render_home(monitor_state, assets)
end

return app
