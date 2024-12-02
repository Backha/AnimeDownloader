remove_illegal_chars = false
replace_illegal_chars = true

local maxnamelen = 35
local animelanguage = Language.English
local episodelanguage = Language.English
local spacechar = " "

-- Determine the anime name using titles
local titles = anime.titles
local shortname = nil

-- Search for a short title
for _, title in ipairs(titles) do
  if title.type == TitleType.Short then
    shortname = title.name
    break
  end
end

-- Use the short name if available, otherwise use the main or preferred name
local animename = shortname or anime:getname(animelanguage) or anime.preferredname

local episodename = ""
local engepname = episode:getname(Language.English) or ""
local episodenumber = ""
-- If the anime is not a movie, add an episode number/name
if anime.type ~= AnimeType.Movie or not engepname:find("^Complete Movie") then
  local fileversion = ""
  if (file.anidb and file.anidb.version > 1) then
    fileversion = "v" .. file.anidb.version
  end
  -- Padding is determined from the number of episodes of the same type in the anime (#tostring() gives the number of digits required, e.g. 10 eps -> 2 digits)
  -- Padding is at least 2 digits
  local epnumpadding = math.max(#tostring(anime.episodecounts[episode.type]), 2)
  episodenumber = episode_numbers(epnumpadding) .. fileversion

  -- If this file is associated with a single episode and the episode doesn't have a generic name, then add the episode name
  if #episodes == 1 and not engepname:find("^Episode") and not engepname:find("^OVA") then
    episodename = episode:getname(episodelanguage) or ""
  end
end

-- If it's a movie, use the anime name as the episode name
if anime.type == AnimeType.Movie then
  episodename = ""
end

local namelist = {
  animename:truncate(maxnamelen),
  episodenumber,
  episodename:truncate(maxnamelen),
}

filename = table.concat(namelist, " "):cleanspaces(spacechar)
subfolder = { animename .. " (" .. anime.year .. ")" }
