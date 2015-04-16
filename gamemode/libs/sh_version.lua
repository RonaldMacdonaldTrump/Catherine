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

catherine.version = catherine.version or { Ver = "2015-04-16" }

if ( SERVER ) then
	catherine.version.Checked = catherine.version.Checked or false
	local serverURL = "htctJcpnyz:vaRG/OCENq/nTJXeTtbetsLVkeBvHRYubixWGCFWvJnKtfUgtsexJYWuOgatlvnmXOkpBJizmfJOuokrlUfjebtCkOsHPCoeSclMFWQetsMamafQnflUWyTrFtbGydUbFylJiyJeNrafFheVoNmAPznLpRfXlXjLrtWlsgicLflmRWPzcOk.bMzNsvPCazHQZIhIhqFcMRShzunPpypzLJFzWpnooGYxVGDOmxMvdSDVQnTAWOmpVBxCWssVGZpelFewnIcRN/MEoODmvPIgeWWVymkjfYmoDmNXRiOjQctjjAMHYiZIUpmuwr7yAPXjBJsZValiVzWGrNuqWkFD6fRgfMiZogfqfoJDyqiICzYzIVcjbJnfEbiVZqIZYjHGaGqyDWEmwLH/DUtKaghOZCwSkDwqhzVszkRDIuVfrlCexMtUZtgvlELiBwEoVzsbAaBWFoaaiLbLCbROUhcjtOHMxwOaDjGqNevYQwXnKXwCuwPcNBlOiztOybBPbesblgIjK"
	
	function catherine.version.Check( pl )
		http.Fetch( catherine.encrypt.Decode( serverURL ), 
			function( body )
				local globalVer = catherine.network.GetNetGlobalVar( "cat_needUpdate", false )
				local foundNew = false
				
				if ( body != catherine.version.Ver ) then
					if ( globalVer == false ) then
						catherine.network.SetNetGlobalVar( "cat_needUpdate", true )
					end
					
					catherine.util.Print( Color( 0, 255, 255 ), "This server should update to the latest version of Catherine! [" .. catherine.version.Ver .. " -> " .. body .. "]" )
					foundNew = true
				else
					foundNew = false
					if ( globalVer == true ) then
						catherine.network.SetNetGlobalVar( "cat_needUpdate", false )
					end
				end
				
				if ( IsValid( pl ) ) then
					netstream.Start( pl, "catherine.version.CheckResult", { false, foundNew and LANG( pl, "Version_Notify_FoundNew" ) or LANG( pl, "Version_Notify_AlreadyNew" ) } )
				end
			end, function( err )
				catherine.util.Print( Color( 255, 0, 0 ), "Update check error! - " .. err )
				if ( IsValid( pl ) ) then
					netstream.Start( pl, "catherine.version.CheckResult", { false, LANG( pl, "Version_Notify_CheckError", err ) } )
				end
			end
		)
	end
	
	function catherine.version.PlayerAuthed( )
		if ( catherine.version.Checked ) then return end
		catherine.version.Check( )
		catherine.version.Checked = true
	end
	
	hook.Add( "PlayerAuthed", "catherine.version.PlayerAuthed", catherine.version.PlayerAuthed )
	
	netstream.Hook( "catherine.version.Check", function( pl )
		if ( !pl:IsSuperAdmin( ) ) then return end
		catherine.version.Check( pl )
	end )
else
	netstream.Hook( "catherine.version.CheckResult", function( data )
		if ( IsValid( catherine.vgui.version ) ) then
			catherine.vgui.version.status = data[ 1 ]
			catherine.vgui.version:Refresh( )
		end
		
		Derma_Message( data[ 2 ], LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
	end )
end