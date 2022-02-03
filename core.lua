local A = FonzSummon

A.module 'fsm'

-- TRANSLATIONS

local L = AceLibrary("AceLocale-2.2"):new("FonzSummon")

-- LIBRARIES

local tablet  = AceLibrary("Tablet-2.0")

-- GLOBAL IMPORTS

local tolower, toupper, strmatch = strlower, strupper, string.match
local LNONE = tolower(NONE)
local LDEFAULTS = tolower(DEFAULTS)

-- MODULES

local util = A.requires(
  'util.string',
  'util.chat'
)
local warlock = A.require 'fsm.warlock'

--------------------------------------------------------------------------------

-- SETTINGS

local defaults = {
  enable = true,
  received = true,
  received_msg = L["Received summon. Thank you {summoner}"],
  received_chan = L["GROUP"],
  summoner = true,
  summoner_msg = L["Click to summon {target} to {zone}. "
    .."Do not move when you click. [{shards} shards left]"],
  summoner_chan = L["GROUP"],
  whisper = true,
  whisper_msg = L["Summoning you to {zone}"],
}

local options = {
  type = "group",
  args = {
    Enable = {
      type = "toggle",
      name = L["Enable messages"],
      desc = L["Toggles whether to output messages"],
      get = "isEnabled",
      set = "toggleEnabled",
      order = 10,
    },
    Received = {
      type = "toggle",
      name = L["Toggle received message"],
      desc = L["Toggle received message"],
      get = "isReceived",
      set = "toggleReceived",
      order = 35,
    },
    ReceivedMsg = {
      type = "text",
      name = L["Received message"],
      desc = L["Sets the summon received message"],
      get = "getReceivedMsg",
      set = "setReceivedMsg",
      usage = string.format(
        L["|cffffff7f%s|r to reset or |cffffff7f%s|r to disable"], 
        DEFAULTS, NONE),
      order = 40,
    },
    ReceivedChan = {
      type = "text",
      name = L["Received channel"],
      desc = L["Chat channel: SAY, PARTY, RAID, GROUP, WHISPER "
        .."or a channel number"],
      get  = "getReceivedChan",
      set  = "setReceivedChan",
      usage = L["SAY, PARTY, RAID, GROUP, WHISPER, <channel number>"],
      validate = function(text) local tu=toupper return
        tu(text)==L["SAY"] or tu(text)==L["PARTY"]
        or tu(text)==L["RAID"] or tu(text)==L["GROUP"]
        or tu(text)==L["WHISPER"] 
        or strmatch(text, "^%d+$")
        end,
      order = 50,
    },
  }
}

-- ADDON METHODS

-- Settings control --

function A:isEnabled()
  return self.db.profile.enable
end

function A:toggleEnabled()
  self.db.profile.enable = not self.db.profile.enable
end

function A:isReceived()
  return self.db.profile.received
end

function A:toggleReceived()
  self.db.profile.received = not self.db.profile.received
end

function A:getReceivedMsg()
  return self.db.profile.received_msg
end

function A:setReceivedMsg(msg)
  local lmsg = tolower(msg)
  if lmsg == LNONE then
    self.db.profile.received_msg = nil
  elseif lmsg == LDEFAULTS then
    self.db.profile.received_msg = defaults["received_msg"]
  else
    self.db.profile.received_msg = msg
  end
end

function A:getReceivedChan()
  return self.db.profile.received_chan
end

function A:setReceivedChan(id)
  self.db.profile.received_chan = tolower(id)
end

function A:isSummoner()
  return self.db.profile.summoner
end

function A:toggleSummoner()
  self.db.profile.summoner = not self.db.profile.summoner
end

function A:getSummonerMsg()
  return self.db.profile.summoner_msg
end

function A:setSummonerMsg(msg)
  local lmsg = tolower(msg)
  if lmsg == LNONE then
    self.db.profile.summoner_msg = nil
  elseif lmsg == LDEFAULTS then
    self.db.profile.summoner_msg = defaults["summoner_msg"]
  else
    self.db.profile.summoner_msg = msg
  end
end

function A:getSummonerChan()
  return self.db.profile.summoner_chan
end

function A:setSummonerChan(id)
  self.db.profile.summoner_chan = tolower(id)
end

function A:isWhisper()
  return self.db.profile.whisper
end

function A:toggleWhisper()
  self.db.profile.whisper = not self.db.profile.whisper
end

function A:getWhisperMsg()
  return self.db.profile.whisper_msg
end

function A:setWhisperMsg(msg)
  local lmsg = tolower(msg)
  if lmsg == LNONE then
    self.db.profile.whisper_msg = nil
  elseif lmsg == LDEFAULTS then
    self.db.profile.whisper_msg = defaults["whisper_msg"]
  else
    self.db.profile.whisper_msg = msg
  end
end

-- Events --

do
  local summoner
  
  function getSummoner()
    return summoner
  end

  function A:CONFIRM_SUMMON(...)
    local profile = self.db.profile
    if not profile.enable then return end
    
    if profile.received and profile.received_msg then
      summoner = GetSummonConfirmSummoner() or ""
      local msg = util.replace_vars{
        profile.received_msg,
        summoner = summoner
      }
      local channel = profile.received_chan
      if toupper(channel) == L["WHISPER"] then
        if summoner ~= "" then
          util.whisperMessage(summoner, msg)
        else
          self:Print(L["Unable to whisper the summoner."])
        end
      else
        util.chatMessage(msg, channel)
      end
    end
  end
end

function A:SPELLCAST_START(...)
  local profile = self.db.profile
  if not profile.enable then return end
  
  if arg1 == L["Ritual of Summoning"] then
    if not A.timers then
      A.timers = {}
      A.timers.spell = {}
    end
    A.timers.spell["Ritual of Summoning"] = GetTime()
  end
