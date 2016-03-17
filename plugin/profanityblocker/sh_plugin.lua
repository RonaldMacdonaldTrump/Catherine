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
PLUGIN.name = "^Profanity_Blocker_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^Profanity_Blocker_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "Profanity_Blocker_Plugin_Name" ] = "Profanity Blocker",
	[ "Profanity_Blocker_Plugin_Desc" ] = "Adding the Profanity Blocker.",
	[ "Profanity_Blocker_Warning" ] = "Do not use Profanity."
} )

catherine.language.Merge( "korean", {
	[ "Profanity_Blocker_Plugin_Name" ] = "욕설 차단",
	[ "Profanity_Blocker_Plugin_Desc" ] = "욕설 차단 시스템을 추가합니다.",
	[ "Profanity_Blocker_Warning" ] = "비속어를 사용하지 마십시오."
} )

if ( SERVER ) then
	local blockClasses = { "ooc", "looc" }
	local profanityList = {
		"병신",
		"씨발"
	}
	
	function PLUGIN:IsProfanity( text )
		for k, v in pairs( profanityList ) do
			if ( text:lower( ):find( v:lower( ) ) ) then
				return true
			end
		end
		
		return false
	end
	
	function PLUGIN:OnChatControl( chatInformation )
		local pl = chatInformation.pl
		local uniqueID = chatInformation.uniqueID
		
		if ( table.HasValue( blockClasses, uniqueID ) and self:IsProfanity( chatInformation.text ) ) then
			catherine.util.NotifyLang( pl, "Profanity_Blocker_Warning" )
			
			return false
		end
	end
else

end