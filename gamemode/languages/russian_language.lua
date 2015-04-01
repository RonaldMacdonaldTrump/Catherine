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

local LANGUAGE = catherine.language.New( "russian" )
LANGUAGE.name = "Russian"
LANGUAGE.data = {
	[ "LanguageError01" ] = "Error Language",
	
	// Cash ^-^;
	[ "Cash_GiveMessage01" ] = "Вы дали %s для %s",
	
	// Faction ^-^;
	[ "Faction_AddMessage01" ] = "Набор фракции",
	[ "Faction_RemoveMessage01" ] = "Возьмите фракцию",
	
	// Flag ^-^;
	[ "Flag_GiveMessage01" ] = "Дайте флаг",
	[ "Flag_TakeMessage01" ] = "Возьмите флаг",
	
	[ "UnknownError" ] = "Неизвестная ошибка!",
	[ "UnknownPlayerError" ] = "Вы не даете правильный имя персонажа!",
	[ "ArgError" ] = "Пожалуйста, введите %s аргумент!"
}

catherine.language.Register( LANGUAGE )
