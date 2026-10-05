include("autorun/orbital_shared.lua")

---------------------------------------------------------
-- DEFAULT BINDS
---------------------------------------------------------

CreateClientConVar(
    "orbital_key_toggle",
    tostring(KEY_G),
    true,
    false
)

CreateClientConVar(
    "orbital_key_up",
    tostring(KEY_UP),
    true,
    false
)

CreateClientConVar(
    "orbital_key_down",
    tostring(KEY_DOWN),
    true,
    false
)

CreateClientConVar(
    "orbital_key_left",
    tostring(KEY_LEFT),
    true,
    false
)

CreateClientConVar(
    "orbital_key_right",
    tostring(KEY_RIGHT),
    true,
    false
)

---------------------------------------------------------
-- STATE
---------------------------------------------------------

local OrbitalActive = false

local CurrentSequence = ""

local PreviousKeys = {}

local ContextButton = nil
local BindWindow = nil

---------------------------------------------------------
-- GET BIND
---------------------------------------------------------

local function GetOrbitalBind(name)

    local cvar = GetConVar("orbital_key_" .. name)

    if not cvar then
        return KEY_NONE
    end

    return cvar:GetInt()
end

---------------------------------------------------------
-- KEY NAME
---------------------------------------------------------

local function GetPrettyKey(key)

    local name = input.GetKeyName(key)

    if not name then
        return "UNBOUND"
    end

    return string.upper(
        language.GetPhrase(name)
    )
end

---------------------------------------------------------
-- SEND DIRECTION
---------------------------------------------------------

local function SendDirection(direction)

    net.Start("Orbital_Input")
        net.WriteString(direction)
    net.SendToServer()

end

---------------------------------------------------------
-- CLEAR INPUT
---------------------------------------------------------

local function ClearInput()

    CurrentSequence = ""

    net.Start("Orbital_Clear")
    net.SendToServer()

end

---------------------------------------------------------
-- ENABLE / DISABLE MODE
---------------------------------------------------------

local function SetOrbitalActive(enabled)

    OrbitalActive = enabled

    if not enabled then
        ClearInput()
    end

end

---------------------------------------------------------
-- CHECK FOR NEW KEY PRESS
---------------------------------------------------------

local function WasPressed(key)

    if not key or key == KEY_NONE then
        return false
    end

    local currentlyDown = input.IsKeyDown(key)

    local previouslyDown = PreviousKeys[key] or false

    PreviousKeys[key] = currentlyDown

    return currentlyDown and not previouslyDown
end

---------------------------------------------------------
-- INPUT HANDLING
---------------------------------------------------------

hook.Add("Think", "Orbital_InputThink", function()

    if gui.IsGameUIVisible() then
        return
    end

    -----------------------------------------------------
    -- Toggle key
    -----------------------------------------------------

    local toggleKey = GetOrbitalBind("toggle")

    if WasPressed(toggleKey) then

        SetOrbitalActive(not OrbitalActive)

        return
    end

    -----------------------------------------------------
    -- Only read directional keys when active
    -----------------------------------------------------

    if not OrbitalActive then
        return
    end

    -----------------------------------------------------
    -- Ignore inputs while using menus
    -----------------------------------------------------

    if IsValid(BindWindow) then
        return
    end

    -----------------------------------------------------
    -- Direction keys
    -----------------------------------------------------

    if WasPressed(GetOrbitalBind("up")) then

        SendDirection("U")

    elseif WasPressed(GetOrbitalBind("down")) then

        SendDirection("D")

    elseif WasPressed(GetOrbitalBind("left")) then

        SendDirection("L")

    elseif WasPressed(GetOrbitalBind("right")) then

        SendDirection("R")

    end

end)

---------------------------------------------------------
-- RECEIVE CURRENT SEQUENCE
---------------------------------------------------------

net.Receive("Orbital_Update", function()

    CurrentSequence = net.ReadString()

end)

---------------------------------------------------------
-- RECEIVE RESULT
---------------------------------------------------------

net.Receive("Orbital_Result", function()

    local success = net.ReadBool()
    local result = net.ReadString()

    if success then

        notification.AddLegacy(
            "ORBITAL COMMAND ACCEPTED: " .. result,
            NOTIFY_HINT,
            4
        )

        surface.PlaySound("buttons/button14.wav")

    else

        notification.AddLegacy(
            result,
            NOTIFY_ERROR,
            3
        )

        surface.PlaySound("buttons/button10.wav")

    end

end)

---------------------------------------------------------
-- HUD
---------------------------------------------------------

local ArrowIcons = {
    U = "↑",
    D = "↓",
    L = "←",
    R = "→"
}

