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
PLUGIN.name = "^SA_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^SA_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "SA_Plugin_Name" ] = "Save Ammo",
	[ "SA_Plugin_Desc" ] = "Good stuff."
} )

catherine.language.Merge( "korean", {
	[ "SA_Plugin_Name" ] = "탄약 저장",
	[ "SA_Plugin_Desc" ] = "플레이어의 탄약을 저장합니다."
} )

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
	local tab = { }
	
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

	for k, v in pairs( catherine.character.GetCharVar( pl, "ammos", { } ) ) do
		pl:SetAmmo( tonumber( v ) or 0, k )
	end
	
	catherine.character.SetCharVar( pl, "ammos", nil )
end