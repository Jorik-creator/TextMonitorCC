local layout = {}

local function clamp(value, minimum)
  if value < minimum then
    return minimum
  end

  return value
end

function layout.center_x(width, text)
  local text_width = #text
  local start_x = math.floor((width - text_width) / 2) + 1

  return clamp(start_x, 1)
end

function layout.home_rows(height)
  local title_y = math.max(1, math.floor(height / 2) - 1)
  local body_y = math.min(height, title_y + 2)

  return {
    title_y = title_y,
    body_y = body_y,
  }
end

function layout.home_regions(width, height, template)
  local footer_enabled = template.footer_enabled
  local footer_height = footer_enabled and math.max(1, template.footer_height) or 0
  local body_height = math.max(1, height - footer_height)

  return {
    body = {
      x = 1,
      y = 1,
      width = width,
      height = body_height,
    },
    footer = footer_enabled and {
      x = 1,
      y = height - footer_height + 1,
      width = width,
      height = footer_height,
    } or nil,
  }
end

return layout
