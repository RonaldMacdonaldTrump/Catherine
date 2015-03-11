catherine.recognize = catherine.recognize or { }

function GM:ShowTeam( pl )
	netstream.Start( pl, "catherine.ShowTeam" )
end

if ( SERVER ) then
	function catherine.recognize.DoKnow( pl, talkCode, target )
		target = target or { }
		
		local classTab = catherine.chat.FindByClass( talkCode )
		if ( !classTab or ( classTab and !classTab.canHearRange ) ) then return end
		
		if ( type( target ) == "table" ) then
			for k, v in pairs( player.GetAll( ) ) do
				if ( !v:IsCharacterLoaded( ) ) then continue end
				if ( !v:Alive( ) or v == pl ) then continue end
				if ( pl:GetPos( ):Distance( v:GetPos( ) ) <= classTab.canHearRange and !catherine.recognize.IsKnowTarget( pl, v ) ) then
					target[ #target + 1 ] = v
				end
			end
		end
		
		if ( type( target ) == "table" ) then
			for k, v in pairs( target ) do
				if ( !IsValid( v ) ) then continue end
				catherine.recognize.DoDataSave( pl, target )
				catherine.recognize.DoDataSave( target, pl )
			end
		elseif ( type( target ) == "Player" ) then
			catherine.recognize.DoDataSave( pl, target )
			catherine.recognize.DoDataSave( target, pl )
		end
	end
	
	function catherine.recognize.DoDataSave( pl, target )
		if ( catherine.recognize.IsKnowTarget( pl, target ) ) then return end
		local recognize = table.Copy( catherine.character.GetCharacterVar( pl, "recognize", { } ) )
		if ( type( target ) == "table" ) then
			for k, v in pairs( target ) do
				recognize[ #recognize + 1 ] = v:GetCharacterID( )
			end
		elseif ( type( target ) == "Player" ) then
			recognize[ #recognize + 1 ] = target:GetCharacterID( )
		end
		catherine.character.SetCharacterVar( pl, "recognize", recognize )
	end
	
	function catherine.recognize.Init( pl )
		catherine.character.SetCharacterVar( pl, "recognize", { } )
	end
	
	netstream.Hook( "catherine.recognize.DoKnow", function( pl, data )
		catherine.recognize.DoKnow( pl, data[ 1 ], data[ 2 ] or nil )
	end )
	
	hook.Add( "PlayerDeath", "catherine.recognize.PlayerDeath", function( pl )
		catherine.recognize.Init( pl )
	end )
end

function catherine.recognize.IsKnowTarget( pl, target )
	if ( !IsValid( pl ) or !IsValid( target ) ) then return false end
	local recognize = catherine.character.GetCharacterVar( pl, "recognize", { } )
	if ( !recognize ) then return false end
	return table.HasValue( recognize, target:GetCharacterID( ) )
end

function GM:GetTargetInformation( pl, target )
	if ( pl == target ) then return { target:Name( ), target:Desc( ) } end
	if ( catherine.recognize.IsKnowTarget( pl, target ) ) then return { target:Name( ), target:Desc( ) }
	else return { "Unknown...", target:Desc( ) }
	end
	return { "Unknown...", target:Desc( ) }
end

if ( CLIENT ) then
	netstream.Hook( "catherine.ShowTeam", function( )
		local Menu = DermaMenu( )
		local ent = LocalPlayer( ):GetEyeTrace( 70 ).Entity
		
		Menu:AddOption( "Recognize for looking player.", function( )
			if ( !IsValid( ent ) ) then return end
			netstream.Start( "catherine.recognize.DoKnow", { "ic", ent } )
		end )
		Menu:AddOption( "All characters within talking range", function( )
			netstream.Start( "catherine.recognize.DoKnow", { "ic" } )
		end )
		Menu:AddOption( "All characters within whispering range.", function( )
			netstream.Start( "catherine.recognize.DoKnow", { "whisper" } )
		end )
		Menu:AddOption( "All characters within yelling range.", function( )
			netstream.Start( "catherine.recognize.DoKnow", { "yell" } )
		end )
		Menu:Open( )
		Menu:Center( )
	end )
end