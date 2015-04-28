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

catherine.language.Merge( "english", {
	[ "Spawnpoint_Notify_Add" ] = "You added spawnpoint for '%s' faction.",
	[ "Spawnpoint_Notify_Remove" ] = "You removed %s's spawn points.",
	[ "Spawnpoint_Notify_Remove_No" ] = "This place hasn't spawnpoint!",
	[ "SPP_Plugin_Name" ] = "Spawn Point",
	[ "SPP_Plugin_Desc" ] = "Good stuff."
} )

catherine.language.Merge( "korean", {
	[ "Spawnpoint_Notify_Add" ] = "당신은 '%s' 팩션을 위한 스폰 포인트를 추가했습니다.",
	[ "Spawnpoint_Notify_Remove" ] = "당신은 %s개의 스폰 포인트를 지웠습니다.",
	[ "Spawnpoint_Notify_Remove_No" ] = "이 장소에는 스폰 포인트가 없습니다!",
	[ "SPP_Plugin_Name" ] = "스폰 포인트",
	[ "SPP_Plugin_Desc" ] = "팩션에 따른 스폰 포인트를 지정할 수 있습니다."
} )