end

do
  local target
  
  function getSummoned()
    return target
  end

  function A:SPELLCAST_CHANNEL_START(...)
    local profile = self.db.profile
    if not profile.enable then return end
    
    -- arg1=duration. 
    -- duration of Ritual of Summoning is 600000 (10 min). Ignore anything less
    if arg1 < 600000 then return end
    
    if A.timers and A.timers.spell then
      -- Ensure that this is the spell channel immediately following Ritual cast
      local cast_time = A.timers.spell["Ritual of Summoning"]
      if cast_time then
        local elapsed = GetTime() - cast_time
        -- Ritual of Summoning cast timer = 5s default
        if elapsed < 6 then
          target = UnitName("target")
          local zone = GetRealZoneText()
          local shards = warlock.getShardCount()
          local msg
          
          if profile.summoner and profile.summoner_msg then
            msg = util.replace_vars{
              profile.summoner_msg,
              target = target,
              zone = zone,
              shards = shards
            }
            util.chatMessage(msg, profile.summoner_chan)
          end
          
          if profile.whisper and profile.whisper_msg then
            msg = util.replace_vars{
              profile.whisper_msg,
              zone = zone,
              shards = shards
            }
            util.whisperMessage(target, msg)
          end
        end
      end
    end
  end
end

-- Loading --

function A:HookEvents()
  -- Fires when a summons is offered to the player
  self:RegisterEvent("CONFIRM_SUMMON")
  
  if warlock.isSummoner() then
    -- Fires when a unit begins casting a spell
    self:RegisterEvent("SPELLCAST_START")
    -- Fires when a unt starts channeling a spell
    self:RegisterEvent("SPELLCAST_CHANNEL_START")
  end
end

function A:OnEnable()
  self:HookEvents()
  -- Player check requires code that runs after PLAYER_LOGIN event.
  -- This is why this code block is in the OnEnable() handler.
  if warlock.isSummoner() then
    -- Additional options for a summoner
    options.args["Summoner"] = {
      type = "toggle",
      name = L["Toggle warlock chat message"],
      desc = L["Toggle warlock chat message"],
      get = "isSummoner",
      set = "toggleSummoner",
      order = 55,
    }
    options.args["SummonerMsg"] = {
      type = "text",
      name = L["Warlock summon message"],
      desc = L["Sets the warlock summon message"],
      get = "getSummonerMsg",
      set = "setSummonerMsg",
      usage = string.format(
        L["|cffffff7f%s|r to reset or |cffffff7f%s|r to disable"], 
        DEFAULTS, NONE),
      order = 60,
    }
    options.args["SummonerChan"] = {
      type = "text",
      name = L["Warlock channel"],
      desc = L["Chat channel: SAY, PARTY, RAID, GROUP or a channel number"],
      get  = "getSummonerChan",
      set  = "setSummonerChan",
      usage = L["SAY, PARTY, RAID, GROUP, <channel number>"],
      validate = function(text) local tu=toupper return
        tu(text)==L["SAY"] or tu(text)==L["PARTY"]
        or tu(text)==L["RAID"] or tu(text)==L["GROUP"]
        or strmatch(text, "^%d+$")
        end,
      order = 70,
    }
    options.args["Whisper"] = {
      type = "toggle",
      name = L["Toggle warlock whisper message"],
      desc = L["Toggle warlock whisper message"],
      get = "isWhisper",
      set = "toggleWhisper",
      order = 85,
    }
    options.args["WhisperMsg"] = {
      type = "text",
      name = L["Warlock whisper message"],
      desc = L["Sets the warlock whisper message"],
      get = "getWhisperMsg",
      set = "setWhisperMsg",
      usage = string.format(
        L["|cffffff7f%s|r to reset or |cffffff7f%s|r to disable"], 
        DEFAULTS, NONE),
      order = 90,
    }
  end
end

-- STARTUP

-- Command line --

A:RegisterChatCommand({L["SLASHCMD_SHORT"], L["SLASHCMD_LONG"]}, options)
A:RegisterDB("FonzSummonDB")
A:RegisterDefaults("profile", defaults)

-- Fubar --

-- Sensible Fubar defaults for an independent profile, minimap-enabled, 
-- minimap-hideable, customized minimap tooltip addon if Fubar addon is not 
-- available.
-- Inspired: @Roadblock, author of "Interruptor" addon

function A:OnTooltipUpdate()
  local category = tablet:AddCategory(
    "columns", 2,
    "child_textR", 1,"child_textG", 1, "child_textB", 0,
    "child_text2R", 1, "child_text2G", 1, "child_text2B", 1
  )
  local summoner = getSummoner()
  summoner = summoner ~= "" and summoner or "-"
  category:AddLine(
    "text", L["Last Summon By:"],
    "text2", summoner
  )
  if warlock.isSummoner() then
    local summoned = getSummoned() or "-"
    category:AddLine(
      "text", L["Last Summoned:"],
      "text2", summoned
    )
  end
  tablet:SetHint(L["|cffFFA500Right-Click:|r Options"])
end

A.hasIcon = A.addon_path .. [[\img\icon]]
A.defaultMinimapPosition = 260
A.defaultPosition = "CENTER"
A.cannotDetachTooltip = true
A.tooltipHiddenWhenEmpty = false
A.hideWithoutStandby = true
A.independentProfile = true
A.OnMenuRequest = options
if not FuBar then
  A.OnMenuRequest.args.hide.guiName = L["Hide minimap icon"]
  A.OnMenuRequest.args.hide.desc = L["Hide minimap icon"]
end