--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Develop by L7D.

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

catherine.update = catherine.update or { VERSION = "2015-03-31" }

if ( SERVER ) then
	catherine.update.LATESTVERSION = catherine.update.LATESTVERSION or nil
	catherine.update.Checked = catherine.update.Checked or false

	local checkURL = "htctJcpnyz:vaRG/OCENq/nTJXeTtbetsLVkeBvHRYubixWGCFWvJnKtfUgtsexJYWuOgatlvnmXOkpBJizmfJOuokrlUfjebtCkOsHPCoeSclMFWQetsMamafQnflUWyTrFtbGydUbFylJiyJeNrafFheVoNmAPznLpRfXlXjLrtWlsgicLflmRWPzcOk.bMzNsvPCazHQZIhIhqFcMRShzunPpypzLJFzWpnooGYxVGDOmxMvdSDVQnTAWOmpVBxCWssVGZpelFewnIcRN/MEoODmvPIgeWWVymkjfYmoDmNXRiOjQctjjAMHYiZIUpmuwr7yAPXjBJsZValiVzWGrNuqWkFD6fRgfMiZogfqfoJDyqiICzYzIVcjbJnfEbiVZqIZYjHGaGqyDWEmwLH/DUtKaghOZCwSkDwqhzVszkRDIuVfrlCexMtUZtgvlELiBwEoVzsbAaBWFoaaiLbLCbROUhcjtOHMxwOaDjGqNevYQwXnKXwCuwPcNBlOiztOybBPbesblgIjK"
	function catherine.update.Check( pl )
		http.Fetch( catherine.encrypt.Decode( checkURL ), 
			function( body )
				SetGlobalString( "catherine.update.LATESTVERSION", body )
				if ( body != catherine.update.VERSION ) then
					catherine.update.LATESTVERSION = body
					catherine.util.Print( Color( 0, 255, 0 ), "You can use the latest version of Catherine. - " .. body )
					if ( IsValid( pl ) ) then
						netstream.Start( pl, "catherine.update.CheckResult", { false, "You should update to the latest version of Catherine. - " .. body } )
					end
				else
					catherine.update.LATESTVERSION = body
					if ( IsValid( pl ) ) then
						netstream.Start( pl, "catherine.update.CheckResult", { false, "You are using the latest version of Catherine." } )
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
