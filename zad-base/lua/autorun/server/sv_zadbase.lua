ZADBase = ZADBase or {}

util.AddNetworkString( "ZADMessage" )
util.AddNetworkString( "ZADPlaySound" )

local meta = FindMetaTable("Player")

function meta:sendZADMessage( info )
	net.Start( "ZADMessage" )
        net.WriteTable(info)
    net.Send(self)
end

function meta:sendClientSound( sound )
	net.Start( "ZADPlaySound" )
		net.WriteString(sound)
	net.Send(self)
end

function meta:canPickupItem( itemname )
	local data = wOS:GetItemData(itemname)
	local canPickup = false
    local length = table.Count(self.SaberInventory)

    for i=1, length do
    	local itemslot = self.SaberInventory[i]
    	if (!istable(itemslot)) then
    		if(itemslot == "Empty") then
    			self.SaberInventory[i] = drop
    			return true
    		end
    	else
        	if (self.SaberInventory[i].Name == "Empty" || (self.SaberInventory[i].Name == itemname && self.SaberInventory[i].Amount < data.MaxStack) ) then
            	if (self.SaberInventory[i].Name == "Empty") then
		        	self.SaberInventory[i].Name = itemname
		        	self.SaberInventory[i].Amount = 1
		    	else
		        	self.SaberInventory[i].Amount = self.SaberInventory[i].Amount + 1
		    	end

				self:sendClientSound("buttons/button24.wav")

	            return true
	        end
    	end
    end

    self:sendZADMessage( {Color(255, 0, 0), "Your inventory is full!"} )
    return false
end

function meta:hasItem( itemname )
	local length = table.Count(self.SaberInventory)
	// Fix this fucking code mate
	// Its saying if you have an empty slot then you have the item
	for i=1, length do
		local itemslot = self.SaberInventory[i]
    	if (!istable(itemslot)) then
			if(itemslot == itemname) then
				return i
			end
    	else
			if (itemslot.Name == itemname) then
				return i
			end
		end
	end

	self:sendZADMessage({Color(255, 0, 0), "You do not have this item!"})
	return false
end
