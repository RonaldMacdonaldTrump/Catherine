if ( SERVER ) then
	local GetVelocity = FindMetaTable( "Entity" ).GetVelocity
	local Length2D = FindMetaTable( "Vector" ).Length2D
	
	hook.Add( "PlayerSpawnedInCharacter", "catherine.stamina.PlayerSpawnedInCharacter", function( pl, charID )
		local stamina = catherine.character.GetCharacterVar( pl, "stamina", 100 )
		catherine.character.SetCharacterVar( pl, "stamina", stamina )
	end )
	
	hook.Add( "PlayerSpawn", "catherine.stamina.PlayerSpawn", function( pl )
		catherine.character.SetCharacterVar( pl, "stamina", 100 )
	end )

	hook.Add( "Think", "catherine.stamina.Think", function( )
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			if ( v:GetMoveType( ) == MOVETYPE_NOCLIP ) then continue end
			local speed = Length2D( GetVelocity( v ) )
			if ( !v.nextStaminaDown or !v.nextStaminaUp ) then
				v.nextStaminaDown = CurTime( ) + 1
				v.nextStaminaUp = CurTime( ) + 3
			end
			if ( v:IsRunning( ) and v.nextStaminaDown <= CurTime( ) ) then
				local staminaDown = math.Clamp( catherine.character.GetCharacterVar( v, "stamina", 100 ) + ( -10 + math.min( ( catherine.attribute.GetProgress( v, CAT_ATT_STAMINA ) ) * 0.25, 7.5 ) ), 0, 100 )
				if ( staminaDown < 10 ) then
					v.runSpeed = v:GetRunSpeed( )
					v:SetRunSpeed( v:GetWalkSpeed( ) )
					catherine.attribute.AddProgress( v, CAT_ATT_STAMINA, 0.09 )
				else
					catherine.character.SetCharacterVar( v, "stamina", staminaDown )
				end
				v.nextStaminaDown = CurTime( ) + 1
			else
				if ( v.nextStaminaUp <= CurTime( ) ) then
					local staminaUp = math.Clamp( catherine.character.GetCharacterVar( v, "stamina", 100 ) + 5, 0, 100 )
					if ( staminaUp >= 100 ) then
						v:SetRunSpeed( catherine.configs.playerDefaultRunSpeed )
					end
					
					if ( staminaUp != catherine.character.GetCharacterVar( v, "stamina", 100 ) ) then
						catherine.character.SetCharacterVar( v, "stamina", staminaUp )
					end
					v.nextStaminaUp = CurTime( ) + 3
				end
			end
		end
	end )
else
	catherine.bar.Add( function( )
		return catherine.character.GetCharacterVar( LocalPlayer( ), "stamina", 100 )
	end, function( )
		return 100
	end, "", Color( 0, 206, 209 ), "stamina" )
end

CAT_ATT_STAMINA = catherine.attribute.Register( "stamina", "Stamina", "How long you can run for.", "CAT/attribute/stamina.png", 0, 100 )