local L = AceLibrary("AceLocale-2.2"):new("FonzSummon")
 
L:RegisterTranslations("enUS", function() return {
    -- Addon commands
    ["SLASHCMD_LONG"] = "/fonzsummon",
    ["SLASHCMD_SHORT"] = "/fsm",
   
    -- Settings display
    ---[[
    ["|cffffff7f%s|r to reset or |cffffff7f%s|r to disable"] = true,
    ["Chat channel: SAY, PARTY, RAID, GROUP or a channel number"] = true,
    ["Chat channel: SAY, PARTY, RAID, GROUP, WHISPER "
      .."or a channel number"] = true,
    ["SAY, PARTY, RAID, GROUP, <channel number>"] = true,
    ["SAY, PARTY, RAID, GROUP, WHISPER, <channel number>"] = true,
   
    ["Received summon. Thank you {summoner}"] = true,
    ["Click to summon {target} to {zone}. Do not move when you click. [{shards} shards left]"] = true,
    ["Summoning you to {zone}"] = true,
    
    ["Enable messages"] = true,
    ["Toggles whether to output messages"] = true,
    
    ["Toggle received message"] = true,
    ["Received message"] = true,
    ["Sets the summon received message"] = true,
    ["Received channel"] = true,
    
    ["Toggle warlock chat message"] = true,
    ["Warlock summon message"] = true,
    ["Sets the warlock summon message"] = true,
    ["Warlock channel"] = true,
    
    ["Toggle warlock whisper message"] = true,
    ["Warlock whisper message"] = true,
    ["Sets the warlock whisper message"] = true,
    ["Unable to whisper the summoner."] = true,
    
    -- Gui only
    ["|cffFFA500Right-Click:|r Options"] = true,
    ["Hide minimap icon"] = true,
    ["Last Summon By:"] = true,
    ["Last Summoned:"] = true,
    --]]
    
    -- Settings - inputs: chat channel
    ["SAY"] = true,
    ["PARTY"] = true,
    ["RAID"] = true,
    ["GROUP"] = true,
    ["WHISPER"] = true,
    
    -- Settings - inputs: message tokens
    ["summoner"] = true,
    ["target"] = true,
    ["zone"] = true,
    ["shards"] = true,
    
    -- Game: spell names
    ["Ritual of Summoning"] = true,
    
    -- Game: item names
    ["Soul Shard"] = true,
  } 
end)