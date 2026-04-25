local time = {}

--- Returns Minecraft time in H:MM format.
-- @return (string) Minecraft time "H:MM"
function time.get()
  -- Minecraft time: 0 = sunrise, 6000 = noon, 12000 = sunset, 18000 = midnight
  -- 24000 ticks per day
  local t = os.time()
  local mtime = math.floor(t / 100) -- Convert to Minecraft "minutes" (0-240)
  local hh = math.floor(mtime / 60) -- Minecraft hours (0-4 per day, then repeats)
  local mm = mtime % 60             -- Minutes
  return string.format("%d:%02d", hh, mm)
end

return time