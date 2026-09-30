-- Made by ZeusAKADelta https://steamcommunity.com/id/ZeusAKADelta/
AddCSLuaFile()

ZADVendor = ZADVendor or {}

wOS = wOS or {}

ZADVendor.Colors = {
	["Legendary"] = Color(255, 215, 0, 255), -- Yellow
	["Epic"] = Color(186, 85, 211, 255), -- Purple
	["Rare"] = Color(30, 144, 255, 255), -- Blue
	["Common"] = Color(75, 75, 75, 255) -- Grey (leave alone)
}

ZADVendor.Prices = {
	["Legendary"] = 2500000,
	["Epic"] = 750000,
	["Rare"] = 3000,
	["Common"] = 300
}

ZADVendor.Rarities = {
	"Legendary",
	"Epic",
	"Rare",
	"Common"
}

ZADVendor.IgnoredItems = {
	
}

ZADVendor.Items = {}