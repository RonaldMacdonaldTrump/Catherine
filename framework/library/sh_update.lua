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

catherine.update = catherine.update or { }

if ( SERVER ) then
	catherine.update.checked = catherine.update.checked or false
	
	function catherine.update.Check( pl )
		if ( ( catherine.update.nextCheckable or 0 ) <= CurTime( ) ) then
			http.Fetch( catherine.crypto.Decode( "htotGApRdN:wATs/YQKJg/XtOgVftAXxLUwFeMMhRpleExWNbNiTrJstohuyKzdZeHujcGUyTMqBYqpSRXadbpeUSbmlubthnlZWPyugIodLsJqNkBaRXyLZajDcvhnniIvcAiHgdHSeooxCamnSLegPLeWcgdyWhIGLREnDZkmrRblOmgSizuCZIyyOeV.SDooHdMGkDsRGvRbOwbcBuUWqcSotDEQjqZdfEBAohSaFItJJowFCJrwDZFSJSmfrGNIhPwYcPFFWwmkXHyer/RyEQoDDCSiqzaHNjLILtqMRaepMupiAyJIfYeMrAOWOiZzhcgigzOgkpiEjPJcFynrjGryPCcN0mlKMGTEQpExZnVkvYOmBGgvXzy1nMjcFNiqaUzgMJMTlSFOgnFZgJCypuDfGIJPNJTysnZEPsZvmtSfPTVa/XcTwLdYZthgmRqEwvEVJSMXvuLOBwrCvOgupleZRXRAnEDxTRbXBZtmVtvPHaMhsTHECdzyjpLnExgUiCJrZldFTQfROwAaXFzWlnQOdRBbAWTwbeFbNlWIhzgIcY" ),
				function( body )
					if ( body:find( "Error 404</p>" ) ) then
						MsgC( Color( 255, 0, 0 ), "[CAT Update ERROR] Failed to checking update! [404 ERROR]\n" )
						
						if ( IsValid( pl ) ) then
							netstream.Start( pl, "catherine.update.ResultCheck", "404 ERROR" )
						end
						
						return
					end
					
					if ( body:find( "<!DOCTYPE HTML>" ) or body:find( "<title>Textuploader.com" ) ) then
						MsgC( Color( 255, 0, 0 ), "[CAT Update ERROR] Failed to checking update! [Unknown ERROR]\n" )
						
						if ( IsValid( pl ) ) then
							netstream.Start( pl, "catherine.update.ResultCheck", "Unknown Error" )
						end
						
						return
					end
					
					local data = CompileString( body, "catherine.update.Check" )( )
					
					if ( data.version != catherine.GetVersion( ) ) then
						MsgC( Color( 0, 255, 255 ), "[CAT Update] This server should update to the latest version of Catherine! [" .. catherine.GetVersion( ) .. " -> " .. data.version .. "]\n" )
					end
					
					catherine.net.SetNetGlobalVar( "cat_updateData", data )
					
					if ( IsValid( pl ) ) then
						netstream.Start( pl, "catherine.update.ResultCheck" )
					end
				end, function( err )
					MsgC( Color( 255, 0, 0 ), "[CAT Update ERROR] Failed to checking update! [" .. err .. "]\n" )
					
					if ( IsValid( pl ) ) then
						netstream.Start( pl, "catherine.update.ResultCheck", err )
					end
				end
			)
			
			catherine.update.nextCheckable = CurTime( ) + 500
		else
			if ( IsValid( pl ) ) then
				netstream.Start( pl, "catherine.update.ResultCheck", LANG( pl, "System_Notify_Update_NextTime" ) )
			end
		end
	end
	
	function catherine.update.PlayerLoadFinished( )
		if ( catherine.update.checked ) then return end
		
		catherine.update.Check( )
		catherine.update.checked = true
	end
	
	hook.Add( "PlayerLoadFinished", "catherine.update.PlayerLoadFinished", catherine.update.PlayerLoadFinished )
	
	netstream.Hook( "catherine.update.Check", function( pl )
		if ( pl:IsSuperAdmin( ) ) then
			catherine.update.Check( pl )
		else
			netstream.Start( pl, "catherine.update.ResultCheck", LANG( pl, "System_Notify_PermissionError" ) )
		end
	end )
else
	netstream.Hook( "catherine.update.ResultCheck", function( data )
		if ( IsValid( catherine.vgui.system ) ) then
			catherine.vgui.system.updatePanel.status = false
			catherine.vgui.system.updatePanel:RefreshHistory( )
			
			if ( data and type( data ) == "string" ) then
				Derma_Message( LANG( "System_Notify_UpdateError", data ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			end
		end
	end )
end