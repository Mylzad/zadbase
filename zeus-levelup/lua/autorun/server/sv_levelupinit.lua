// Written by Mylzad: https://steamcommunity.com/id/Mylzad/

local meta = FindMetaTable("Player")

util.AddNetworkString( "wOS.LeveledUp" )

hook.Add("wOS.ALCS.PostLoaded", "Adding Level Hook", function()
    function meta:SkillLevelUp()

        self:SetSkillLevel( self:GetSkillLevel() + 1 )
        self:SendLua( [[ surface.PlaySound( "buttons/button24.wav" ) ]] )

        if self:GetSkillLevel() % wOS.ALCS.Config.Skills.LevelsPerSkillPoint == 0 then
            self:AddSkillPoints( wOS.ALCS.Config.Skills.SkillPointPerLevel )
            self:SendLua( [[ notification.AddLegacy( "[wOS] You've earned a skill point! Spend it at a Skill Station", NOTIFY_GENERIC, 3 ) ]] )
        end

        hook.Call("PostPlayerALCSLevel", nil, self, self:GetSkillLevel())

        net.Start("wOS.LeveledUp")
        	net.WriteEntity(self)
        net.Broadcast()

        self:CheckSkillLevel()
    end
end)