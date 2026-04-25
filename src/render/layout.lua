local layout = {}

local function clamp(value, minimum)
  if value < minimum then
    return minimum
  end

  return value
end

function layout.align_x(width, text, alignment)
  local text_width = #text

  if alignment == "right" then
    return clamp(width - text_width + 1, 1)
  elseif alignment == "center" then
    return clamp(math.floor((width - text_width) / 2) + 1, 1)
  else
    return 1
  end
end

function layout.center_x(width, text)
  return layout.align_x(width, text, "center")
end

function layout.home_line_rows(height, line_count)
  local start_y = math.max(1, math.floor(height / 2) - math.floor(line_count / 2) + 1)
  local rows = {}

  for i = 1, line_count do
    rows[i] = start_y + i - 1
  end

  return rows
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

-- Split text by newline characters into an array of lines.
-- Preserves empty lines between consecutive newlines.
function layout.split_lines(text)
  if type(text) ~= "string" then
    return { tostring(text) }
  end

  local lines = {}
  local start = 1

  while true do
    local pos = text:find("\n", start, true)

    if not pos then
      table.insert(lines, text:sub(start))
      break
    end

    table.insert(lines, text:sub(start, pos - 1))
    start = pos + 1
  end

  return lines
end

return layout
