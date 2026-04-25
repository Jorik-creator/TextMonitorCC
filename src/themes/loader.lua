local loader = {}

local REQUIRED_TOKENS = {
  "background",
  "text",
  "title",
  "muted",
  "accent",
  "border",
  "success",
  "warning",
  "error",
}

local function is_color_token_map(tokens)
  if type(tokens) ~= "table" then
    return false
  end

  for _, key in ipairs(REQUIRED_TOKENS) do
    if type(tokens[key]) ~= "number" then
      return false
    end
  end

  return true
end

local function is_valid_text_scale(scale)
  if type(scale) ~= "number" then
    return false
  end

  return scale >= 0.5 and scale <= 5.0 and scale * 2 == math.floor(scale * 2)
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

  if not is_valid_text_scale(theme.text_scale) then
    return nil, "invalid theme text_scale: " .. module_name
  end

  return theme
end

return loader
