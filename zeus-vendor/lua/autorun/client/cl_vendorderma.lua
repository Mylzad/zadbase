-- Made by Mylzad https://steamcommunity.com/id/Mylzad/
AddCSLuaFile()

ZADVendor = ZADVendor or {}

net.Receive("ALCSVendorTable", function()
	if wOS.InventoryPanel != nil then
		if wOS.InventoryPanel:IsVisible() then
			wOS.InventoryPanel:Remove()
			wOS.MaterialPanel:Remove()
			gui.EnableScreenClicker( false )
			wOS.InventoryPanel = nil
			wOS.MaterialPanel = nil
		end
	end

	local itemtbl = net.ReadTable()

	local netmsginfo = {}

	if IsValid(ZADVendor.frame) then return end

	ZADVendor.frame = vgui.Create("DFrame")
	ZADVendor.frame:SetSize(ScrW()*.8, ScrH()*.85)
	ZADVendor.frame:Center()
	ZADVendor.frame:SetVisible(true)
	ZADVendor.frame:SetTitle("")
	ZADVendor.frame:SetDraggable(false)
	ZADVendor.frame.btnMinim:SetVisible(false)
	ZADVendor.frame.btnMaxim:SetVisible(false)
	ZADVendor.frame.btnClose:SetVisible(false)
	ZADVendor.frame:MakePopup()
	local ourMat = Material( "gui/gradient_up" )
	ZADVendor.frame.Paint = function( self, w, h )
		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial(Material( "zeus/vendor/Tex_1505_0.png" ))
		surface.DrawTexturedRect( 0, 0, w, h )
	end

	local closebtn = vgui.Create( "DButton", ZADVendor.frame)
	closebtn:SetSize( ZADVendor.frame:GetWide()*.03 , ZADVendor.frame:GetWide()*.03 )
	closebtn:SetFont("Trebuchet24")
	closebtn:SetText("")
	closebtn:SetTextColor(Color(255, 255, 255))
	closebtn:SetPos( ZADVendor.frame:GetWide()*.93, ZADVendor.frame:GetTall()*.05 )
	closebtn.Paint = function( self, w, h )
		surface.SetDrawColor(color_white)
		surface.SetMaterial(Material("zeus/vendor/zeusclosebtn.png"))
		surface.DrawTexturedRect( 0, 0, w, h )
		--draw.RoundedBox(0, 0, 0, 100, 50, Color( 150, 0 , 0 ) )
	end
	function closebtn:DoClick()
		sound.Play("Friends/friend_join.wav", LocalPlayer():GetPos())
	    ZADVendor.frame:Close()
		ZADVendor.frame = nil
	end

	local confirm = vgui.Create("DFrame")
	confirm:SetSize(ScrW()*.25, ScrH()*.25)
	confirm:Center()
	confirm:SetVisible(false)
	confirm:SetTitle("")
	confirm:SetDraggable(false)
	confirm.btnMinim:SetVisible(false)
	confirm.btnMaxim:SetVisible(false)
	confirm.btnClose:SetVisible(false)
	confirm.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50))
		draw.SimpleText("Are you sure?", "Trebuchet24", confirm:GetWide()*.4, confirm:GetTall()*.4)
		surface.SetDrawColor( 0, 0, 0 )
		surface.SetMaterial( ourMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end

	local yesbutton = vgui.Create("DButton", confirm)
	yesbutton:SetSize( confirm:GetWide()*.25 , 50 )
	yesbutton:SetFont("Trebuchet24")
	yesbutton:SetText("Yes")
	yesbutton:SetColor()
	yesbutton:SetTextColor(Color(255, 255, 255))
	yesbutton:SetPos( confirm:GetWide() - 150, confirm:GetTall() - 100 )
	yesbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 205, 50, 200 ))
		surface.SetDrawColor( 0, 0, 0 )
		surface.SetMaterial( ourMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	yesbutton.OnCursorEntered = function()
		yesbutton:SetTextColor(Color(200, 200, 255))
		sound.Play("wos/alcs/ui_rollover.wav", LocalPlayer():GetPos())
	end
	yesbutton.OnCursorExited = function()
		yesbutton:SetTextColor(Color(225, 225, 225))
	end
	function yesbutton:DoClick()
		if (netmsginfo == {}) then return end
		sound.Play("Friends/friend_join.wav", LocalPlayer():GetPos())
		net.Start(netmsginfo.message)
			net.WriteString(netmsginfo.args)
		net.SendToServer()
		confirm:SetVisible(false)
	end

	local nobutton = vgui.Create("DButton", confirm)
	nobutton:SetSize( confirm:GetWide()*.25, 50)
	nobutton:SetFont("Trebuchet24")
	nobutton:SetText("No")
	nobutton:SetTextColor(Color(225,225,225))
	nobutton:SetPos( 50, confirm:GetTall() - 100)
	nobutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 20, 60, 200 ))
		surface.SetDrawColor( 0, 0, 0 )
		surface.SetMaterial( ourMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	nobutton.OnCursorEntered = function()
		nobutton:SetTextColor(Color(200, 200, 255))
		sound.Play("wos/alcs/ui_rollover.wav", LocalPlayer():GetPos())
	end
	nobutton.OnCursorExited = function()
		nobutton:SetTextColor(Color(225, 225, 225))
	end
	function nobutton:DoClick()
		sound.Play("Friends/friend_join.wav", LocalPlayer():GetPos())
		confirm:SetVisible(false)
	end

	local numrarities = table.Count(ZADVendor.Prices)
	local spacing = ZADVendor.frame:GetWide()*.32

	for i=1, numrarities do

		local rarity = ZADVendor.Rarities[i]
		local sellallbutton = vgui.Create( "DButton", ZADVendor.frame)
		local rarityname = "None"

		if(rarity == "Legendary") then
			rarityname = "Legendarie"
		else
			rarityname = rarity
		end

		sellallbutton:SetSize( 200 , 50 )
		sellallbutton:SetText("")
		sellallbutton:SetTextColor(ZADVendor.Colors[rarity])
		sellallbutton:SetPos( ZADVendor.frame:GetWide() - spacing, ZADVendor.frame:GetTall()*.077 )
		sellallbutton:SetWrap(true)
		sellallbutton.Paint = function( self, w, h )
			surface.SetDrawColor( 255, 255, 255 )
			surface.SetMaterial( Material("zeus/vendor/tex_1501_0.png") )
			surface.DrawTexturedRect( 0, 0, w, h )
			draw.SimpleTextOutlined( "".."Sell all "..rarityname.."s".."", "Trebuchet24", w/2, h/2, sellallbutton:GetTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.5, Color(0,0,0,255))
		end
		function sellallbutton:DoClick()
			sound.Play("Friends/friend_join.wav", LocalPlayer():GetPos())
		    netmsginfo = {
		    	message = "ALCSSellAllType",
		    	args = ZADVendor.Rarities[i]
		    }
		    confirm:MakePopup()
		    confirm:SetVisible(true)
		end
		sellallbutton.OnCursorEntered = function()
			sellallbutton:SetTextColor( Color(150, 150, 255) )
			sound.Play("wos/alcs/ui_rollover.wav", LocalPlayer():GetPos())
		end
		sellallbutton.OnCursorExited = function()
			sellallbutton:SetTextColor( ZADVendor.Colors[rarity] )
		end
		spacing = spacing + ZADVendor.frame:GetWide()*.15
	end

	local ScrollPanel = vgui.Create( "DScrollPanel" , ZADVendor.frame)
	ScrollPanel:Dock( BOTTOM )
	ScrollPanel:SetPos( 10 , 10 )
	ScrollPanel:DockMargin(10, ZADVendor.frame:GetTall()*.83, ZADVendor.frame:GetWide()*.03, ZADVendor.frame:GetTall()*.0765)
	ScrollPanel:SetSize( ZADVendor.frame:GetWide(), ZADVendor.frame:GetTall()*.775 )

	local sbar = ScrollPanel:GetVBar()
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
	end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w+10, h+10, Color( 100, 100, 100 ) )
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w+10, h+10, Color( 100, 100, 100 ) )
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 75, 75, 75 ) )
	end

	local y = ScrollPanel:GetWide()*.02
	local length = table.Count(itemtbl)

	for i=1, length do

		local name = itemtbl[i].name
		local rarity = itemtbl[i].rarity
		local model = itemtbl[i].model
		local description = itemtbl[i].description

		local Panel = ScrollPanel:Add( "DPanel" )
		Panel:SetPos(ScrollPanel:GetWide()*.05, y)
		Panel:SetSize(ScrollPanel:GetWide()*.9 , ScrollPanel:GetWide()*.1 )
		Panel.Paint = function( self, w, h )
		end

		local PanelColored = vgui.Create( "DPanel", Panel)
		PanelColored:SetPos(Panel:GetWide()*.25, 0)
		PanelColored:SetSize(Panel:GetWide()*.5 , Panel:GetTall() )
		PanelColored.Paint = function( self, w, h )
			surface.SetMaterial( Material("zeus/vendor/tex_1597_0.png") )
			surface.SetDrawColor( 255, 255, 255 )
			surface.DrawTexturedRect( 0, 0, w, h )
		end

		local BuyButton = Panel:Add( "DButton" )
		BuyButton:SetText("")
		BuyButton:SetTextColor(Color(225, 225, 225))
		BuyButton:SetSize(Panel:GetTall() , Panel:GetTall()*.4)
		BuyButton:SetPos(Panel:GetWide()*.765 , Panel:GetTall()*.3)
		BuyButton.Paint = function( self, w, h )
			surface.SetDrawColor( 50, 205, 50 )
			surface.SetMaterial( Material("zeus/vendor/tex_1501_0.png") )
			surface.DrawTexturedRect( 0, 0, w, h )
			draw.SimpleTextOutlined( "".."Buy: $"..string.Comma(ZADVendor.Prices[rarity]).."", "Trebuchet24", w/2, h/2, BuyButton:GetTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.5, Color(0,0,0,255))
		end
		BuyButton.OnCursorEntered = function()
			BuyButton:SetTextColor(Color(200, 200, 255))
			sound.Play("wos/alcs/ui_rollover.wav", LocalPlayer():GetPos())
		end
		BuyButton.OnCursorExited = function()
			BuyButton:SetTextColor(Color(225, 225, 225))
		end
		BuyButton.DoClick = function()
			sound.Play("Friends/friend_join.wav", LocalPlayer():GetPos())
			netmsginfo = {
		    	message = "ALCSBuyItem",
		    	args = name
		    }
		    confirm:MakePopup()
		    confirm:SetVisible(true)
		end

		local SellButton = Panel:Add( "DButton" )
		SellButton:SetText( "" )
		SellButton:SetTextColor(Color(225, 225, 225))
		SellButton:SetSize(Panel:GetTall() , Panel:GetTall()*.4)
		SellButton:SetPos(Panel:GetWide()*.125 , Panel:GetTall()*.3)
		SellButton.Paint = function( self, w, h )
			surface.SetDrawColor( 255, 0, 0, 255 )
			surface.SetMaterial( Material("zeus/vendor/tex_1501_0.png") )
			surface.DrawTexturedRect( 0, 0, w, h )
			draw.SimpleTextOutlined( "".."Sell: $"..string.Comma(ZADVendor.Prices[rarity]*.5).."", "Trebuchet24", w/2, h/2, SellButton:GetTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.5, Color(0,0,0,255))
		end
		SellButton.OnCursorEntered = function()
			SellButton:SetTextColor(Color(200, 200, 255))
			sound.Play("wos/alcs/ui_rollover.wav", LocalPlayer():GetPos())
		end
		SellButton.OnCursorExited = function()
			SellButton:SetTextColor(Color(225, 225, 225))
		end
		SellButton.DoClick = function()
			sound.Play("Friends/friend_join.wav", LocalPlayer():GetPos())
			netmsginfo = {
		    	message = "ALCSSellItem",
		    	args = name
		    }
		    confirm:MakePopup()
		    confirm:SetVisible(true)
		end

		// Background for the item's 3d model
		local iconbackground = vgui.Create( "DPanel" , Panel)
		iconbackground:SetSize( Panel:GetTall()*.75 , Panel:GetTall()*.75 )
		iconbackground:SetPos( Panel:GetWide()*.35 - ((Panel:GetTall()*.9)*.5) , Panel:GetTall()*.1 )
		iconbackground.Paint = function ( self, w, h )
			surface.SetMaterial( Material("zeus/vendor/tex_1610_0.png") )
			surface.SetDrawColor( 255, 255, 255 )
			surface.DrawTexturedRect( 0, 0, w, h )
		end

		function GenerateView(Panel)
	    	pcall( function()
	    		local PrevMins, PrevMaxs = Panel.Entity:GetRenderBounds()
	        	Panel:SetCamPos(PrevMins:Distance(PrevMaxs)*Vector(1, 1, 1)*.6)
	        	Panel:SetLookAt((PrevMaxs + PrevMins)/2)
	    	end, Panel)
		end

		// The 3d model
		local icon = vgui.Create( "DModelPanel" , Panel)
		icon:SetSize( Panel:GetTall()*.65 , Panel:GetTall()*.73 )
		icon:SetPos( Panel:GetWide()*.355 - ((Panel:GetTall()*.9)*.5) , Panel:GetTall()*.1 )
		icon:SetModel( model )
		GenerateView(icon)

		// The Name of the Item (Has to be placed here to go above everything else)
		local ItemName = vgui.Create( "DPanel", Panel )
		ItemName:SetPos( Panel:GetWide()*.39, Panel:GetTall()*.1 )
		ItemName:SetSize( Panel:GetWide()*.34, Panel:GetTall()*.22 )
		ItemName.Paint = function( self, w, h )
			surface.SetMaterial( Material("zeus/vendor/tex_1540_0.png") )
			surface.SetDrawColor( 255, 255, 255 )
			surface.DrawTexturedRect( 0, 0, w, h )
			draw.SimpleTextOutlined( ""..name.."", "CloseCaption_Bold", w/2, h/2, ZADVendor.Colors[rarity], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.5, Color(0,0,0,255))
		end

		local ItemDescription = vgui.Create( "DLabel", Panel )
		ItemDescription:SetPos( Panel:GetWide()*.39, Panel:GetTall()*.3 )
		ItemDescription:SetSize( Panel:GetWide() * .34, Panel:GetTall()*.3 )
		ItemDescription:SetText("")
		ItemDescription.Paint = function( self, w, h )
			draw.SimpleTextOutlined( ""..description.."", "CloseCaption_Normal", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.5, Color(0,0,0,255))
		end

		y = y + (ScrollPanel:GetWide()*.12)

	end

end)
