local time = {}

function time.get()
  local h = os.time()
  local hh = math.floor(h) % 24
  local mm = math.floor((h % 1) * 60)
  return string.format("%02d:%02d:%02d", hh, mm)
end

return time