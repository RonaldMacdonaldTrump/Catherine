--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

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
		catherine.character.SetCharVar( pl, "aw_playTime", 0 )
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
				local prevTime = catherine.character.GetCharVar( v, "aw_playTime", 0 )
				catherine.character.SetCharVar( v, "aw_playTime", prevTime + self.refreshTime )
				
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