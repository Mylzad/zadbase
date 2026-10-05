AddCSLuaFile("autorun/orbital_shared.lua")
AddCSLuaFile("autorun/client/orbital_client.lua")

include("autorun/orbital_shared.lua")

---------------------------------------------------------
-- NETWORK STRINGS
---------------------------------------------------------

util.AddNetworkString("Orbital_Input")
util.AddNetworkString("Orbital_Clear")
util.AddNetworkString("Orbital_Update")
util.AddNetworkString("Orbital_Result")

---------------------------------------------------------
-- PLAYER DATA
---------------------------------------------------------

local function InitializePlayer(ply)
    ply.OrbitalInput = ""
    ply.OrbitalLastInput = 0
    ply.OrbitalLastNetInput = 0
end

hook.Add("PlayerInitialSpawn", "Orbital_InitializePlayer", function(ply)
    InitializePlayer(ply)
end)

---------------------------------------------------------
-- SEND CURRENT INPUT TO CLIENT
---------------------------------------------------------

local function SendInput(ply)
    net.Start("Orbital_Update")
        net.WriteString(ply.OrbitalInput or "")
    net.Send(ply)
end

---------------------------------------------------------
-- CLEAR INPUT
---------------------------------------------------------

local function ClearInput(ply)
    ply.OrbitalInput = ""
    ply.OrbitalLastInput = 0

    SendInput(ply)
end

---------------------------------------------------------
-- INVALID CODE
---------------------------------------------------------

local function CodeRejected(ply)
    net.Start("Orbital_Result")
        net.WriteBool(false)
        net.WriteString("INVALID COMMAND")
    net.Send(ply)

    ClearInput(ply)
end

---------------------------------------------------------
-- VALID CODE
---------------------------------------------------------

local function CodeAccepted(ply, strike)
    print(
        "[ORBITAL] "
        .. ply:Nick()
        .. " entered orbital code for "
        .. strike.name
    )

    net.Start("Orbital_Result")
        net.WriteBool(true)
        net.WriteString(strike.name)
    net.Send(ply)

    -----------------------------------------------------
    -- ACTUAL STRIKE CODE WILL GO HERE
    -----------------------------------------------------

    hook.Run("OrbitalStrikeActivated", ply, strike)

    ClearInput(ply)
end

---------------------------------------------------------
-- CHECK CURRENT CODE
---------------------------------------------------------

local function CheckCode(ply)
    local current = ply.OrbitalInput or ""

    local stillPossible = false

    for _, strike in ipairs(ORBITAL.Strikes) do

        ---------------------------------------------
        -- Exact match
        ---------------------------------------------

        if current == strike.code then
            CodeAccepted(ply, strike)
            return
        end

        ---------------------------------------------
        -- Is this still the beginning of a code?
        ---------------------------------------------

        if string.sub(strike.code, 1, #current) == current then
            stillPossible = true
        end
    end

    ---------------------------------------------
    -- Sequence doesn't match anything
    ---------------------------------------------

    if not stillPossible then
        CodeRejected(ply)
        return
    end

    SendInput(ply)
end

---------------------------------------------------------
-- RECEIVE DIRECTION
---------------------------------------------------------

net.Receive("Orbital_Input", function(_, ply)

    if not IsValid(ply) then return end
    if not ply:Alive() then return end

    -----------------------------------------------------
    -- Rate limiting
    -----------------------------------------------------

    local now = CurTime()

    ply.OrbitalLastNetInput = ply.OrbitalLastNetInput or 0

    if now - ply.OrbitalLastNetInput < ORBITAL.MinimumInputDelay then
        return
    end

    ply.OrbitalLastNetInput = now

    -----------------------------------------------------
    -- Read direction
    -----------------------------------------------------

    local direction = net.ReadString()

    if direction ~= "U"
    and direction ~= "D"
    and direction ~= "L"
    and direction ~= "R" then

        return
    end

    -----------------------------------------------------
    -- Initialize if necessary
    -----------------------------------------------------

    ply.OrbitalInput = ply.OrbitalInput or ""
    ply.OrbitalLastInput = ply.OrbitalLastInput or 0

    -----------------------------------------------------
    -- Timeout
    -----------------------------------------------------

    if ply.OrbitalLastInput > 0 then

        if now - ply.OrbitalLastInput > ORBITAL.InputTimeout then
            ply.OrbitalInput = ""
        end

    end

    ply.OrbitalLastInput = now

    -----------------------------------------------------
    -- Add direction
    -----------------------------------------------------

    ply.OrbitalInput = ply.OrbitalInput .. direction

    CheckCode(ply)
end)

---------------------------------------------------------
-- CLIENT REQUESTED CLEAR
---------------------------------------------------------

net.Receive("Orbital_Clear", function(_, ply)

    if not IsValid(ply) then return end

    ClearInput(ply)
end)

---------------------------------------------------------
-- CLEANUP
---------------------------------------------------------

hook.Add("PlayerDeath", "Orbital_ClearDeath", function(ply)
    ClearInput(ply)
end)