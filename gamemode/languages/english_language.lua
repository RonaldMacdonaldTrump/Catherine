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

local LANGUAGE = catherine.language.New( "english" )
LANGUAGE.name = "English"
LANGUAGE.data = {
	[ "LanguageError01" ] = "Error Language",
	
	// Cash ^-^;
	[ "Cash_GiveMessage01" ] = "You have given %s to %s",
	
	// Faction ^-^;
	[ "Faction_AddMessage01" ] = "Set faction",
	[ "Faction_RemoveMessage01" ] = "Take faction",
	
	// Flag ^-^;
	[ "Flag_GiveMessage01" ] = "Give flag",
	[ "Flag_TakeMessage01" ] = "Take flag",
	
	[ "UnknownError" ] = "Unknown Error!",
	[ "UnknownPlayerError" ] = "You are not giving a valid character name!",
	[ "ArgError" ] = "Please enter the %s argument!",
	
	
	
	
	
	// Version
	[ "Version_UI_Title" ] = "Version",
	[ "Version_UI_LatestVer_AV" ] = "Latest Version - %s",
	[ "Version_UI_LatestVer_NO" ] = "Latest Version - None",
	[ "Version_UI_YourVer_AV" ] = "Your Version - %s",
	[ "Version_UI_YourVer_NO" ] = "Your Version - None",
	[ "Version_UI_Checking" ] = "Checking update ...",
	[ "Version_UI_CheckButtonStr" ] = "Update Check",
	// Version Notify
	[ "Version_Notify_FoundNew" ] = "You should update to the latest version of Catherine. - %s",
	[ "Version_Notify_AlreadyNew" ] = "You are using the latest version of Catherine.",
	[ "Version_Notify_CheckError" ] = "Update check error! - %s",
	
	// Attribute
	[ "Attribute_UI_Title" ] = "Attribute",
	// Attribute Notify
	
	
	// Basic
	[ "Basic_UI_Notify" ] = "Notify",
	[ "Basic_UI_OK" ] = "OK",
	[ "Basic_UI_YES" ] = "YES",
	[ "Basic_UI_NO" ] = "NO"
}

catherine.language.Register( LANGUAGE )