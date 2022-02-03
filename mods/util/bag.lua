local A = FonzSummon

A.module 'util.bag'

function mprint(...)
  DEFAULT_CHAT_FRAME:AddMessage(table.concat(arg, " "))
end

function isempty(s)
  return s == nil or s == ''
end

function itemLinkToName(link)
	return gsub(link,"^.*%[(.*)%].*$","%1")
end

function M.findBagItem(item)
	if isempty(item) then return end

	local search_item = itemLinkToName(item)
  if isempty(search_item) then return end
  search_item = strlower(search_item)
  
	local bag, slot, texture
	local totalcount = 0
  local bag_item
	for b = 0,4 do
		for s = 1,GetContainerNumSlots(b) do
			local link = GetContainerItemLink(b, s)
			if not isempty(link) then
        bag_item = itemLinkToName(link)
        if not isempty(bag_item) then
          bag_item = strlower(bag_item)
          if search_item == bag_item then
            bag, slot = b, s
            local count
            texture, count = GetContainerItemInfo(b, s)
            totalcount = totalcount + count
          end
        end
			end
		end
	end
	return bag, slot, texture, totalcount
end

function M.useBagItem(item, show)
  if isempty(item) then return end
  
	for b = 0,4 do
		for s = 1,GetContainerNumSlots(b) do
			local link = GetContainerItemLink(b, s)
			if not isempty(link) then
				if string.find(link, item) then
          UseContainerItem(b, s)
          if show then
            mprint("Item '" .. itemLinkToName(link) .. "' used.")
          end
          return true
				end
			end
		end
	end
end

function M.deleteBagItem(bag, slot)
  PickupContainerItem(bag,slot)
  DeleteCursorItem()
end

function M.deleteNamedBagItem(item, bag, slot, show)
	if isempty(item) or bag == nil or slot == nil then return end
  if show == nil then show = true end
  
	local expected_item = string.lower(itemLinkToName(item))  
  if isempty(expected_item) then return end
  
  local link = GetContainerItemLink(bag, slot)
	if not link then return end
  
  local bag_item = string.lower(itemLinkToName(link))
  if bag_item == expected_item then
    if show then
      mprint("Deleting bag item: "..bag_item)
    end
    deleteBagItem(bag, slot)
  end
end

function M.deleteItem(item)
	if isempty(item) then return end
  
  local bag, slot = findBagItem(item)
  if bag == nil or slot == nil then return end
  
  deleteNamedBagItem(item, bag, slot)
end