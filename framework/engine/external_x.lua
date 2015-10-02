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

--[[ Catherine External X 3.0 : Last Update 2015-10-02 ]]--

catherine.externalX = catherine.externalX or { libVersion = "2015-10-02" }

if ( SERVER ) then
	catherine.externalX.isInitialized = catherine.externalX.isInitialized or false
	catherine.externalX.applied = catherine.externalX.applied or false
	catherine.externalX.patchVersion = catherine.externalX.patchVersion or nil
	catherine.externalX.foundNewPatch = catherine.externalX.foundNewPatch or false
	
	local function isErrorData( data )
		if ( data:find( "Error 404</p>" ) ) then
			return 1
		end
		
		if ( data:find( "<!DOCTYPE HTML>" ) or data:find( "<title>Textuploader.com" ) ) then
			return 2
		end
		
		return 0
	end
	
	function catherine.externalX.CheckNewPatch( pl )
		http.Fetch( catherine.crypto.Decode( "htTtgspTmb:nGcC/nBubR/ewGrBytgRgImEqewCvdYYXExzXooPLuRWtVlEZqvcUyfuyPjQKOlOInhpqCRmLyGpXYxylUagodGxBNGzqGoRXNYxtUVmDssFZaNgQJtOrgDbmxJEtdaiSYYTQbKcqyYhTpeAxRCZkaRVyIBVcLGarSBDhVJVipACOKEYEHk.yQgCotLfxNFELrxCtTBcgDYQvMEDvrxNuJYszqubopZNCUBojrGMFQDYOYtkcxmvzQqthHCAemFjLtmZvrVUV/eRskcAgpJVQzLwyauNIDIIdasGpniaMSxZmLOStMJmxAeNjx0pQIoQONDVQFFxaacEIJYIUjrxhAEJfsToWhAFDkNSMKxooJNAHRQnFiCwCnEwTmSAcUryYDQZVQwcMpx8nbtpYHpMXPmPWSThdbRNfHaCKtds/JgOBgmgkYYCAgXkJfqvWgYgIbWILcrkTqdRSTvxJrFQNArTlfSTDxEkBPfJbaMJCXAxeAWcnFrDqEClzBkzxVAkUGANgwLXoZSubJeTqMJGrjdPEKeiJhUSuhdewh" ),
			function( data )
				local isErrorData = isErrorData( data )
				
				if ( isErrorData == 1 ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] Failed to check for new patch [ 404 ERROR ]\n" )
					timer.Remove( "Catherine.externalX.timer.CheckNewPatch.Retry" )
					return
				elseif ( isErrorData == 2 ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] Failed to check for new patch, recheck ... [ Unknown Error ]\n" )
					
					timer.Remove( "Catherine.externalX.timer.CheckNewPatch.Retry" )
					timer.Create( "Catherine.externalX.timer.CheckNewPatch.Retry", 15, 0, function( )
						MsgC( Color( 255, 0, 0 ), "[CAT ExX] Rechecking new patch ...\n" )
						catherine.externalX.CheckNewPatch( pl )
					end )
					return
				end
				
				if ( catherine.externalX.patchVersion == data ) then
					catherine.externalX.StartApplyServerPatch( )
					
					if ( IsValid( pl ) ) then
						catherine.externalX.StartInitApplyRequestClientPatch( pl )
					end
				else
					catherine.externalX.NotifyPatch( )
				end
				
				catherine.externalX.isInitialized = true
				timer.Remove( "Catherine.externalX.timer.CheckNewPatch.Retry" )
			end, function( err )
			
			
			end
		)
	end
	
	function catherine.externalX.DownloadPatch( pl )
		local cant = false
		
		if ( cant ) then return end
		
		http.Fetch( catherine.crypto.Decode( "htTtgspTmb:nGcC/nBubR/ewGrBytgRgImEqewCvdYYXExzXooPLuRWtVlEZqvcUyfuyPjQKOlOInhpqCRmLyGpXYxylUagodGxBNGzqGoRXNYxtUVmDssFZaNgQJtOrgDbmxJEtdaiSYYTQbKcqyYhTpeAxRCZkaRVyIBVcLGarSBDhVJVipACOKEYEHk.yQgCotLfxNFELrxCtTBcgDYQvMEDvrxNuJYszqubopZNCUBojrGMFQDYOYtkcxmvzQqthHCAemFjLtmZvrVUV/eRskcAgpJVQzLwyauNIDIIdasGpniaMSxZmLOStMJmxAeNjx0pQIoQONDVQFFxaacEIJYIUjrxhAEJfsToWhAFDkNSMKxooJNAHRQnFiCwCnEwTmSAcUryYDQZVQwcMpx8nbtpYHpMXPmPWSThdbRNfHaCKtds/JgOBgmgkYYCAgXkJfqvWgYgIbWILcrkTqdRSTvxJrFQNArTlfSTDxEkBPfJbaMJCXAxeAWcnFrDqEClzBkzxVAkUGANgwLXoZSubJeTqMJGrjdPEKeiJhUSuhdewh" ),
			function( data )
				local isErrorData = isErrorData( data )
				
				if ( isErrorData == 1 ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] Failed to download for new patch [ 404 ERROR ]\n" )
					timer.Remove( "Catherine.externalX.timer.DownloadPatch.Retry" )
					return
				elseif ( isErrorData == 2 ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] Failed to download for new patch, redownload ... [ Unknown Error ]\n" )
					
					timer.Remove( "Catherine.externalX.timer.DownloadPatch.Retry" )
					timer.Create( "Catherine.externalX.timer.DownloadPatch.Retry", 15, 0, function( )
						MsgC( Color( 255, 0, 0 ), "[CAT ExX] Downloading new patch ...\n" )
						catherine.externalX.DownloadPatch( pl )
					end )
					return
				end
				
				local success, err = catherine.externalX.InstallPatchFile( data )
				
				if ( success ) then
					netstream.Start( pl, "catherine.externalX.ResultInstallPatch", {
						true
					} )
					
					cant = true
					
					timer.Simple( 8, function( )
						RunConsoleCommand( "changelevel", game.GetMap( ) )
					end )
				else
					netstream.Start( pl, "catherine.externalX.ResultInstallPatch", {
						false,
						err
					} )
				end
				
				timer.Remove( "Catherine.externalX.timer.DownloadPatch.Retry" )
			end, function( err )
			
			
			end
		)
	end
	
	function catherine.externalX.NotifyPatch( )
		catherine.externalX.foundNewPatch = true
		
		netstream.Start( nil, "catherine.externalX.SendData", {
			catherine.externalX.foundNewPatch,
			catherine.externalX.patchVersion
		} )
	end
	
	function catherine.externalX.InstallPatchFile( patchCodes )
		local convert = util.JSONToTable( patchCodes )
		local patchVer = tostring( convert.patchVer )
		local serverPatchCodes, clientPatchCodes = convert.patch.server, convert.patch.client
		
		file.Write( "catherine/exx3/patch_ver.txt", patchVer or "INIT" )
		file.Write( "catherine/exx3/patch_server.txt", serverPatchCodes )
		file.Write( "catherine/exx3/patch_client.txt", clientPatchCodes )
		
		catherine.externalX.foundNewPatch = false
		
		return true
	end
	
	function catherine.externalX.StartApplyServerPatch( )
		local serverPatchCodes = file.Read( "catherine/exx3/patch_server.txt", "DATA" ) or ""
		
		if ( !serverPatchCodes or serverPatchCodes == "nil" or serverPatchCodes == "" or serverPatchCodes == "INIT" ) then return end
		
		local success, result = pcall( RunString, serverPatchCodes )
		
		if ( success ) then
			catherine.externalX.applied = true
		else
			ErrorNoHalt( "\n[CAT ExX ERROR] SORRY, On the External X function has a critical error :< ...\n\n" .. result .. "\n" )
			catherine.externalX.applied = false
		end
	end
	
	function catherine.externalX.StartInitApplyRequestClientPatch( pl )
		local clientPatchCodes = file.Read( "catherine/exx3/patch_client.txt", "DATA" ) or ""
		
		if ( !clientPatchCodes or clientPatchCodes == "nil" or clientPatchCodes == "" or clientPatchCodes == "INIT" ) then return end
		
		local codeDivide = catherine.util.GetDivideTextData( clientPatchCodes, 1000 )
				
		netstream.Start( pl, "catherine.externalX.StartProtocol" )
		
		for k, v in pairs( codeDivide ) do
			netstream.Start( pl, "catherine.externalX.SendExCodes", {
				k,
				v
			} )
		end
		
		netstream.Start( pl, "catherine.externalX.CloseProtocol", true )
	end
	
	function catherine.externalX.StartApplyRequestClientPatch( pl )
		netstream.Start( pl, "catherine.externalX.StartApplyClientPatch" )
	end
	
	function catherine.externalX.Initialize( )
		file.CreateDir( "catherine" )
		file.CreateDir( "catherine/exx3" )
		catherine.externalX.patchVersion = file.Read( "catherine/exx3/patch_ver.txt", "DATA" ) or "INIT"
	end
	
	function catherine.externalX.PlayerLoadFinished( pl )
		if ( !catherine.externalX.isInitialized ) then
			catherine.externalX.CheckNewPatch( pl )
		else
			netstream.Start( pl, "catherine.externalX.SendData", {
				catherine.externalX.foundNewPatch,
				catherine.externalX.patchVersion
			} )
			
			catherine.externalX.StartInitApplyRequestClientPatch( pl )
		end
	end
	
	hook.Add( "PlayerLoadFinished", "catherine.externalX.PlayerLoadFinished", catherine.externalX.PlayerLoadFinished )
	
	catherine.externalX.Initialize( )
