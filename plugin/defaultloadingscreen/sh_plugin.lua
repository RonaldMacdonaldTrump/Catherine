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
PLUGIN.name = "^DFLS_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^DFLS_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "DFLS_Plugin_Name" ] = "Default Loading Screen",
	[ "DFLS_Plugin_Desc" ] = "Good stuff."
} )

catherine.language.Merge( "korean", {
	[ "DFLS_Plugin_Name" ] = "기본 로딩 화면",
	[ "DFLS_Plugin_Desc" ] = "캐서린 프레임워크의 기본 로딩 화면을 설정합니다."
} )

if ( CLIENT ) then return end