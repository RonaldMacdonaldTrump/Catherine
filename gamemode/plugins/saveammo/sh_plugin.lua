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
PLUGIN.name = "Save Ammo"
PLUGIN.author = "L7D"
PLUGIN.desc = "Good stuff."

if ( CLIENT ) then return end

local Ammo_Types = {
	"ar2",
	"alyxgun",
	"pistol",
	"smg1",
	"357",
	"xbowbolt",
	"buckshot",
	"rpg_round",
	"smg1_grenade",
	"sniperround",
	"sniperpenetratedround",
	"grenade",
	"thumper",
	"gravity",
	"battery",
	"gaussenergy",
	"combinecannon",
	"airboatgun",
	"striderminigun",
	"helicoptergun",
	"ar2altfire",
	"slam"
}

function PLUGIN:PostCharacterSave( pl )
	local wep, tab = pl:GetActiveWeapon( ), { }
	for k, v in pairs( Ammo_Types ) do
		local ammoCount = pl:GetAmmoCount( v )
		if ( ammoCount > 0 ) then
			tab[ v ] = ammoCount
		end
	end
	catherine.character.SetCharVar( pl, "ammos", tab )
end

function PLUGIN:PlayerSpawnedInCharacter( pl )
	pl:RemoveAllAmmo( )
	local ammoData = catherine.character.GetCharVar( pl, "ammos", { } )
	for k, v in pairs( ammoData ) do
		pl:SetAmmo( tonumber( v ) or 0, k )
	end
	catherine.character.SetCharVar( pl, "ammos", nil )
end