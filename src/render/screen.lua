local layout = require("render.layout")

local screen = {}

local function draw_centered_line(target, y, text, text_color, background_color)
  local width = target.getSize()
  local x = layout.center_x(width, text)

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
  local rows = layout.home_rows(height)

  screen.clear(target, body.background)
  draw_centered_line(target, rows.title_y, body.title, body.title_color, body.background)
  draw_centered_line(target, rows.body_y, body.message, body.text_color, body.background)
end

function screen.render_footer(target, footer)
  local _, height = target.getSize()

  screen.clear(target, footer.background)
  draw_centered_line(target, height, footer.text, footer.text_color, footer.background)
end

return screen
