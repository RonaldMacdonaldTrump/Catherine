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

concommand.Add( "cat_ws_selectWeapon", function( pl, _, args )
	pl:SelectWeapon( args[ 1 ] )
end )

function PLUGIN:PlayerSpawnedInCharacter( pl )
	timer.Simple( 1, function( )
		netstream.Start( pl, "catherine.plugin.weaponselect.Refresh", {
			4
		} )
	end )
end

function PLUGIN:PlayerRagdollJoined( pl )
	netstream.Start( pl, "catherine.plugin.weaponselect.Refresh", {
		3
	} )
end

function PLUGIN:PlayerGiveWeapon( pl, uniqueID )
	if ( !IsValid( pl ) or !pl:IsCharacterLoaded( ) ) then return end

	timer.Simple( 0.05, function( )
		netstream.Start( pl, "catherine.plugin.weaponselect.Refresh", {
			1,
			uniqueID
		} )
	end )
end

function PLUGIN:PlayerStripWeapon( pl, uniqueID )
	if ( !IsValid( pl ) ) then return end

	netstream.Start( pl, "catherine.plugin.weaponselect.Refresh", {
		2,
		uniqueID
	} )
end