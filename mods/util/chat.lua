local A = FonzSummon

A.module 'util.chat'

function isempty(s)
  return s == nil or s == ''
end

function M.chatMessage(msg, chat_type)
  if isempty(msg) then return end
  chat_type = chat_type or "GROUP"
  if tonumber(chat_type) then
    SendChatMessage(msg, "CHANNEL", nil, chat_type)
  else
    if chat_type == "GROUP" then
      SendChatMessage(msg, UnitInRaid("player") and "RAID" or "PARTY")
    else
      SendChatMessage(msg, chat_type)
    end
  end
end

function M.whisperMessage(target, msg)
  if isempty(target) or isempty(msg) then return end
  SendChatMessage(msg, "WHISPER", nil, target)
end