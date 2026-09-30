local ignoredgroups = {
    ["user"] = true,
    ["vip"] = true,
}
hook.Add("PlayerSpawnProp", "propspawn_groups_only", function(ply, mdl)
    if (ignoredgroups[ply:GetUserGroup()]) then
        return false
    end
end)
hook.Add("PlayerSpawnRagdoll", "NoLosersAlllhjkowed", function(ply, mdl)
    if (ignoredgroups[ply:GetUserGroup()]) then
        return false
    end
end)
hook.Add("PlayerSpawnSENT", "AGAIlhjkNNONERDSSTUPID", function(ply, mdl)
    if (ignoredgroups[ply:GetUserGroup()]) then
        return false
    end
end)
hook.Add("PlayerSpawnEffect", "aseaseasdgfwwfg", function(ply, mdl)
    if (ignoredgroups[ply:GetUserGroup()]) then
        return false
    end
end)
hook.Add("PlayerSpawnNPC", "AGAIdfgdfgNNONERDSSTUPID", function(ply, mdl)
    if (ignoredgroups[ply:GetUserGroup()]) then
        return false
    end
end)
hook.Add("PlayerSpawnVehicle", "AGAINNONggdfgSTUPID", function(ply, mdl)
    if (ignoredgroups[ply:GetUserGroup()]) then
        return false
    end
end)
hook.Add("PlayerSpawnObject", "AGAINNONERDSSTUPID", function(ply, mdl)
    if (ignoredgroups[ply:GetUserGroup()]) then
        return false
    end
end)
hook.Add("PlayerSpawnSWEP", "AGAINNOjghfjNERDSSTUPID", function(ply, mdl)
    if (ignoredgroups[ply:GetUserGroup()]) then
        return false
    end
end)