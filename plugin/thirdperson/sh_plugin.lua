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
PLUGIN.name = "^Thirdperson_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^Thirdperson_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "Option_Str_Thirdperson_Name" ] = "Enable Third Person",
	[ "Option_Str_Thirdperson_Desc" ] = "Enable the Third Person.",
	[ "Thirdperson_Plugin_Name" ] = "Third Person",
	[ "Thirdperson_Plugin_Desc" ] = "Good stuff."
} )

catherine.language.Merge( "korean", {
	[ "Option_Str_Thirdperson_Name" ] = "3인칭 활성화",
	[ "Option_Str_Thirdperson_Desc" ] = "3인칭을 활성화 합니다.",
	[ "Thirdperson_Plugin_Name" ] = "3인칭",
	[ "Thirdperson_Plugin_Desc" ] = "3인칭으로 플레이 할 수 있게 합니다."
} )

if ( SERVER ) then return end

CAT_CONVAR_THIRDPERSON = CreateClientConVar( "cat_convar_thirdperson", "0", true, true )
catherine.option.Register( "CONVAR_THIRD_PERSON", "cat_convar_thirdperson", "^Option_Str_Thirdperson_Name", "^Option_Str_Thirdperson_Desc", "^Option_Category_01", CAT_OPTION_SWITCH )

function PLUGIN:CalcView( pl, pos, ang, fov )
	if ( GetConVarString( "cat_convar_thirdperson" ) == "0" ) then return end
	local tr = util.TraceLine( {
		start = pos,
		endpos = pos - ( ang:Forward( ) * 100 )
	} )

	local data = {
		origin = tr.Fraction < 1 and ( tr.HitPos + tr.HitNormal * 5 ) or tr.HitPos,
		angles = ang,
		fov = fov
	}

	return {
		origin = tr.Fraction < 1 and ( tr.HitPos + tr.HitNormal * 5 ) or tr.HitPos,
		angles = ang,
		fov = fov
	}
end

function PLUGIN:ShouldDrawLocalPlayer( pl )
	if ( GetConVarString( "cat_convar_thirdperson" ) == "1" ) then
		return true
	end
end