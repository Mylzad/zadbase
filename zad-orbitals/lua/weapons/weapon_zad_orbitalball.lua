if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Orbital Targeting Grenade"
SWEP.Author = "Mylzad"
SWEP.Category = "ZADBase"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"

SWEP.UseHands = true

-- HL2 grenade view/world models
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"

SWEP.HoldType = "grenade"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

SWEP.ThrowForce = 1200

---------------------------------------------------------
-- INITIALIZE
---------------------------------------------------------

function SWEP:Initialize()
    self:SetHoldType("grenade")

    self.OrbitalThrown = false
end

---------------------------------------------------------
-- DEPLOY
---------------------------------------------------------

function SWEP:Deploy()
    self.OrbitalThrown = false

    return true
end

---------------------------------------------------------
-- PRIMARY ATTACK
---------------------------------------------------------

function SWEP:PrimaryAttack()

    if self.OrbitalThrown then
        return
    end

    self:SetNextPrimaryFire(CurTime() + 1)

    local owner = self:GetOwner()

    if not IsValid(owner) then
        return
    end

    -----------------------------------------------------
    -- Throw animation
    -----------------------------------------------------

    self:SendWeaponAnim(ACT_VM_THROW)

    owner:SetAnimation(PLAYER_ATTACK1)

    -----------------------------------------------------
    -- Server creates actual grenade
    -----------------------------------------------------

    if SERVER then
        self:ThrowOrbitalGrenade()
    end
end

---------------------------------------------------------
-- THROW GRENADE
---------------------------------------------------------

function SWEP:ThrowOrbitalGrenade()

    if not SERVER then return end
    if self.OrbitalThrown then return end

    local owner = self:GetOwner()

    if not IsValid(owner) then
        return
    end

    -----------------------------------------------------
    -- Read pending strike
    -----------------------------------------------------

    local strikeID = self.OrbitalStrikeID
    local strikeName = self.OrbitalStrikeName

    if not strikeID then
        owner:ChatPrint("No orbital strike assigned.")
        owner:StripWeapon(self:GetClass())
        return
    end

    self.OrbitalThrown = true

    -----------------------------------------------------
    -- Create grenade entity
    -----------------------------------------------------

    local grenade = ents.Create("zad_orbital_grenade")

    if not IsValid(grenade) then
        self.OrbitalThrown = false
        return
    end

    -----------------------------------------------------
    -- Spawn location
    -----------------------------------------------------

    local aim = owner:GetAimVector()

    local pos =
        owner:EyePos()
        + aim * 20
        + owner:GetRight() * 8
        - owner:GetUp() * 5

    grenade:SetPos(pos)

    grenade:SetAngles(owner:EyeAngles())

    grenade:SetOwner(owner)

    -----------------------------------------------------
    -- Give grenade orbital information
    -----------------------------------------------------

    grenade.OrbitalOwner = owner
    grenade.OrbitalStrikeID = strikeID
    grenade.OrbitalStrikeName = strikeName

    grenade:Spawn()
    grenade:Activate()

    -----------------------------------------------------
    -- Throw velocity
    -----------------------------------------------------

    local phys = grenade:GetPhysicsObject()

    if IsValid(phys) then

        phys:SetVelocity(
            aim * self.ThrowForce
            + owner:GetVelocity()
        )

        phys:AddAngleVelocity(
            Vector(
                math.random(-300, 300),
                math.random(-300, 300),
                math.random(-300, 300)
            )
        )
    end

    -----------------------------------------------------
    -- Remove temporary weapon shortly after throw
    -----------------------------------------------------

    timer.Simple(0.25, function()

        if not IsValid(owner) then
            return
        end

        if IsValid(self) then
            owner:StripWeapon(self:GetClass())
        end

    end)
end

---------------------------------------------------------
-- HOLSTER
--
-- If they switch away BEFORE throwing,
-- cancel the orbital.
---------------------------------------------------------

function SWEP:Holster(newWeapon)

    if SERVER and not self.OrbitalThrown then

        local owner = self:GetOwner()

        if IsValid(owner) then

            owner:ChatPrint(
                "ORBITAL STRIKE CANCELLED"
            )

            -------------------------------------------------
            -- Remove the weapon next frame.
            -- Don't StripWeapon directly inside Holster.
            -------------------------------------------------

            timer.Simple(0, function()

                if not IsValid(owner) then return end

                local weapon = owner:GetWeapon(
                    "weapon_zad_orbitalball"
                )

                if IsValid(weapon) then
                    owner:StripWeapon(
                        "weapon_zad_orbitalball"
                    )
                end

            end)
        end
    end

    return true
end

---------------------------------------------------------
-- SECONDARY ATTACK
---------------------------------------------------------

function SWEP:SecondaryAttack()
end

---------------------------------------------------------
-- HUD (only drawn on the client while the weapon is held)
---------------------------------------------------------

function SWEP:DrawHUD()

    if not CLIENT then return end

    local name = self:GetNWString("OrbitalStrikeName", "UNKNOWN")

    local width, height = 360, 90
    local x = ScrW() / 2 - width / 2
    local y = ScrH() * 0.78

    surface.SetDrawColor(10, 10, 10, 200)
    surface.DrawRect(x, y, width, height)

    surface.SetDrawColor(255, 60, 40)
    surface.DrawOutlinedRect(x, y, width, height, 2)

    draw.SimpleText("ORBITAL STRIKE READY", "Trebuchet18", ScrW() / 2, y + 18, Color(255, 210, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(name, "Trebuchet24", ScrW() / 2, y + 45, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("LEFT CLICK - THROW   |   SWITCH WEAPON - CANCEL", "Trebuchet18", ScrW() / 2, y + 72, Color(170, 170, 170), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end