local preset = {}

-- Theme tokens
preset.tokens = {
  background = colors.black,
  text = colors.white,
  title = colors.cyan,
  muted = colors.lightGray,
  accent = colors.magenta,
  border = colors.gray,
  success = colors.lime,
  warning = colors.yellow,
  error = colors.red,
}

preset.text_scale = 1.0

-- Template structure
preset.home = {
  lines = {
    { text_key = "title", align = "center", color_token = "title" },
    { text_key = "body", align = "center", color_token = "text" },
  },
  footer = {
    text_key = "footer",
    align = "left",
    color_token = "muted",
  },
  footer_enabled = true,
  footer_height = 1,
}

return preset
