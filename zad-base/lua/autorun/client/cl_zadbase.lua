net.Receive("ZADMessage", function()
	local temp = net.ReadTable()
	chat.AddText(unpack(temp))
	return
end)

net.Receive("ZADPlaySound", function()
	local temp = net.ReadString()
	sound.Play(temp, LocalPlayer():GetPos())
end)
