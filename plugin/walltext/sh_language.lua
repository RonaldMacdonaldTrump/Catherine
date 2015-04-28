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
	[ "WallText_Notify_Add" ] = "You have added text to your desired location.",
	[ "WallText_Notify_Remove" ] = "You have removed %s's texts.",
	[ "WallText_Notify_NoText" ] = "There are no texts at that location!",
	[ "WT_Plugin_Name" ] = "Wall Text",
	[ "WT_Plugin_Desc" ] = "Write text to wall."
} )

catherine.language.Merge( "korean", {
	[ "WallText_Notify_Add" ] = "해당 위치에 글씨를 추가했습니다.",
	[ "WallText_Notify_Remove" ] = "당신은 %s개의 글씨를 지웠습니다.",
	[ "WallText_Notify_NoText" ] = "해당 위치에는 글씨가 없습니다!",
	[ "WT_Plugin_Name" ] = "벽 글씨",
	[ "WT_Plugin_Desc" ] = "벽에 글씨를 쓸 수 있습니다."
} )