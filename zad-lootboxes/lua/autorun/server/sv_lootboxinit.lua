util.AddNetworkString( "ZeusItemReceived" )

hook.Add("wOS.ALCS.PostLoaded", "ParsingLootboxLoot", function()
	RegisterZADBoxes()
end)

hook.Add( "OnNPCKilled", "LootBoxHook", function( npc, killer )
    local tester = false

    if(ZADBase.NPCInfo[npc:GetClass()] != nil) then 
        tester = ZADBase.NPCInfo[ZADBase.NPCInfo[npc:GetClass()]].Boss
    end

    if(tester) then
        if IsValid( killer ) && killer:IsPlayer() then
            local Box = ents.Create( "zeusboxes_bossloot" )
            Box:SetPos( npc:LocalToWorld( Vector( 0, 0, 0 ) ) )
            Box:Spawn()
            Box:Activate()
            if not (ZADBase.AutoRemove) then return end // If the autoremove timer is set to false, end the function
            SafeRemoveEntityDelayed( Box , ZADBase.AutoRemove ) // If the function has not ended, then set the timer to auto-delete
        end
    else
        if IsValid( killer ) && killer:IsPlayer() then
            local Box = ents.Create( "zeusboxes" )
            Box:SetPos( npc:LocalToWorld( Vector( 0, 0, 0 ) ) )
            Box:Spawn()
            Box:Activate()
            if not (ZADBase.AutoRemove) then return end // If the autoremove timer is set to false, end the function
            SafeRemoveEntityDelayed( Box , ZADBase.AutoRemove ) // If the function has not ended, then set the timer to auto-delete
        end
    end

end)

function RegisterZADBoxes()
    print("[ZADBase] Starting Lootbox Parsing!")
    ZADBase.LootTableColors = {}
    for id, item in pairs( wOS.ItemIDTranslations ) do
        local itemdata = wOS:GetItemData(item)

        if not table.HasValue(ZADBase.RarityNames, itemdata.RarityName) then continue end
        if (ZADBase.IgnoredItems[item]) then continue end
        if itemdata.Type == WOSTYPE.ARMOR or itemdata.Type == WOSTYPE.HELMET then continue end

        if(ZADBase[itemdata.RarityName.."Table"] != nil) then
            table.insert(ZADBase[itemdata.RarityName.."Table"], table.Count(ZADBase[itemdata.RarityName.."Table"]) + 1, itemdata.Name)
        else
            ZADBase[itemdata.RarityName.."Table"] = {itemdata.Name}
        end
        if (itemdata.RarityColor == nil) then continue end
        if (ZADBase.LootTableColors[itemdata.RarityName] != nil) then continue end

        print("[ZADBase] Adding color for rarity "..itemdata.RarityName)

        ZADBase.LootTableColors[itemdata.RarityName] = itemdata.RarityColor
    end
end