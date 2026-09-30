SWEP.PrintName = "Projectile Demo Tool"
SWEP.Author = "Mylzad"
SWEP.Purpose = "Used to demonstrate the projectiles I made"
SWEP.Instructions = "Left-Click to fire a base projectile"
SWEP.Category = "ZAD Base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Weight = 1
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.HoldType = "normal"

local ShootSound = Sound( "Metal.SawbladeStick" )

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:PrimaryAttack()
    if !SERVER then return end
    self:SetNextPrimaryFire(1)
    local ent = ents.Create("projectile_base")
        ent:SetPos(self.Owner:GetPos()*Vector(1,1,1))
        ent:SetAngles(self.Owner:GetAimVector():Angle())
        ent:Spawn()
        ent:GetPhysicsObject():ApplyForceCenter(self.Owner:GetForward()*10000)
end

