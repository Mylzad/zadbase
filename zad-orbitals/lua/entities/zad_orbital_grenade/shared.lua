AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Orbital Targeting Grenade"

ENT.Spawnable = false

ENT.Model = "models/Items/grenadeAmmo.mdl"

---------------------------------------------------------
-- INITIALIZE
---------------------------------------------------------

function ENT:Initialize()

    if SERVER then

        self:SetModel(self.Model)

        self:PhysicsInit(SOLID_VPHYSICS)

        self:SetMoveType(MOVETYPE_VPHYSICS)

        self:SetSolid(SOLID_VPHYSICS)

        self:SetCollisionGroup(
            COLLISION_GROUP_PROJECTILE
        )

        local phys = self:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
        end

        self.HasImpacted = false

        -------------------------------------------------
        -- Safety cleanup
        -------------------------------------------------

        timer.Simple(60, function()

            if IsValid(self) then
                self:Remove()
            end

        end)

    end
end

---------------------------------------------------------
-- COLLISION
---------------------------------------------------------

function ENT:PhysicsCollide(data, phys)

    if CLIENT then return end
    if self.HasImpacted then return end
    if data.Speed < 50 then return end

    self.HasImpacted = true

    local owner = self.OrbitalOwner
    local strikeID = self.OrbitalStrikeID
    local hitPos = data.HitPos

    local strike = ORBITAL.GetStrike(strikeID)
    local delay = (strike and strike.delay) or ORBITAL.DefaultDelay or 5

    print("Orbital has struck! Incoming Orbital: " .. tostring(self.OrbitalStrikeName or "UNKNOWN"))

    -----------------------------------------------------
    -- Tell every client to draw the beam
    -----------------------------------------------------

    net.Start("Orbital_Beam")
        net.WriteVector(hitPos)
        net.WriteFloat(delay)
    net.Broadcast()

    -----------------------------------------------------
    -- Orbital arrives after the delay
    -- (timer is independent of this entity, which is removed now)
    -----------------------------------------------------

    timer.Simple(delay, function()
        hook.Run("OrbitalStrikeImpact", owner, strikeID, hitPos)
    end)

    -----------------------------------------------------
    -- Landing effect + remove grenade
    -----------------------------------------------------

    local effect = EffectData()
    effect:SetOrigin(hitPos)
    util.Effect("cball_bounce", effect, true, true)

    self:Remove()
end