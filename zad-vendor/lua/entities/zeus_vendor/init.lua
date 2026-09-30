AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize() // Set all the parameters for the box
    self:SetModel( "models/props_combine/combine_interface001.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
    self:SetPos( self:GetPos() )

    local phys = self:GetPhysicsObject() // Make the box have physics

    if phys:IsValid() then
        phys:Wake()
    end

end

function ENT:Use( ply )

    if not (IsValid( ply ) && ply:IsPlayer()) then return end

    hook.Run("ALCSVendorScript", ply )

end
