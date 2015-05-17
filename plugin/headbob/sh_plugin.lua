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
PLUGIN.name = "^HB_Plugin_Name"
PLUGIN.author = "L7D, Black Tea"
PLUGIN.desc = "^HB_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "HB_Plugin_Name" ] = "Head Bob",
	[ "HB_Plugin_Desc" ] = "Good stuff.",
	[ "Option_Str_HB_Name" ] = "Enable Head Bob",
	[ "Option_Str_HB_Desc" ] = "Enable head bob for player."
} )

catherine.language.Merge( "korean", {
	[ "HB_Plugin_Name" ] = "다리",
	[ "HB_Plugin_Desc" ] = "캐릭터 밑에 다리를 표시합니다.",
	[ "Option_Str_HB_Name" ] = "머리 흔들림 활성화",
	[ "Option_Str_HB_Desc" ] = "움직일 때 머리가 흔들리는 효과를 활성화 합니다."
} )

if ( SERVER ) then return end

CAT_CONVAR_HEADBOB = CreateClientConVar( "cat_convar_headbob", "1", true, true )
catherine.option.Register( "CONVAR_HEADBOB", "cat_convar_headbob", "^Option_Str_HB_Name", "^Option_Str_HB_Desc", "^Option_Category_01", CAT_OPTION_SWITCH )

local curAng = Angle( 0, 0, 0 )
local targetAng = Angle( 0, 0, 0 )

function PLUGIN:CalcView( pl, pos, ang, fov )
	local ft = FrameTime( )

	if ( pl:IsOnGround( ) ) then
		targetAng.y = ( 2 / 1 ) * math.sin( CurTime( ) / 2 )
	end
	
	curAng = Lerp( ft * 10, curAng, targetAng )

	local data = {
		angles = ang + curAng,
		origin = pos,
		fov = fov
	}

	return GAMEMODE:CalcView( pl, data.origin, data.angles, data.fov )
end