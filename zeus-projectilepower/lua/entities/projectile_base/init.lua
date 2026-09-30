AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

ZADBase = ZADBase or {}

function ENT:Initialize() // Set all the parameters for the box
    self:SetModel( "models/dav0r/hoverball.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetNoDraw(true)
    self:SetPos( self:GetPos() )
    if !self.EntSound then
        self.EntSound = CreateSound(self, Sound("ambient/fire/fire_big_loop1.wav"))
        self.EntSound:SetSoundLevel( 80 )
        self.EntSound:PlayEx(1, 220)
    end

    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:Wake()
        phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
        phys:AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
        phys:SetMaterial("default_silent")
    end

    for k,v in pairs(ents.GetAll()) do
        if(v:GetClass() == self:GetClass() && v != self) then
            constraint.NoCollide(v, self.Entity, 0, 0)
        end
    end

    if(!IsValid(self:GetOwner())) then self:SetOwner(self:GetCreator()) end

    local damage = 500
    if( self.HitDamage == nil ) then self.HitDamage = damage end

    local radius = 350
    if( self.BlastRadius == nil ) then self.BlastRadius = radius end

    local explosioneffect = "_ai_blackhole"
    if( self.ExplosionEffect == nil ) then self.ExplosionEffect = explosioneffect end

    local effect = "mr_effect_02"
    if( self.Effect != nil ) then effect = self.Effect end
    timer.Simple( .01, function()
        ParticleEffectAttach( effect, PATTACH_ABSORIGIN_FOLLOW, self, 1 )
    end)
end

function ENT:PhysicsCollide( data, phys )
    if self.Hit then return end
    self.Hit = true
    self:SetNWBool("Hit", true)

    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetMass(1)
        phys:SetVelocity(phys:GetVelocity()*.00001)
    end

    if data.HitEntity:IsWorld() then
        local trace = {}
        trace.filter = {self}
        data.HitNormal = data.HitNormal * -1
        local start = data.HitPos + data.HitNormal
        local endpos = data.HitPos - data.HitNormal
        util.Decal( "Scorch", start, endpos )
    end

    local dmginfo = DamageInfo()
    dmginfo:SetDamage( self.HitDamage )
    dmginfo:SetDamageType( DMG_GENERIC )
    if(IsValid(self:GetOwner())) then
        dmginfo:SetAttacker( self:GetOwner() )
    else
        dmginfo:SetAttacker( game.GetWorld() )
    end
    dmginfo:SetInflictor( self )
    util.BlastDamageInfo( dmginfo, self:GetPos(), self.BlastRadius )

    local pos = self:GetPos()
    local shouldphys = true

    for k,v in pairs(ents.FindInSphere(pos, self.BlastRadius*.85)) do
        if v:IsNPC() then
            shouldphys = false
        end
    end


    if shouldphys then
        local physExplo = ents.Create( "env_physexplosion" )
        physExplo:SetPos( self:GetPos() )
        physExplo:SetKeyValue( "magnitude", "1000" ) -- power of explosion
        physExplo:SetKeyValue( "radius", tostring(self.BlastRadius*2) )	-- Radius of the explosion
        physExplo:SetKeyValue( "spawnflags", "1" )
        physExplo:Spawn()
        physExplo:Fire( "Explode", "", 0 )
    end

    local shake = ents.Create( "env_shake" )
    shake:SetPos( self:GetPos() )
    shake:SetKeyValue( "amplitude", "1000" )
    shake:SetKeyValue( "radius", tostring(self.BlastRadius*6) )
    shake:SetKeyValue( "duration", "3" )
    shake:SetKeyValue( "frequency", "255" )
    shake:SetKeyValue( "spawnflags", "4" )
    shake:Spawn()
    shake:Activate()
    shake:Fire( "StartShake", "", 0 )
    shake:Fire( "kill", 0, 10 )
    local explosion = ents.Create( "base_gmodentity" )
    explosion:SetPos( self:GetPos() )
    explosion:SetMoveType(MOVETYPE_NONE)
    ParticleEffect( self.ExplosionEffect, self:GetPos() + Vector(0,0,50),Angle(0,0,0), explosion)
    for k,v in pairs(ents.GetAll()) do
        constraint.NoCollide(v, explosion, 0, 0)
    end
    timer.Simple(1.2, function()
        explosion:Remove()
    end)
    self:EmitSound(Sound("ambient/explosions/explode_4.wav"),90)
    self:SetMoveType(MOVETYPE_NONE)
    self:Remove()
    --[[
    timer.Simple(1, function()
        self:Remove()
    end)
    ]]--
end


function ENT:OnRemove()
    if( self.EntSound ) then
        self.EntSound:ChangeVolume( 0, .02 )
        self.EntSound:Stop()
        self.EntSound = nil
    end
end

function ENT:Think()
    if self:WaterLevel() > 0 then
        SafeRemoveEntity( self )
    end
    self.Entity:NextThink( CurTime() )
    return true
end
