if ( SERVER ) then
	local GetVelocity = FindMetaTable( "Entity" ).GetVelocity
	local Length2D = FindMetaTable( "Vector" ).Length2D
	
	hook.Add( "CharacterLoaded", "catherine.character.CharacterLoaded_2", function( pl, charID )
		local stamina = catherine.character.GetCharacterVar( pl, "stamina", 100 )
		catherine.character.SetCharacterVar( pl, "stamina", stamina )
	end )
	
	hook.Add( "PlayerSpawn", "catherine.character.PlayerSpawn_2", function( pl )
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
				local staminaDown = math.Clamp( catherine.character.GetCharacterVar( v, "stamina", 100 ) - 5, 0, 100 )
				if ( staminaDown < 10 ) then
					v.runSpeed = v:GetRunSpeed( )
					v:SetRunSpeed( v:GetWalkSpeed( ) )
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
					
					catherine.character.SetCharacterVar( v, "stamina", staminaUp )
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