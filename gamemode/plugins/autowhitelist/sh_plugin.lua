local PLUGIN = PLUGIN
PLUGIN.name = "Auto Whitelist"
PLUGIN.author = "L7D"
PLUGIN.desc = "Good stuff."

if ( SERVER ) then
	PLUGIN.enable = false
	PLUGIN.lists = {
		[ "cp" ] = 5000,
		[ "ow" ] = 240
	}
	PLUGIN.refreshTime = 50
	
	function PLUGIN:PlayerFirstSpawned( pl )
		if ( !self.enable ) then return end
		catherine.character.SetCharacterVar( pl, "aw_playTime", 0 )
	end
	
	function PLUGIN:PlayerSpawnedInCharacter( pl )
		if ( !self.enable ) then return end
		pl.CAT_aw_nextRefresh = pl.CAT_aw_nextRefresh or CurTime( ) + self.refreshTime
	end
	
	function PLUGIN:Think( )
		if ( !self.enable ) then return end
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			if ( !v.CAT_aw_nextRefresh ) then continue end
			if ( v.CAT_aw_nextRefresh <= CurTime( ) ) then
				local prevTime = catherine.character.GetCharacterVar( v, "aw_playTime", 0 )
				catherine.character.SetCharacterVar( v, "aw_playTime", prevTime + self.refreshTime )
				
				for k1, v1 in pairs( self.lists ) do
					local factionTable = catherine.faction.FindByID( k1 )
					if ( !factionTable or !factionTable.isWhitelist or catherine.faction.HasWhiteList( v, k1 ) ) then continue end
					if ( prevTime + self.refreshTime >= v1 ) then
						catherine.faction.AddWhiteList( v, k1 )
					end
				end
				v.CAT_aw_nextRefresh = CurTime( ) + self.refreshTime
			end
		end
	end
end