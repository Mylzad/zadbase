// Made by Mylzad https://steamcommunity.com/id/Mylzad/

hook.Add("EntityTakeDamage", "ZADDMGRandomizer", function(target, dmgInfo)
	local damage = dmgInfo:GetBaseDamage()
	damage = math.Round(damage*(math.Rand(.95, 1.05)), 0)
	dmgInfo:SetDamage(damage)
end)