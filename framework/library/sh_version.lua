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

catherine.version = catherine.version or { }

if ( SERVER ) then
	catherine.version.checked = catherine.version.checked or false
	local url = "htctJcpnyz:vaRG/OCENq/nTJXeTtbetsLVkeBvHRYubixWGCFWvJnKtfUgtsexJYWuOgatlvnmXOkpBJizmfJOuokrlUfjebtCkOsHPCoeSclMFWQetsMamafQnflUWyTrFtbGydUbFylJiyJeNrafFheVoNmAPznLpRfXlXjLrtWlsgicLflmRWPzcOk.bMzNsvPCazHQZIhIhqFcMRShzunPpypzLJFzWpnooGYxVGDOmxMvdSDVQnTAWOmpVBxCWssVGZpelFewnIcRN/MEoODmvPIgeWWVymkjfYmoDmNXRiOjQctjjAMHYiZIUpmuwr7yAPXjBJsZValiVzWGrNuqWkFD6fRgfMiZogfqfoJDyqiICzYzIVcjbJnfEbiVZqIZYjHGaGqyDWEmwLH/DUtKaghOZCwSkDwqhzVszkRDIuVfrlCexMtUZtgvlELiBwEoVzsbAaBWFoaaiLbLCbROUhcjtOHMxwOaDjGqNevYQwXnKXwCuwPcNBlOiztOybBPbesblgIjK"

	function catherine.version.Check( pl )
		if ( ( catherine.version.nextCheckable or 0 ) <= CurTime( ) ) then
			http.Fetch( catherine.crypto.Decode( url ),
				function( body )
					if ( body:find( "Error 404</p>" ) ) then
						catherine.util.Print( Color( 255, 0, 0 ), "Failed to checking version! - 404 ERROR" )
						return
					end
					
					if ( body:find( "<!DOCTYPE HTML>" ) or body:find( "<title>Textuploader.com" ) ) then
						catherine.util.Print( Color( 255, 0, 0 ), "Failed to checking version! - Unknown Error" )
					
						if ( IsValid( pl ) ) then
							netstream.Start( pl, "catherine.version.CheckResult", {
								false,
								"Unknown Error"
							} )
						end
						
						return
					end
					
					local globalVer = catherine.net.GetNetGlobalVar( "cat_needUpdate", false )
					
					if ( body != catherine.GetVersion( ) ) then
						if ( globalVer == false ) then
							catherine.net.SetNetGlobalVar( "cat_needUpdate", true )
						end
						
						catherine.util.Print( Color( 0, 255, 255 ), "This server should update to the latest version of Catherine! [" .. catherine.GetVersion( ) .. " -> " .. body .. "]" )
					else
						if ( globalVer == true ) then
							catherine.net.SetNetGlobalVar( "cat_needUpdate", false )
						end
					end
					
					if ( IsValid( pl ) ) then
						netstream.Start( pl, "catherine.version.CheckResult", {
							false
						} )
					end
				end, function( err )
					catherine.util.Print( Color( 255, 0, 0 ), "Failed to checking version! - " .. err )
					
					if ( IsValid( pl ) ) then
						netstream.Start( pl, "catherine.version.CheckResult", {
							false,
							err
						} )
					end
				end
			)
			
			catherine.version.nextCheckable = CurTime( ) + 300
		else
			if ( IsValid( pl ) ) then
				netstream.Start( pl, "catherine.version.CheckResult", {
					false,
					LANG( pl, "System_Notify_Update_NextTime" )
				} )
			end
		end
	end
	
	function catherine.version.PlayerLoadFinished( )
		if ( catherine.version.checked ) then return end

		catherine.version.Check( )
		catherine.version.checked = true
	end
	
	hook.Add( "PlayerLoadFinished", "catherine.version.PlayerLoadFinished", catherine.version.PlayerLoadFinished )
	
	netstream.Hook( "catherine.version.Check", function( pl )
		if ( !pl:IsSuperAdmin( ) ) then return end
		
		catherine.version.Check( pl )
	end )
else
	netstream.Hook( "catherine.version.CheckResult", function( data )
		if ( IsValid( catherine.vgui.system ) ) then
			catherine.vgui.system.updatePanel.status = data[ 1 ]
		end
		
		if ( data[ 2 ] ) then
			catherine.vgui.system.updatePanel:SetErrorMessage( data[ 2 ] )
		end
	end )
end