local preset = {}

-- Minimal theme: high contrast, no accent colors
preset.tokens = {
  background = colors.black,
  text = colors.white,
  title = colors.white,
  muted = colors.gray,
  accent = colors.white,
  border = colors.gray,
  success = colors.white,
  warning = colors.white,
  error = colors.white,
}

preset.text_scale = 1.0

-- Minimal template: title only, no footer
preset.home = {
  lines = {
    { text_key = "title", align = "center", color_token = "title" },
  },
  footer = nil,
  footer_enabled = false,
  footer_height = 0,
}

return preset
