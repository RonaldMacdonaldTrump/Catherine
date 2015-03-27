catherine.configs = catherine.configs or { }

catherine.configs.OWNER = ""

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
catherine.configs.schematicViewPos = { // for rp_c18_v1!
	pos = Vector( 339.375244, -101.734825, 1207.814819 ),
	ang = Angle( 33.188992, -139.331573, 0.000000 )
}


if ( SERVER ) then
	catherine.configs.hintInterval = 30
end