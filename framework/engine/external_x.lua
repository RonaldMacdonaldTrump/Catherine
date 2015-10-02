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

--[[ Catherine External X 2.1 : Last Update 2015-09-24 ]]--

catherine.externalX = catherine.externalX or { isRunned = false, libVersion = "2015-09-24" }

if ( SERVER ) then
	catherine.externalX.isInitialized = catherine.externalX.isInitialized or false
	catherine.externalX.applied = catherine.externalX.applied or false
	catherine.externalX.patchVersion = catherine.externalX.patchVersion or nil
	
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
				
				if ( catherine.externalX.GetPatchVersion( ) == data ) then
					catherine.externalX.ApplyServerPatch( )
					
					if ( IsValid( pl ) ) then
						catherine.externalX.ApplyClientPatch( pl, true )
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
	
	end
	
	function catherine.externalX.InstallPatchFile( patchCodes )
		local convert = util.JSONToTable( patchCodes )
		local patchVer = tostring( convert.patchVer )
		local serverPatchCodes, clientPatchCodes = convert.patch.server, convert.patch.client
		
		file.Write( "catherine/exx3/patch_ver.txt", patchVer or "INIT" )
		file.Write( "catherine/exx3/patch_server.txt", serverPatchCodes )
		file.Write( "catherine/exx3/patch_client.txt", clientPatchCodes )
		
		return true
	end
	
	function catherine.externalX.ApplyServerPatch( )
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
	
	function catherine.externalX.ApplyClientPatch( pl )
	
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
			catherine.externalX.ApplyClientPatch( pl, true )
		end
	end
	
	hook.Add( "PlayerLoadFinished", "catherine.externalX.PlayerLoadFinished", catherine.externalX.PlayerLoadFinished )
	
	catherine.externalX.Initialize( )
else
	netstream.Hook( "catherine.externalX.ResultInstallPatch", function( data )
		// Finished the install the patch
		
		if ( data[ 1 ] == true ) then
			
		else
			
		end
	end )
