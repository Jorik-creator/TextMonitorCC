local time = {}

--- Returns current time in HH:MM:SS format.
-- @return (string) Formatted time "HH:MM:SS"
function time.get()
  -- os.time() returns hours as decimal (e.g., 14.5 = 14:30)
  local h = os.time()
  local hh = math.floor(h) % 24
  local mm = math.floor((h % 1) * 60)
  local ss = math.floor(((h % 1) * 60 % 1) * 60)
  return string.format("%02d:%02d:%02d", hh, mm, ss)
end

return time