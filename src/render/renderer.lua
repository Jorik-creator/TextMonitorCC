local layout = require("render.layout")
local screen = require("render.screen")

local renderer = {}

local function validate_assets(assets)
  if type(assets) ~= "table" then
    return nil, "invalid render assets"
  end
  if type(assets.preset) ~= "table" or type(assets.preset.tokens) ~= "table" then
    return nil, "missing preset tokens"
  end
  if type(assets.preset.home) ~= "table" then
    return nil, "missing preset home template"
  end
  if type(assets.locale) ~= "table" or type(assets.locale.strings) ~= "table" then
    return nil, "missing locale strings"
  end
  return assets
end

local function create_regions(target, dimensions, template)
  local r = layout.home_regions(dimensions.width, dimensions.height, template)
  return {
    body = window.create(target, r.body.x, r.body.y, r.body.width, r.body.height, true),
    footer = r.footer and window.create(target, r.footer.x, r.footer.y, r.footer.width, r.footer.height, true) or nil,
  }
end

local function build_body_lines(template_home, strings, tokens)
  local lines = {}
  for i = 1, #template_home.lines do
    local c = template_home.lines[i]
    local text = strings[c.text_key]
    local text_lines = layout.split_lines(text)
    for _, line_text in ipairs(text_lines) do
      table.insert(lines, { text = line_text, align = c.align, color = tokens[c.color_token] })
    end
  end
  return lines
end

local function create_home_view_model(dimensions, assets)
  local strings = assets.locale.strings.home
  local tokens = assets.preset.tokens
  local home = assets.preset.home
  local view_model = {
    width = dimensions.width,
    height = dimensions.height,
    background = tokens.background,
    body = { lines = build_body_lines(home, strings, tokens), background = tokens.background },
  }
  if home.footer_enabled and home.footer then
    local f = home.footer
    local footer_text = strings[f.text_key]
    local footer_lines = layout.split_lines(footer_text)
    view_model.footer = {
      lines = footer_lines,
      align = f.align,
      color = tokens[f.color_token],
      background = tokens.background,
    }
  end
  return view_model
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
  local dimensions = { width = monitor_state.width, height = monitor_state.height }
  local regions = create_regions(monitor_state.monitor, dimensions, valid_assets.preset.home)
  local view_model = create_home_view_model(dimensions, valid_assets)
  screen.clear(monitor_state.monitor, view_model.background)
  screen.render_home_body(regions.body, view_model.body)
  if regions.footer and view_model.footer then
    screen.render_footer(regions.footer, view_model.footer)
  end
  return true
end

return renderer
