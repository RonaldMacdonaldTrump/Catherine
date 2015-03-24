catherine.configs = catherine.configs or { }

catherine.configs.doorCost = 50
catherine.configs.doorSellCost = 25
catherine.configs.playerDefaultRunSpeed = 275
catherine.configs.playerDefaultWalkSpeed = 90
catherine.configs.defaultCash = 100
catherine.configs.cashName = "Dollars"
catherine.configs.cashModel = "models/props_lab/box01a.mdl"
catherine.configs.schemaImage = ""
catherine.configs.saveInterval = 300
catherine.configs.giveHand = true
catherine.configs.giveKey = true
catherine.configs.spawnTime = 10
catherine.configs.characterMenuMusic = "music/hl2_song19.mp3"
catherine.configs.baseInventoryWeight = 10
catherine.configs.characterNameMaxLen = 30
catherine.configs.characterNameMinLen = 10
catherine.configs.characterDescMaxLen = 54
catherine.configs.characterDescMinLen = 10
catherine.configs.alwaysRaised = {
	weapon_physgun = true,
	gmod_tool = true
}
catherine.configs.spaceString = "kg"
catherine.configs.Font = "Segoe UI"

if ( SERVER ) then
	catherine.configs.hintInterval = 30
end