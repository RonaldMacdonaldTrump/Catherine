local Plugin = Plugin

Plugin.name = "Save Ammo"
Plugin.author = "L7D"
Plugin.desc = "Good stuff."

if ( SERVER ) then
	local Ammo_Types = {
		"ar2",
		"alyxgun",
		"pistol",
		"smg1",
		"357",
		"xbowbolt",
		"buckshot",
		"rpg_round",
		"smg1_grenade",
		"sniperround",
		"sniperpenetratedround",
		"grenade",
		"thumper",
		"gravity",
		"battery",
		"gaussenergy",
		"combinecannon",
		"airboatgun",
		"striderminigun",
		"helicoptergun",
		"ar2altfire",
		"slam"
	}
	
	function Plugin:PostCharacterSave( pl )
		local wep, tab = pl:GetActiveWeapon( ), { }
		for k, v in pairs( Ammo_Types ) do
			local int = pl:GetAmmoCount( v )
			if ( int > 0 ) then
				tab[ v ] = int
			end
		end
		catherine.character.SetCharacterVar( pl, "ammos", tab )
	end
	
	function Plugin:PlayerSpawnedInCharacter( pl )
		pl:RemoveAllAmmo( )
		local ammoData = catherine.character.GetCharacterVar( pl, "ammos", { } )
		for k, v in pairs( ammoData ) do
			pl:SetAmmo( tonumber( v ) or 0, k )
		end
		catherine.character.SetCharacterVar( pl, "ammos", nil )
	end
end