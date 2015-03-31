catherine.command.Register( {
	command = "fallover",
	canRun = function( pl ) return pl:Alive( ) end,
	runFunc = function( pl, args )
		catherine.player.RagdollWork( pl, !catherine.player.IsRagdolled( pl ), args[ 1 ] )
	end
} )

catherine.command.Register( {
	command = "chargetup",
	canRun = function( pl ) return pl:Alive( ) end,
	runFunc = function( pl, args )
		if ( !pl.CAT_gettingup ) then
			if ( catherine.player.IsRagdolled( pl ) ) then
				pl.CAT_gettingup = true
				catherine.util.TopNotify( pl, false )
				catherine.util.ProgressBar( pl, "You are now getting up ...", 3, function( )
					catherine.player.RagdollWork( pl, false )
					pl.CAT_gettingup = nil
				end )
			else
				catherine.util.Notify( pl, "You are not fallovered!" )
			end
		else
			catherine.util.Notify( pl, "You are already getting uping!" )
		end
	end
} )