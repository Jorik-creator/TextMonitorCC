local template = {}

template.home = {
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

return template