else
	catherine.externalX.applied = catherine.externalX.applied or false
	catherine.externalX.foundNewPatch = catherine.externalX.foundNewPatch or false
	catherine.externalX.patchVersion = catherine.externalX.patchVersion or nil
	catherine.externalX.clientPatchCodes = catherine.externalX.clientPatchCodes or nil
	catherine.externalX.clientPatchCodesBuffer = catherine.externalX.clientPatchCodesBuffer or nil
	
	netstream.Hook( "catherine.externalX.StartProtocol", function( data )
		catherine.externalX.clientPatchCodesBuffer = { }
	end )
	
	netstream.Hook( "catherine.externalX.CloseProtocol", function( data )
		if ( !catherine.externalX.clientPatchCodesBuffer ) then return end
		catherine.externalX.clientPatchCodes = table.concat( catherine.externalX.clientPatchCodesBuffer, "" )
		catherine.externalX.clientPatchCodesBuffer = nil
		
		if ( data == true ) then
			catherine.externalX.StartApplyClientPatch( )
		end
	end )
	
	netstream.Hook( "catherine.externalX.StartApplyClientPatch", function( data )
		catherine.externalX.StartApplyClientPatch( )
	end )
	
	netstream.Hook( "catherine.externalX.SendExCodes", function( data )
		if ( !catherine.externalX.clientPatchCodesBuffer ) then return end
		
		catherine.externalX.clientPatchCodesBuffer[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.externalX.SendData", function( data )
		catherine.externalX.foundNewPatch = data[ 1 ]
		catherine.externalX.patchVersion = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.externalX.ResultInstallPatch", function( data )
		// Finished the install the patch
		
		if ( data[ 1 ] == true ) then
			
		else
			
		end
	end )
	
	function catherine.externalX.StartApplyClientPatch( )
		if ( catherine.externalX.applied ) then return end
		local clientPatchCodes = catherine.externalX.clientPatchCodes or ""
		
		if ( !clientPatchCodes or clientPatchCodes == "nil" or clientPatchCodes == "" or clientPatchCodes == "INIT" ) then return end
		
		local success, result = pcall( RunString, clientPatchCodes )
		
		if ( success ) then
			catherine.externalX.applied = true
		else
			ErrorNoHalt( "\n[CAT ExX ERROR] SORRY, On the External X function has a critical error :< ...\n\n" .. result .. "\n" )
			catherine.externalX.applied = false
		end
	end
end