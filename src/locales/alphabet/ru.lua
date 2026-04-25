local alphabet = {}

-- Mapping of Russian Cyrillic letters to ComputerCraft escape sequences.
-- These byte values correspond to the custom font glyphs available in CC:Tweaked.
alphabet.map = {
  -- Uppercase (А-Я)
  ["А"] = "\191", ["Б"] = "\192", ["В"] = "\193", ["Г"] = "\194",
  ["Д"] = "\195", ["Е"] = "\196", ["Ё"] = "\197", ["Ж"] = "\198",
  ["З"] = "\199", ["И"] = "\200", ["Й"] = "\201", ["К"] = "\202",
  ["Л"] = "\203", ["М"] = "\204", ["Н"] = "\205", ["О"] = "\206",
  ["П"] = "\207", ["Р"] = "\208", ["С"] = "\209", ["Т"] = "\210",
  ["У"] = "\211", ["Ф"] = "\212", ["Х"] = "\213", ["Ц"] = "\214",
  ["Ч"] = "\215", ["Ш"] = "\216", ["Щ"] = "\217", ["Ъ"] = "\218",
  ["Ы"] = "\219", ["Ь"] = "\220", ["Э"] = "\221", ["Ю"] = "\222",
  ["Я"] = "\223",
  -- Lowercase (а-я)
  ["а"] = "\224", ["б"] = "\225", ["в"] = "\226", ["г"] = "\227",
  ["д"] = "\228", ["е"] = "\229", ["ё"] = "\230", ["ж"] = "\231",
  ["з"] = "\232", ["и"] = "\233", ["й"] = "\234", ["к"] = "\235",
  ["л"] = "\236", ["м"] = "\237", ["н"] = "\238", ["о"] = "\239",
  ["п"] = "\240", ["р"] = "\241", ["с"] = "\242", ["т"] = "\243",
  ["у"] = "\244", ["ф"] = "\245", ["х"] = "\246", ["ц"] = "\247",
  ["ч"] = "\248", ["ш"] = "\249", ["щ"] = "\250", ["ъ"] = "\251",
  ["ы"] = "\252", ["ь"] = "\253", ["э"] = "\254", ["ю"] = "\255",
  ["я"] = "\13",
}

-- Replace all Cyrillic characters in text with their escape sequences.
-- Uses UTF-8 aware matching: each multi-byte sequence is captured as one unit.
-- Non-mapped characters are left unchanged.
function alphabet.replace(text)
  if type(text) ~= "string" then
    return text
  end

  return (text:gsub("[\194-\244][\128-\191]*", function(char)
    return alphabet.map[char] or char
  end))
end

return alphabet
