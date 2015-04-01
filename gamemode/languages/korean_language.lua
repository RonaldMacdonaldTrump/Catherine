--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Develop by L7D.

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

local LANGUAGE = catherine.language.New( "korean" )
LANGUAGE.name = "Korean(한국어)"
LANGUAGE.data = {
	[ "LanguageError01" ] = "언어 설정 오류",
	
	// Cash ^-^;
	[ "Cash_GiveMessage01" ] = "당신은 %s 님에게 %s 를 주셨습니다.",
	
	// Faction ^-^;
	[ "Faction_AddMessage01" ] = "Give faction",
	[ "Faction_RemoveMessage01" ] = "Take faction",	
	
	// Flag ^-^;
	[ "Flag_GiveMessage01" ] = "Give flag",
	[ "Flag_TakeMessage01" ] = "Take flag",
	
	[ "UnknownError" ] = "알 수 없는 오류 입니다.",
	[ "UnknownPlayerError" ] = "올바르지 않은 캐릭터 이름을 입력했습니다!",
	[ "ArgError" ] = "%s 번째 값을 입력하세요!"
}

catherine.language.Register( LANGUAGE )