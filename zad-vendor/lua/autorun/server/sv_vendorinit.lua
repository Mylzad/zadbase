-- Made by Mylzad https://steamcommunity.com/id/Mylzad/

wOS = wOS or {}

ZADVendor = ZADVendor or {}

--------------------------- Don't touch anything below unless you know what your doing-----------------------------------------

util.AddNetworkString( "ALCSBuyItem" )
util.AddNetworkString( "ALCSSellItem" )
util.AddNetworkString( "ALCSVendorTable" )
util.AddNetworkString( "ALCSSellAllType")

net.Receive("ALCSBuyItem", function(len, ply)

	local itemname = net.ReadString()
	local data = wOS:GetItemData(itemname)
	local rarity = data.RarityName
	local price = ZADVendor.Prices[rarity]

	if (ply:canAfford(price)) then
		if (!ply:canPickupItem(itemname)) then return end
		ply:addMoney(-price)
		local temp = string.Comma(price)

        ply:sendZADMessage({ZADVendor.Colors[rarity], "You have purchased: [", rarity, "] ", itemname, " for $", temp})
	else
		ply:SendLua( [[ notification.AddLegacy( "You cannot afford this item!", NOTIFY_GENERIC, 5 ) ]] )
	end
	return
end)

net.Receive("ALCSSellItem", function(len, ply)

	local itemname = net.ReadString()
	local itemid = wOS:GetItemData(itemname)

	if (itemid.RarityName == nil) then
		ply:SendLua( [[ notification.AddLegacy( "You attempted to sell an invalid item!", NOTIFY_GENERIC, 5 ) ]] )
		return
	end

	local sellprice = (ZADVendor.Prices[itemid.RarityName] * .5)
	local slot = ply:hasItem(itemname)
	if(slot == false) then return end

	ply:addMoney(sellprice)
	if(istable(ply.SaberInventory[slot]) and ply.SaberInventory[slot].Amount > 1) then
		ply.SaberInventory[slot].Amount = ply.SaberInventory[slot].Amount - 1
	else
		ply.SaberInventory[slot] = "Empty"
	end

	sellprice = string.Comma(sellprice)
    ply:sendZADMessage({ZADVendor.Colors[itemid.RarityName], "You have sold: [", itemid.RarityName, "] ", itemname, " for $", sellprice})
	return
end)

net.Receive("ALCSSellAllType", function(len, ply)
	local rarity = net.ReadString()
	local sellprice = (ZADVendor.Prices[rarity] * .5)
	local length = table.Count(ply.SaberInventory)
	local count = 0
	local slots = {}

	for i=1, length do
		local itemslot = ply.SaberInventory[i]
		local itemdata
    	if (!istable(itemslot)) then
			if(itemslot == "Empty") then continue end
    		itemdata = wOS:GetItemData(itemslot)
    		if(itemdata.RarityName == rarity) then
    			count = count + 1
    			table.insert(slots, table.Count(slots) + 1, i)
    		end
    	else
			if(itemslot.Name == "Empty") then continue end
			itemdata = wOS:GetItemData(itemslot.Name)
			if (itemdata.RarityName == rarity) then
				table.insert(slots, table.Count(slots) + 1, i)
				count = count + ply.SaberInventory[i].Amount
			end
		end
	end

	local rarityname = rarity

	if(rarity == "Legendary") then
		rarityname = "Legendarie"
	end

	if(table.Count(slots) >= 1) then
		local longboi = table.Count(slots)
		for i=1, longboi do
			if(istable(ply.SaberInventory[slots[i]])) then
				ply.SaberInventory[slots[i]].Name = "Empty"
			else
				ply.SaberInventory[slots[i]] = "Empty"
			end
		end
		local money = sellprice*count
		ply:addMoney(money)
		local temp = string.Comma(money)
        ply:sendZADMessage({ZADVendor.Colors[rarityname], "You have sold ", count," ", rarity, "s for $", temp})
	else
		ply:sendZADMessage( {Color(200, 0, 0), "You don't have any "..rarityname.."s to sell!"})
		return
	end
end)

hook.Add("ALCSVendorScript", "OpenVendorAndOnClient", function( ply )
	local count = 0
	ZADVendor.Items = {}
	for id, item in pairs( wOS.ItemIDTranslations ) do

		local itemdata = wOS:GetItemData(item)

		if (itemdata.RarityName == nil) then continue end
		if (ZADVendor.Prices[itemdata.RarityName] == nil) then continue end
		if (ZADVendor.IgnoredItems[item]) then continue end

		count = count + 1
		local temp = {
			name = item,
			rarity = itemdata.RarityName,
			model = itemdata.Model,
			description = itemdata.Description
		}

		if((table.Count(ZADVendor.Items) <= 1) && count <= 1 ) then
			ZADVendor.Items = {temp}
			continue
		end

		table.Add(ZADVendor.Items, {temp})

	end

	if(table.Count(ZADVendor.Items) <= 0) then
		ply:SendLua( [[ notification.AddLegacy( "The Vendor has no items that are sellable!", NOTIFY_GENERIC, 5 ) ]] )
		return
	end

	table.sort(ZADVendor.Items, function( a, b ) return ZADVendor.Prices[a.rarity] > ZADVendor.Prices[b.rarity] end)

	net.Start("ALCSVendorTable")
		net.WriteTable(ZADVendor.Items)
	net.Send(ply)
end)
