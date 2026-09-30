// Written by Mylzad: https://steamcommunity.com/id/Mylzad/

local leveleffect = true

ZADEffect = {
    ["Sith Empire"] = "_shadow_hide",
    ["Jedi Order"] = "_wraith_hide"
}

concommand.Add( "wos_toggleleveleffect", function( ply, cmd, args )
    leveleffect = !leveleffect
end)

net.Receive("wOS.LeveledUp", function()
    local ply = net.ReadEntity()
    local teamabc = ply:getJobTable().category
    local particle = "[5]starfield_2"

    if (ZADEffect[teamabc] != nil) then
        particle = ZADEffect[teamabc]
    else 
    	particle = "_ghost_upgrade"
    	return end

    if(leveleffect) then
        local effect = ply:CreateParticleEffect( particle, 0 )

        effect:AddControlPoint( 0, ply, PATTACH_ABSORIGIN_FOLLOW, 0, Vector(0, 0, 80) )
        effect:StartEmission(false)
        timer.Simple( 3 , function()
            effect:StopEmission(false, false, false)
        end)
    end

    if not (LocalPlayer() == ply) then return end
    
    local w = ScrW()
    local h = ScrH()

    local frame = vgui.Create( "DFrame" )
    frame:SetSize( w*.5, w*.5 )
    frame:SetTitle( "" )
    frame:Center()
    frame:SetVisible( true )
    frame:SetDraggable( false )
    frame:ShowCloseButton( false )
    frame:MakePopup()
    frame:SetMouseInputEnabled(false)
    frame:SetKeyboardInputEnabled(false)
    frame.Paint = function( self, w, h )
    end

    local icon = vgui.Create( "DPanel", frame)
    icon:SetSize( frame:GetTall()*.244 , frame:GetTall()*.219 )
    local iconsizex,iconsizey = icon:GetSize()
    icon:SetPos( (frame:GetWide()/2)-iconsizex/2, (frame:GetTall()/2)-iconsizey/2-iconsizey*.4 )
    icon.Paint = function ( self, w, h )
            surface.SetMaterial( Material("reborn/rebornlogo2.png") )
            surface.SetDrawColor( 255, 255, 255 )
            surface.DrawTexturedRect(0, 0, w, h )
    end

    local text = vgui.Create ("DPanel", frame)
    text:SetSize( frame:GetWide()/2 , frame:GetTall()/2 )
    text:SetPos( (frame:GetWide()/4), (frame:GetTall()/3) )
    text.Paint = function ( self, w, h )
        draw.SimpleTextOutlined( "".."   You have leveled up! Your Combat Level is now "..ply:GetSkillLevel().."", "Trebuchet24", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.5, Color(0,0,0,255))
    end

    timer.Simple(5, function()
        frame:Remove()
    end)

end)