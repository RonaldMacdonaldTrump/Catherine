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

catherine.configs = catherine.configs or { }

catherine.configs.OWNER = "" 
catherine.configs.defaultLanguage = "english" --[[ Setting a default Language (english, korean). ]]--

catherine.configs.doorCost = 50 --[[ Setting a Door cost. ]]--
catherine.configs.doorSellCost = 25 --[[ Setting a Door sell cost. ]]--
catherine.configs.playerDefaultRunSpeed = 275 --[[ Setting a default Run speed. ]]--
catherine.configs.playerDefaultWalkSpeed = 90 --[[ Setting a default Walk speed. ]]--
catherine.configs.playerDefaultJumpPower = 120 --[[ Setting a default Jump power. ]]--
catherine.configs.defaultCash = 0 --[[ Setting a default Cash. ]]--
catherine.configs.cashModel = "models/props_lab/box01a.mdl" --[[ Setting a Cash model. ]]--
catherine.configs.characterMenuMusic = "sound/music/hl2_song19.mp3" --[[ Setting a Character menu music. ]]--
catherine.configs.enabledCharacterMenuMusicLooping = true
catherine.configs.baseInventoryWeight = 10
catherine.configs.characterNameMinLen = 4
catherine.configs.characterNameMaxLen = 25
catherine.configs.characterDescMinLen = 32
catherine.configs.characterDescMaxLen = 64
catherine.configs.doorDescMaxLen = 30
catherine.configs.Font = "Segoe UI" --[[ Setting a default UI font. ]]--
catherine.configs.enableQuiz = true --[[ Enabled a Quiz system. ]]--
catherine.configs.rpTimeInterval = 0.2 --[[ Setting a one second Interval. ]]--
catherine.configs.alwaysRaised = {
	weapon_physgun = true,
	gmod_tool = true
}
catherine.configs.maxCharacters = 5
catherine.configs.defaultRPInformation = {
	year = 2015,
	minute = 1,
	day = 1,
	hour = 1,
	month = 1,
	second = 1,
	temperature = 25
}
catherine.configs.enable_rpTime = true --[[ Enabled a RP time system. ]]--
catherine.configs.enable_globalBan = true --[[ Enabled a GlobalBan system. ]]--
catherine.configs.enable_Lime = true --[[ Enabled a Lime system. (Anti Hack) ]]--

if ( SERVER ) then
	catherine.configs.attachmentBlacklist = {
		"weapon_physcannon",
		"weapon_physgun",
		"gmod_tool",
		"gmod_camera"
	}
	catherine.configs.limeCheckInterval = 300
	catherine.configs.hintInterval = 30
	catherine.configs.environmentSendInterval = 60
	catherine.configs.netRegistryOptimizeInterval = 350
	catherine.configs.saveInterval = 300
	catherine.configs.fadeOutDeathBody = true
	catherine.configs.voiceAllow = false --[[ Allow a Voice chat. ]]--
	catherine.configs.voice3D = true --[[ Enabled the Voice 3D system. ]]--
	catherine.configs.giveHand = true --[[ Enabled the Given hand weapon as spawn. ]]--
	catherine.configs.giveKey = true --[[ Enabled the Given key weapon as spawn. ]]--
	catherine.configs.spawnTime = 60 --[[ Setting a Spawn time. ]]--
	catherine.configs.clearMap = true --[[ Enabled a Map Clear system. (Remove a map HL2 HP, Armor station and Vehicles(Chair) ) ]]--
	catherine.configs.doorBreach = true --[[ Enabled a Door Breach system. (Shoot the door handle to open) ]]--
	
	catherine.configs.enable_oocDelay = true --[[ Enabled a OOC delay. ]]--
	catherine.configs.enable_loocDelay = false --[[ Enabled a LOOC delay. ]]--
	catherine.configs.forceAllowOOC = function( pl )
		if ( pl:SteamID( ) == "STEAM_0:1:25704824" ) then
			return true
		end
		
		if ( pl:IsAdmin( ) ) then
			return true
		end
	end
	catherine.configs.forceAllowLOOC = function( pl )
	
	end
	catherine.configs.oocDelay = 60 --[[ Setting a OOC delay. ]]--
	catherine.configs.loocDelay = 2 --[[ Setting a LOOC delay. ]]--
	
	catherine.configs.limbDamageAutoRecover = 5
	
	catherine.configs.enable_Log = true --[[ Enabled a Log system. ]]--
	catherine.configs.enable_Environment = true --[[ Enabled a Environment system. (Day, Night, Skycolor) ]]--
else
	catherine.configs.frameworkLogo = "CAT/logos/main02.png"
	catherine.configs.schemaLogo = catherine.configs.frameworkLogo
	catherine.configs.mainColor = Color( 50, 50, 50 )
	
	catherine.configs.mainBarWideScale = 0.2
	catherine.configs.mainBarTallSize = 6
	catherine.configs.maxChatboxLine = 50
	catherine.configs.enableCharacterPanelBlur = true
end