hook.Add("HUDPaint", "Orbital_HUD", function()

    if not OrbitalActive then
        return
    end

    -----------------------------------------------------
    -- Convert sequence to arrows
    -----------------------------------------------------

    local sequenceText = ""

    for i = 1, #CurrentSequence do

        local character = string.sub(
            CurrentSequence,
            i,
            i
        )

        sequenceText =
            sequenceText
            .. (ArrowIcons[character] or "?")
            .. " "

    end

    -----------------------------------------------------
    -- Position
    -----------------------------------------------------

    local width = 500
    local height = 160

    local x = ScrW() / 2 - width / 2
    local y = ScrH() * 0.70

    -----------------------------------------------------
    -- Background
    -----------------------------------------------------

    surface.SetDrawColor(10, 10, 10, 225)

    surface.DrawRect(
        x,
        y,
        width,
        height
    )

    -----------------------------------------------------
    -- Border
    -----------------------------------------------------

    surface.SetDrawColor(230, 180, 40)

    surface.DrawOutlinedRect(
        x,
        y,
        width,
        height,
        2
    )

    -----------------------------------------------------
    -- Header
    -----------------------------------------------------

    draw.SimpleText(
        "ORBITAL FIRE CONTROL",
        "Trebuchet24",
        ScrW() / 2,
        y + 25,
        Color(255, 210, 60),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    -----------------------------------------------------
    -- Status
    -----------------------------------------------------

    draw.SimpleText(
        "INPUT MODE ACTIVE",
        "Trebuchet18",
        ScrW() / 2,
        y + 52,
        Color(100, 255, 100),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    -----------------------------------------------------
    -- Sequence
    -----------------------------------------------------

    draw.SimpleText(
        sequenceText,
        "Trebuchet24",
        ScrW() / 2,
        y + 90,
        Color(255, 255, 255),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    -----------------------------------------------------
    -- Disable hint
    -----------------------------------------------------

    draw.SimpleText(
        GetPrettyKey(GetOrbitalBind("toggle"))
            .. " - EXIT ORBITAL MODE",

        "Trebuchet18",

        ScrW() / 2,
        y + 130,

        Color(170, 170, 170),

        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

end)

---------------------------------------------------------
-- BIND BUTTON CREATION
---------------------------------------------------------

local function CreateBindButton(parent, label, bindName)

    local panel = vgui.Create("DPanel", parent)

    panel:Dock(TOP)

    panel:SetTall(45)

    panel:DockMargin(10, 5, 10, 5)

    -----------------------------------------------------
    -- Label
    -----------------------------------------------------

    local text = vgui.Create("DLabel", panel)

    text:Dock(LEFT)

    text:SetWide(200)

    text:SetText(label)

    text:SetFont("Trebuchet18")

    -----------------------------------------------------
    -- Button
    -----------------------------------------------------

    local button = vgui.Create("DButton", panel)

    button:Dock(FILL)

    local function UpdateText()

        button:SetText(
            GetPrettyKey(
                GetOrbitalBind(bindName)
            )
        )

    end

    UpdateText()

    -----------------------------------------------------
    -- Rebinding
    -----------------------------------------------------

    button.DoClick = function()

        button:SetText("PRESS A KEY...")

        input.StartKeyTrapping()

        button.Think = function(self)

            local key = input.CheckKeyTrapping()

            if not key then
                return
            end

            if key == KEY_ESCAPE then

                self.Think = nil

                UpdateText()

                return
            end

            RunConsoleCommand(
                "orbital_key_" .. bindName,
                tostring(key)
            )

            self.Think = nil

            timer.Simple(0, UpdateText)

        end

    end

end

---------------------------------------------------------
-- SETTINGS WINDOW
---------------------------------------------------------

local function OpenOrbitalSettings()

    if IsValid(BindWindow) then

        BindWindow:Remove()
        BindWindow = nil

        return
    end

    BindWindow = vgui.Create("DFrame")

    BindWindow:SetSize(500, 390)

    BindWindow:Center()

    BindWindow:SetTitle(
        "Orbital Fire Control - Keybindings"
    )

    BindWindow:SetDraggable(true)

    BindWindow:ShowCloseButton(true)

    BindWindow:MakePopup()

    -----------------------------------------------------
    -- Explanation
    -----------------------------------------------------

    local info = vgui.Create("DLabel", BindWindow)

    info:Dock(TOP)

    info:SetTall(55)

    info:DockMargin(10, 10, 10, 5)

    info:SetWrap(true)

    info:SetText(
        "Activate Orbital Input Mode, then enter orbital "
        .. "authorization codes using the four directional binds."
    )

    -----------------------------------------------------
    -- Binds
    -----------------------------------------------------

    CreateBindButton(
        BindWindow,
        "Toggle Orbital Mode",
        "toggle"
    )

    CreateBindButton(
        BindWindow,
        "Up",
        "up"
    )

    CreateBindButton(
        BindWindow,
        "Down",
        "down"
    )

    CreateBindButton(
        BindWindow,
        "Left",
        "left"
    )

    CreateBindButton(
        BindWindow,
        "Right",
        "right"
    )

end

---------------------------------------------------------
-- CONSOLE COMMAND
---------------------------------------------------------

concommand.Add(
    "orbital_controls",
    OpenOrbitalSettings
)

---------------------------------------------------------
-- C MENU BUTTON
---------------------------------------------------------

hook.Add("OnContextMenuOpen", "Orbital_CreateContextButton", function()

    if IsValid(ContextButton) then
        ContextButton:Remove()
    end

    ContextButton = vgui.Create("DButton")

    ContextButton:SetSize(
        180,
        40
    )

    ContextButton:SetPos(
        ScrW() - 200,
        100
    )

    ContextButton:SetText(
        "ORBITAL CONTROLS"
    )

    ContextButton:SetFont(
        "Trebuchet18"
    )

    ContextButton:SetDrawOnTop(true)

    ContextButton.DoClick = function()

        OpenOrbitalSettings()

    end

end)

---------------------------------------------------------
-- REMOVE BUTTON WHEN C MENU CLOSES
---------------------------------------------------------

hook.Add("OnContextMenuClose", "Orbital_RemoveContextButton", function()

    if IsValid(ContextButton) then

        ContextButton:Remove()

        ContextButton = nil

    end

end)