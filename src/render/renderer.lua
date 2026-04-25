local layout = require("render.layout")
local screen = require("render.screen")

local renderer = {}

local function validate_assets(assets)
  if type(assets) ~= "table" then
    return nil, "invalid render assets"
  end

  if type(assets.theme) ~= "table" or type(assets.theme.tokens) ~= "table" then
    return nil, "missing theme tokens"
  end

  if type(assets.template) ~= "table" or type(assets.template.home) ~= "table" then
    return nil, "missing home template"
  end

  if type(assets.locale) ~= "table" or type(assets.locale.strings) ~= "table" then
    return nil, "missing locale strings"
  end

  return assets
end

local function create_regions(target, dimensions, template)
  local regions = layout.home_regions(dimensions.width, dimensions.height, template)

  return {
    body = window.create(target, regions.body.x, regions.body.y, regions.body.width, regions.body.height, true),
    footer = regions.footer and window.create(target, regions.footer.x, regions.footer.y, regions.footer.width, regions.footer.height, true) or nil,
  }
end

local function create_home_view_model(dimensions, assets)
  local strings = assets.locale.strings.home
  local tokens = assets.theme.tokens
  local footer_enabled = assets.template.home.footer_enabled

  return {
    width = dimensions.width,
    height = dimensions.height,
    background = tokens.background,
    body = {
      title = strings.title,
      message = strings.body,
      title_color = tokens.title,
      text_color = tokens.text,
      background = tokens.background,
    },
    footer = footer_enabled and {
      text = strings.footer,
      text_color = tokens.muted,
      background = tokens.background,
    } or nil,
  }
end

function renderer.render_home(monitor_state, assets)
  if type(monitor_state) ~= "table"
    or type(monitor_state.monitor) ~= "table"
    or type(monitor_state.monitor.getSize) ~= "function" then
    return false, "invalid monitor state"
  end

  local valid_assets, assets_error = validate_assets(assets)

  if not valid_assets then
    return false, assets_error
  end

  local dimensions = {
    width = monitor_state.width,
    height = monitor_state.height,
  }
  local regions = create_regions(monitor_state.monitor, dimensions, valid_assets.template.home)
  local view_model = create_home_view_model(dimensions, valid_assets)

  screen.clear(monitor_state.monitor, view_model.background)
  screen.render_home_body(regions.body, view_model.body)

  if regions.footer and view_model.footer then
    screen.render_footer(regions.footer, view_model.footer)
  end

  return true
end

return renderer
