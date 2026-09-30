AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

ZADBase = ZADBase or {}

function ENT:Initialize() // Set all the parameters for the box
    self:SetModel( "models/starwars/syphadias/props/sw_tor/bioware_ea/items/harvesting/slicing/slicing_footlocker_panel.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
    self:SetPos( self:GetPos() + Vector( 0, 0, 0 ) )

    local phys = self:GetPhysicsObject() // Make the box have physics

    if phys:IsValid() then
        phys:Wake()
    end

end

function ENT:Use( ply )

    if !IsValid( ply ) && ply:IsPlayer() then return end
    self.players = self.players or {}
    if (self.players[ply:SteamID()]) then
        ply:sendZADMessage({Color(255, 0, 0), "You've already picked up this lootbox!"})
        return
    end

    local dropnum = math.random( 1, ZADBase.MaxPercent )
    local lowest = 0
    local numoftbls = table.Count(ZADBase.EventRolls)

    // Handles all drops
    for i=1, numoftbls do
        local rarity = ZADBase.EventRolls[i]
        local drop = table.Random( ZADBase[rarity .. "Table"] )

        if( dropnum >= lowest && dropnum <= (ZADBase.EventRarities[rarity] + lowest) ) then

            if(rarity == "Money") then
            	ply:addMoney(drop)
            	drop = ("$"..drop)
            else
                if not ply:canPickupItem(drop) then return end
        	end

            self.players[ply:SteamID()] = true
            ply:sendZADMessage({ZADBase.LootTableColors[rarity], "You received: [", rarity, "] ", drop,  " from opening this lootbox."})
            return
        end
        lowest = lowest + ZADBase.EventRarities[rarity]
    end
end
