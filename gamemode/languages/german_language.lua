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

local LANGUAGE = catherine.language.New( "german" )
LANGUAGE.name = "German"
LANGUAGE.data = {
	[ "LanguageError01" ] = "Error Language",
	
	// Cash ^-^;
	[ "Cash_GiveMessage01" ] = "Du hast %s an %s überwiesen.",
	
	// Faction ^-^;
	[ "Faction_AddMessage01" ] = "Setze die Fraktion",
	[ "Faction_RemoveMessage01" ] = "Entferne die Fraktion",
	
	// Flag ^-^;
	[ "Flag_GiveMessage01" ] = "Füge flag hinzu",
	[ "Flag_TakeMessage01" ] = "Entferne flag",
	
	[ "UnknownError" ] = "Unbekannter Fehler.",
	[ "UnknownPlayerError" ] = "Der eingegebende Name ist ungültig!",
	[ "ArgError" ] = "%s Bitte füge ein zweites Argument hinzu!"
}

catherine.language.Register( LANGUAGE )