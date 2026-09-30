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

    local drop = table.Random( ZADBase["CommonTable"])

    if not ply:canPickupItem(drop) then return end -- i hate you zeus
    SafeRemoveEntity( self )
    ply:sendZADMessage({ZADBase.LootTableColors["Common"], "You received: [Common] ", drop})

end
