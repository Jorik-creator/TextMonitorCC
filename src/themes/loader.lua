local loader = {}

local function is_color_token_map(tokens)
  if type(tokens) ~= "table" then
    return false
  end

  return type(tokens.background) == "number"
    and type(tokens.text) == "number"
    and type(tokens.title) == "number"
    and type(tokens.muted) == "number"
end

function loader.load(name)
  if name ~= nil and type(name) ~= "string" then
    return nil, "invalid theme name"
  end

  local module_name = "themes." .. (name or "default")
  local ok, theme = pcall(require, module_name)

  if not ok then
    return nil, "failed to load theme module: " .. module_name
  end

  if type(theme) ~= "table" or not is_color_token_map(theme.tokens) then
    return nil, "invalid theme module: " .. module_name
  end

  return theme
end

return loader
