local A = FonzSummon

A.module 'fsm.warlock'

local L = AceLibrary("AceLocale-2.2"):new("FonzSummon")

local util = A.require 'util.bag'

function M.isSummoner()
  local _, class = UnitClass("player")
  local level = UnitLevel("player")
  -- [Vanilla] Only level 20+ warlocks have access to Ritual of Summoning
  return class == "WARLOCK" and level >= 20
end

function M.getShardCount()
  local _, _, _, shard_count = util.findBagItem(L["Soul Shard"])
  return shard_count
end
