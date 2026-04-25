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

local VALID_ALIGNMENTS = {
  left = true,
  center = true,
  right = true,
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

local function is_valid_line(line)
  if type(line) ~= "table" then
    return false
  end

  return type(line.text_key) == "string"
    and VALID_ALIGNMENTS[line.align] ~= nil
    and type(line.color_token) == "string"
end

local function is_valid_lines(lines)
  if type(lines) ~= "table" then
    return false
  end

  for i = 1, #lines do
    if not is_valid_line(lines[i]) then
      return false
    end
  end

  return true
end

local function is_valid_footer(footer)
  if footer == nil then
    return true
  end

  if type(footer) ~= "table" then
    return false
  end

  return type(footer.text_key) == "string"
    and VALID_ALIGNMENTS[footer.align] ~= nil
    and type(footer.color_token) == "string"
end

local function is_valid_home_template(home)
  if type(home) ~= "table" then
    return false
  end

  return is_valid_lines(home.lines)
    and type(home.footer_enabled) == "boolean"
    and type(home.footer_height) == "number"
    and is_valid_footer(home.footer)
end

function loader.load(name)
  if name ~= nil and type(name) ~= "string" then
    return nil, "invalid preset name"
  end

  local module_name = "presets." .. (name or "default")
  local ok, preset = pcall(require, module_name)

  if not ok then
    return nil, "failed to load preset module: " .. module_name
  end

  if type(preset) ~= "table" then
    return nil, "invalid preset module: " .. module_name
  end

  if not is_color_token_map(preset.tokens) then
    return nil, "invalid preset tokens: " .. module_name
  end

  if not is_valid_text_scale(preset.text_scale) then
    return nil, "invalid preset text_scale: " .. module_name
  end

  if not is_valid_home_template(preset.home) then
    return nil, "invalid preset home template: " .. module_name
  end

  return preset
end

return loader