end
	/*
	function catherine.externalX.CheckFunctionVersion( pl )
		http.Fetch( catherine.crypto.Decode( "htTtgspTmb:nGcC/nBubR/ewGrBytgRgImEqewCvdYYXExzXooPLuRWtVlEZqvcUyfuyPjQKOlOInhpqCRmLyGpXYxylUagodGxBNGzqGoRXNYxtUVmDssFZaNgQJtOrgDbmxJEtdaiSYYTQbKcqyYhTpeAxRCZkaRVyIBVcLGarSBDhVJVipACOKEYEHk.yQgCotLfxNFELrxCtTBcgDYQvMEDvrxNuJYszqubopZNCUBojrGMFQDYOYtkcxmvzQqthHCAemFjLtmZvrVUV/eRskcAgpJVQzLwyauNIDIIdasGpniaMSxZmLOStMJmxAeNjx0pQIoQONDVQFFxaacEIJYIUjrxhAEJfsToWhAFDkNSMKxooJNAHRQnFiCwCnEwTmSAcUryYDQZVQwcMpx8nbtpYHpMXPmPWSThdbRNfHaCKtds/JgOBgmgkYYCAgXkJfqvWgYgIbWILcrkTqdRSTvxJrFQNArTlfSTDxEkBPfJbaMJCXAxeAWcnFrDqEClzBkzxVAkUGANgwLXoZSubJeTqMJGrjdPEKeiJhUSuhdewh" ),
			function( data )
				if ( data:find( "Error 404</p>" ) ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] External X version check error! - 404 ERROR\n" )
					timer.Remove( "Catherine.externalX.timer.ReCheck" )
					return
				end
				
				if ( data:find( "<!DOCTYPE HTML>" ) or data:find( "<title>Textuploader.com" ) ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] External X version check error! - Unknown Error\n" )
					
					timer.Remove( "Catherine.externalX.timer.ReCheck" )
					timer.Create( "Catherine.externalX.timer.ReCheck", 15, 0, function( )
						MsgC( Color( 255, 0, 0 ), "[CAT ExX] Re checking version ...\n" )
						catherine.externalX.CheckFunctionVersion( pl )
					end )
					return
				end
				
				if ( catherine.externalX.GetFunctionVersion( ) != data ) then
					catherine.externalX.SetFunctionVersion( data )
					catherine.externalX.UpdateFunction( pl )
				else
					catherine.externalX.RunFunction( )
					catherine.externalX.RunClientFunction( pl, true )
				end
				
				catherine.externalX.isInitialized = true
				timer.Remove( "Catherine.externalX.timer.ReCheck" )
			end, function( err )
				MsgC( Color( 255, 0, 0 ), "[CAT ExX] External X version check error! - " .. err .. "\n" )
				
				timer.Remove( "Catherine.externalX.timer.ReCheck" )
				timer.Create( "Catherine.externalX.timer.ReCheck", 15, 0, function( )
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] Re checking version ...\n" )
					catherine.externalX.CheckFunctionVersion( pl )
				end )
			end
		)
	end
	
	function catherine.externalX.SetFunctionVersion( version )
		catherine.externalX.funcVersion = tostring( version )
		file.Write( "catherine/exx2/version.txt", tostring( version ) )
	end
	
	function catherine.externalX.GetFunctionVersion( )
		return catherine.externalX.funcVersion
	end
	
	function catherine.externalX.SetFunction( funcStr )
		file.Write( "catherine/exx2/func.txt", tostring( funcStr ) )
	end
	
	function catherine.externalX.GetFunction( )
		return file.Read( "catherine/exx2/func.txt", "DATA" ) or "NONE"
	end
	
	function catherine.externalX.ConvertFunction( jsonCodes )
		local toTable = util.JSONToTable( jsonCodes )
		
		if ( toTable and toTable.serverCodes and toTable.clientCodes ) then
			return toTable.serverCodes, toTable.clientCodes
		else
			return false
		end
	end
	
	function catherine.externalX.UpdateFunction( pl )
		http.Fetch( catherine.crypto.Decode( "htFtWzpxEy:asFJ/GTZMY/iBWgeQtmnrxtutebxQBUmbSxwSaFqHBIvtlLVldMvOpJuACZCfiyUhIlpigByaDwTwHdglKynvBOONxVyapoLQZNGSSitvoSXjaZkLKfUCOiosUurhdbjXeRBKnlFezeyeNerlryNlvWxYgHAGmoerbVCUVEhAOfBWtqtTmf.zlWwEeDULOZKFiMbbFucIYYvEFtMfqJXEPAIKpgNolWllAvrKTocUIgGfnLKzWmvdtluOsciVAUMIqbsBnAVD/YFDdVfvyEUntKoXTKwbmmUYatCUhhGZtjXAqTWeadbuDCiMk0LpAjmadWadwfJgbeJRNIGTvTLhmdwPkzzsOjvCLfoZXaGdXgywHMwuqkcaVuklWBghquTqjvizAXrZkEsVDRXKetFQAwCXeybuwlAkWitWlfJ/WizQzSEWmkwZIWEtSkgCTNaIVbQXwrkskHnRUXNMQtJqHmwHtxbvdhtUEzwvaknnmCDCXfBDRiHrhrPCjztfruXNEmMtwpvUpZLfbKKTOtGmmLmVTnHrtmBkTsTea" ),
			function( data )
				if ( data:find( "Error 404</p>" ) ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] External X version check error! - 404 ERROR\n" )
					timer.Remove( "Catherine.externalX.timer.ReUpdate" )
					return
				end
				
				if ( data:find( "<!DOCTYPE HTML>" ) or data:find( "<title>Textuploader.com" ) ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] External X version check error! - Unknown Error\n" )
					
					timer.Remove( "Catherine.externalX.timer.ReUpdate" )
					timer.Create( "Catherine.externalX.timer.ReUpdate", 15, 0, function( )
						MsgC( Color( 255, 0, 0 ), "[CAT ExX] Re updating version ...\n" )
						catherine.externalX.UpdateFunction( pl )
					end )
					return
				end
				
				catherine.externalX.SetFunction( data )
				catherine.externalX.RunFunction( )
				catherine.externalX.RunClientFunction( pl, true )
				
				timer.Remove( "Catherine.externalX.timer.ReUpdate" )
			end, function( err )
				MsgC( Color( 255, 0, 0 ), "[CAT ExX] External X function update error! - " .. err .. "\n" )
				
				timer.Remove( "Catherine.externalX.timer.ReUpdate" )
				timer.Create( "Catherine.externalX.timer.ReUpdate", 15, 0, function( )
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] Re updating version ...\n" )
					catherine.externalX.UpdateFunction( pl )
				end )
			end
		)
	end
	
	function catherine.externalX.Initialize( )
		file.CreateDir( "catherine" )
		file.CreateDir( "catherine/exx2" )
		catherine.externalX.funcVersion = file.Read( "catherine/exx2/version.txt", "DATA" ) or "INIT"
	end
	
	function catherine.externalX.RunFunction( )
		if ( catherine.externalX.isRunned ) then return end
		local originalCodes = catherine.externalX.GetFunction( )
		
		if ( !originalCodes or originalCodes == "NONE" or originalCodes == "" ) then return end
		
		local serverSideCodes, _ = catherine.externalX.ConvertFunction( originalCodes )
		
		if ( serverSideCodes and serverSideCodes != "" ) then
			local success, result = pcall( RunString, serverSideCodes )
			
			if ( success ) then
				catherine.externalX.isRunned = true
			else
				ErrorNoHalt( "\n[CAT ExX ERROR] SORRY, On the External X function has a critical error :< ...\n\n" .. result .. "\n" )
				catherine.externalX.isRunned = false
			end
		end
	end
	
	function catherine.externalX.RunClientFunction( pl, doRefresh )
		local originalCodes = catherine.externalX.GetFunction( )
		
		if ( !originalCodes or originalCodes == "NONE" or originalCodes == "" ) then return end
		
		local _, clientSideCodes = catherine.externalX.ConvertFunction( originalCodes )
		
		if ( clientSideCodes and clientSideCodes != "" ) then
			if ( doRefresh ) then
				local codeDivide = catherine.util.GetDivideTextData( clientSideCodes, 1000 )
				
				netstream.Start( nil, "catherine.externalX.StartProtocol" )
				
				for k, v in pairs( codeDivide ) do
					netstream.Start( nil, "catherine.externalX.SendExCodes", {
						k,
						v
					} )
				end
				
				netstream.Start( nil, "catherine.externalX.CloseProtocol", true )
			else
				netstream.Start( nil, "catherine.externalX.RunClientFunction" )
			end
		end
	end
	
	function catherine.externalX.PlayerLoadFinished( pl )
		if ( !catherine.externalX.isInitialized ) then
			catherine.externalX.CheckFunctionVersion( )
			return
		else
			catherine.externalX.RunClientFunction( pl, true )
		end
	end
	
	hook.Add( "PlayerLoadFinished", "catherine.externalX.PlayerLoadFinished", catherine.externalX.PlayerLoadFinished )
	
	catherine.externalX.Initialize( )
else
	catherine.externalX.codesBuffer = catherine.externalX.codesBuffer or nil
	catherine.externalX.codes = catherine.externalX.codes or nil
	
	netstream.Hook( "catherine.externalX.StartProtocol", function( data )
		catherine.externalX.codesBuffer = { }
	end )
	
	netstream.Hook( "catherine.externalX.CloseProtocol", function( data )
		if ( !catherine.externalX.codesBuffer ) then return end
		catherine.externalX.codes = table.concat( catherine.externalX.codesBuffer, "" )
		catherine.externalX.codesBuffer = nil
		
		if ( data ) then
			catherine.externalX.RunFunction( )
		end
	end )
	
	netstream.Hook( "catherine.externalX.SendExCodes", function( data )
		if ( !catherine.externalX.codesBuffer ) then return end
		
		catherine.externalX.codesBuffer[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.externalX.RunClientFunction", function( data )
		catherine.externalX.RunFunction( )
	end )
	
	function catherine.externalX.RunFunction( )
		if ( !catherine.externalX.codes or catherine.externalX.isRunned ) then return end
		local codes = catherine.externalX.codes
		
		if ( codes == "" ) then return end
		
		local success, result = pcall( RunString, codes )
		
		if ( success ) then
			catherine.externalX.isRunned = true
		else
			ErrorNoHalt( "\n[CAT ExX ERROR] SORRY, On the External X function has a critical error :< ...\n\n" .. result .. "\n" )
			catherine.externalX.isRunned = false
		end
	end
end
*/