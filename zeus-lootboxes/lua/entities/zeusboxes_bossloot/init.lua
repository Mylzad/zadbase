AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

ZADBase = ZADBase or {}

function ENT:Initialize() // Set all the parameters for the box
    self:SetModel( "models/starwars/syphadias/props/sw_tor/bioware_ea/items/harvesting/slicing/slicing_footlocker_screen.mdl" )
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
    local numoftbls = table.Count(ZADBase.RarityNames)

    // Handles all drops
    for i=1, numoftbls do
        local rarity = ZADBase.RarityNames[i]
        local drop = table.Random( ZADBase[rarity .. "Table"] )

        if( dropnum >= lowest && dropnum <= (ZADBase.BossRarities[rarity] + lowest) ) then
            if not ply:canPickupItem(drop) then return end -- i hate you zeus
            ply:AddSkillXP(ZADBase.BossXPAmounts[rarity])
            self.players[ply:SteamID()] = true
            ply:sendZADMessage({ZADBase.LootTableColors[rarity], "You received: [", rarity, "] ", drop, "\n You gained ", ZADBase.BossXPAmounts[rarity], "XP from opening this lootbox."})
            return
        end
        lowest = lowest + ZADBase.Rarities[rarity]
    end

end
