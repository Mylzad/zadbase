include( "shared.lua" )

surface.CreateFont( "Player", {
    font = "Trebuchet MS",
    size = 1000,
})

function ENT:Draw()

    self:DrawModel()

    if ( IsValid( self ) && LocalPlayer():GetPos():Distance( self:GetPos() ) < 500 ) then

        local ang = Angle( 0, ( LocalPlayer():GetPos() - self:GetPos() ):Angle()[ "yaw" ], ( LocalPlayer():GetPos() - self:GetPos() ):Angle()[ "pitch" ] ) + Angle( 0, 90, 90 )

        cam.IgnoreZ( false )
        cam.Start3D2D( self:GetPos() + Vector( 0, 0, 78 ), ang, 0.1 )
            draw.SimpleText( "Vending Machine", "Player", 0, 0, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        cam.End3D2D()

    end

end
