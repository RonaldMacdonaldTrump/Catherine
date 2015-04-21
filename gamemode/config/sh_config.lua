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
catherine.configs.defaultLanguage = "english"

catherine.configs.doorCost = 50
catherine.configs.doorSellCost = 25
catherine.configs.playerDefaultRunSpeed = 275
catherine.configs.playerDefaultWalkSpeed = 90
catherine.configs.defaultCash = 100
catherine.configs.cashName = "Dollars"
catherine.configs.cashModel = "models/props_lab/box01a.mdl"
catherine.configs.characterMenuMusic = "music/hl2_song19.mp3"
catherine.configs.baseInventoryWeight = 10
catherine.configs.characterNameMaxLen = 30
catherine.configs.characterNameMinLen = 10
catherine.configs.characterDescMaxLen = 54
catherine.configs.characterDescMinLen = 10
catherine.configs.spaceString = "kg"
catherine.configs.Font = "Segoe UI"
catherine.configs.schematicViewPos = { // for rp_c18_v1!
	pos = Vector( -18.818655, 898.651184, 354.860474 ),
	ang = Angle( 12.549129, -54.947598, 0.000000 )
}
catherine.configs.alwaysRaised = {
	weapon_physgun = true,
	gmod_tool = true
}
catherine.configs.frameworkLogo = "CAT/logos/2.png"

if ( SERVER ) then
	catherine.configs.defaultRPInformation = {
		year = 2015,
		minute = 1,
		day = 1,
		hour = 1,
		month = 1,
		second = 1,
		temperature = 25
	}
	catherine.configs.hintInterval = 30
	catherine.configs.netRegistryOptimizeInterval = 350
	catherine.configs.saveInterval = 300
	catherine.configs.voiceAllow = false
	catherine.configs.voice3D = true
	catherine.configs.giveHand = true
	catherine.configs.giveKey = true
	catherine.configs.spawnTime = 10
end