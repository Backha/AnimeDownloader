remove_illegal_chars = false
replace_illegal_chars = true

local maxnamelen = 35
local animelanguage = Language.English
local episodelanguage = Language.English
local spacechar = " "
local allow_unofficial = true

-- Determine the anime name using titles from AniDB for the folder name
local foldername = anime.MainTitle or anime.preferredname

-- Determine the anime name for the file name
local animename = anime.MainTitle or anime.preferredname

-- Iterate through titles to find the short title and check if it's in Latin characters
local titles = anime.titles or {}
local shortname = nil
for _, title in ipairs(titles) do
  if title.type == "Short" and title.name:match("%a") then
    shortname = title.name
    break
  end
end

-- Use the short name if available for the file name
if shortname then
  animename = shortname
end

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

-- Safely determine the year from AirDate
local animeyear = ""
if anime.airdate and anime.airdate.year then
  animeyear = anime.airdate.year
end

-- Update the folder name with the year if year is not already in the name
if animeyear ~= "" and not foldername:find("%(%d+%)") then
  foldername = foldername .. " (" .. animeyear .. ")"
end

local namelist = {
  animename:truncate(maxnamelen),
  "-",
  episodenumber,
  episodename:truncate(maxnamelen),
}

filename = table.concat(namelist, " "):cleanspaces(spacechar)
subfolder = { foldername }
