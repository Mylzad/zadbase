AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "autorun/sh_config.lua" )

include( "shared.lua" )

ZADBase = ZADBase or {}

function ENT:Initialize() // Set all the parameters for the box
    self:SetModel( "models/starwars/syphadias/props/sw_tor/bioware_ea/items/harvesting/slicing/slicing_footlocker_dial.mdl" )
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

    local dropnum = math.random( 1, ZADBase.MaxPercent )
    local lowest = 0
    local numoftbls = table.Count(ZADBase.RarityNames)

    // Handles all drops
    for i=1, numoftbls do
        local rarity = ZADBase.RarityNames[i]
        if(ZADBase[rarity.."Table"] == nil) then continue end
        local drop = table.Random( ZADBase[rarity .. "Table"] )

        if( dropnum >= lowest && dropnum <= (ZADBase.Rarities[rarity] + lowest) ) then
            if not ply:canPickupItem(drop) then return end
            ply:AddSkillXP(ZADBase.XPAmounts[rarity])
            SafeRemoveEntity( self )
            ply:sendZADMessage({ZADBase.LootTableColors[rarity], "You received: [", rarity, "] ", drop, "\n You gained ", ZADBase.XPAmounts[rarity], "XP from opening this lootbox."})
            return
        end
        lowest = lowest + ZADBase.Rarities[rarity]
    end
end
