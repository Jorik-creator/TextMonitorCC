local layout = require("render.layout")

local screen = {}

-- Text arrives pre-transformed by the locale pipeline; draw_line is locale-agnostic.
local function draw_line(target, y, text, text_color, background_color, alignment)
  local width = target.getSize()
  local x = layout.align_x(width, text, alignment)

  target.setCursorPos(x, y)
  target.setTextColor(text_color)
  target.setBackgroundColor(background_color)
  target.write(text)
end

function screen.clear(target, background_color)
  target.setBackgroundColor(background_color)
  target.clear()
end

function screen.render_home_body(target, body)
  local _, height = target.getSize()
  local line_count = #body.lines
  local rows = layout.home_line_rows(height, line_count)

  screen.clear(target, body.background)

  for i = 1, line_count do
    local line = body.lines[i]
    draw_line(target, rows[i], line.text, line.color, body.background, line.align)
  end
end

function screen.render_footer(target, footer)
  local _, height = target.getSize()
  local line_count = #footer.lines
  local start_y = math.max(1, height - line_count + 1)

  screen.clear(target, footer.background)

  for i = 1, line_count do
    draw_line(target, start_y + i - 1, footer.lines[i], footer.color, footer.background, footer.align)
  end
end

return screen
