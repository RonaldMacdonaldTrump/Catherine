catherine.update = catherine.update or { }
catherine.update.VERSION = "2015-03-18"

if ( SERVER ) then
	catherine.update.LATESTVERSION = catherine.update.LATESTVERSION or nil
	catherine.update.Checked = catherine.update.Checked or false
	
	local checkURL = "htctJcpnyz:vaRG/OCENq/nTJXeTtbetsLVkeBvHRYubixWGCFWvJnKtfUgtsexJYWuOgatlvnmXOkpBJizmfJOuokrlUfjebtCkOsHPCoeSclMFWQetsMamafQnflUWyTrFtbGydUbFylJiyJeNrafFheVoNmAPznLpRfXlXjLrtWlsgicLflmRWPzcOk.bMzNsvPCazHQZIhIhqFcMRShzunPpypzLJFzWpnooGYxVGDOmxMvdSDVQnTAWOmpVBxCWssVGZpelFewnIcRN/MEoODmvPIgeWWVymkjfYmoDmNXRiOjQctjjAMHYiZIUpmuwr7yAPXjBJsZValiVzWGrNuqWkFD6fRgfMiZogfqfoJDyqiICzYzIVcjbJnfEbiVZqIZYjHGaGqyDWEmwLH/DUtKaghOZCwSkDwqhzVszkRDIuVfrlCexMtUZtgvlELiBwEoVzsbAaBWFoaaiLbLCbROUhcjtOHMxwOaDjGqNevYQwXnKXwCuwPcNBlOiztOybBPbesblgIjK"
	function catherine.update.Check( pl )
		http.Fetch( catherine.encrypt.Decode( checkURL ), 
			function( body )
				if ( body != catherine.update.VERSION ) then
					catherine.update.LATESTVERSION = body
					SetGlobalString( "catherine.update.LATESTVERSION", body )
					catherine.util.Print( Color( 0, 255, 0 ), "You can use the latest version of Catherine. - " .. body )
					if ( IsValid( pl ) ) then
						netstream.Start( pl, "catherine.update.CheckResult", { false, "You can use the latest version of Catherine. - " .. body } )
					end
				else
					catherine.update.LATESTVERSION = body
					SetGlobalString( "catherine.update.LATESTVERSION", body )
					if ( IsValid( pl ) ) then
						netstream.Start( pl, "catherine.update.CheckResult", { false, "You are using latest version of Catherine." } )
					end
				end
			end, function( err )
				catherine.util.Print( Color( 255, 0, 0 ), "Update check error! - " .. err )
				if ( IsValid( pl ) ) then
					netstream.Start( pl, "catherine.update.CheckResult", { false, "Update check error! - " .. err } )
				end
			end
		)
	end
	
	function catherine.update.PlayerAuthed( )
		if ( catherine.update.Checked ) then return end
		catherine.update.Check( )
		catherine.update.Checked = true
	end
	hook.Add( "PlayerAuthed", "catherine.update.PlayerAuthed", catherine.update.PlayerAuthed )
	
	netstream.Hook( "catherine.update.Check", function( pl )
		if ( !pl:IsSuperAdmin( ) ) then return end
		catherine.update.Check( pl )
	end )
else
	netstream.Hook( "catherine.update.CheckResult", function( data )
		if ( IsValid( catherine.vgui.version ) ) then
			catherine.vgui.version.status.status = data[ 1 ]
			catherine.vgui.version.status.text = data[ 2 ]
			catherine.vgui.version:Refresh( )
		end
		Derma_Message( data[ 2 ], "Check Result", "OK" )
	end )
end