local time = {}

--- Returns current time in HH:MM:SS format.
-- @return (string) Formatted time "HH:MM:SS"
function time.get()
  -- os.time() returns hours as decimal (14.5 = 14:30:00)
  local h = os.time()
  local total_seconds = math.floor(h * 3600 + 0.5) % 86400
  local hh = math.floor(total_seconds / 3600)
  local mm = math.floor((total_seconds % 3600) / 60)
  local ss = total_seconds % 60
  return string.format("%02d:%02d:%02d", hh, mm, ss)
end

return time