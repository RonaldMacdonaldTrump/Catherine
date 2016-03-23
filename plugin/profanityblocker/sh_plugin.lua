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
	
	--[[
		누구나 욕을 많이 알고 있죠, 다만 쓰지 않을 뿐 입니다 ..
		^__^
	--]]
	local profanityList = {
		"병신",
		"씨발",
		"애미",
		"애비",
		"섹스",
		"미친",
		"시발",
		"개새끼",
		"새끼",
		"좆",
		"좃",
		"걸레년",
		"보지", // ^-^
		"자지", // ^-^
		"쎾쓰",
		"섹쓰",
		"ㄴㅇㅁ",
		"ㅅㅂ",
		"ㅄ",
		"ㅆㅂ",
		"ㅆㅃ",
		// 필터링 피할려고 별짓거리를 다해요.
		"ㅅ!ㅂ",
		"ㅅ1ㅂ",
		"ㅅ@ㅂ",
		"시!발",
		"시1발",
		"시@발",
		"씨1발",
		"씨!발",
		"씨@발",
		"병!신",
		"병1신",
		"병@신",
		"니애미", // 이 유행어를 만드신 김윤태씨에게 고개를 절래-절래 흔듭니다.
		"Sex",
		"Fuck",
		"Suck",
		"Motherfucker",
		"Mother fucker"
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
end