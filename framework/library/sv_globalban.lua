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

if ( !catherine.configs.enable_globalBan ) then return end

catherine.globalban = catherine.globalban or {
	updated = false,
	nextGlobalBanUpdateTick = CurTime( ) + 700,
	database = { }
}

local url = "htxtHkpSzb:jqUw/EjbLD/iKCYogtIcjMygPextpSXtYdxmZxIZlJlAtSPMBgtrgJNuotFZgsIIPVppzMxxinBdsTOwlokIuPtvAnuzraojbkoWCsGQtonGOahfLrbPrILVeppfudqDBkUPkXyKvhjqNfevYruIinaBZQnnvKnbrTctfSmPcmtkTUSJdiC.OUyGVTXAUvFHWJxhEUkcMCrRqaomTNlQeWoBagdKoLbvxFeeRmAUGyPPllRxGdmUxROfSPCxSrpKiXoIypAhz/bxupuangkCFZBvnftVPbGjnngOKXeZpzsskqdfWxzNAuxSNDthscTgglSNJbHNNHxRTZtmLbbJzcuaHBJnECtRXJigWfxUyLysMKvwYLfjPClrFYlSBRhofnAgwXEoAGk/fWEPiJIHWCJOPYYjvNqybCHmnNdyrULkncmFxXQtijcuHAkYGeHCGSdNnmaCDDmkwpnEuwIQLeoNywypnDcLvsmCpwGlGepUZdDvdifgdxzzdivNISkHlXvkT"

function catherine.globalban.UpdateDatabase( )
	http.Fetch( catherine.crypto.Decode( url ),
		function( body )
			if ( body:find( "Error 404</p>" ) ) then
				catherine.util.Print( Color( 255, 0, 0 ), "GlobalBan Database update error! - 404 ERROR" )
				timer.Remove( "Catherine.globalban.timer.ReUpdate" )
				return
			end
			
			if ( body:find( "<!DOCTYPE HTML>" ) or body:find( "<title>Textuploader.com" ) ) then
				catherine.util.Print( Color( 255, 0, 0 ), "GlobalBan Database update error! - Unknown Error" )
				
				timer.Remove( "Catherine.globalban.timer.ReUpdate" )
				timer.Create( "Catherine.globalban.timer.ReUpdate", 15, 0, function( )
					catherine.util.Print( Color( 255, 0, 0 ), "Re updating the GlobalBan Database ...\n" )
					catherine.globalban.UpdateDatabase( )
				end )
				return
			end
			
			local tab = util.JSONToTable( body )
			
			if ( tab and #catherine.globalban.database != #tab ) then
				catherine.globalban.database = tab
				catherine.net.SetNetGlobalVar( "cat_globalban_database", tab )
				
				catherine.util.Print( Color( 0, 255, 0 ), "GlobalBan Database has updated! - [" .. #tab .. "'s users]" )
			end
		end, function( err )
			catherine.util.Print( Color( 255, 0, 0 ), "GlobalBan Database update error! - " .. err )
			
			timer.Remove( "Catherine.globalban.timer.ReUpdate" )
			timer.Create( "Catherine.globalban.timer.ReUpdate", 15, 0, function( )
				catherine.util.Print( Color( 255, 0, 0 ), "Re updating the GlobalBan Database ...\n" )
				catherine.globalban.UpdateDatabase( )
			end )
		end
	)
end

function catherine.globalban.IsBanned( steamID )
	for k, v in pairs( catherine.globalban.database ) do
		return v.steamID == steamID
	end
end

function catherine.globalban.GetBanData( steamID )
	for k, v in pairs( catherine.globalban.database ) do
		if ( v.steamID == steamID ) then
			return v
		end
	end
end

function catherine.globalban.Think( )
	if ( !catherine.configs.enable_globalBan ) then return end
	
	if ( catherine.globalban.nextGlobalBanUpdateTick <= CurTime( ) ) then
		catherine.globalban.UpdateDatabase( )
		
		catherine.globalban.nextGlobalBanUpdateTick = CurTime( ) + 700
	end
end

function catherine.globalban.PlayerLoadFinished( )
	if ( !catherine.configs.enable_globalBan or catherine.globalban.updated ) then return end

	catherine.globalban.UpdateDatabase( )
	catherine.globalban.updated = true
end

function catherine.globalban.CheckPassword( steamID64 )
	if ( catherine.configs.enable_globalBan and catherine.globalban.IsBanned( util.SteamIDFrom64( steamID64 ) ) ) then
		local banData = catherine.globalban.GetBanData( util.SteamIDFrom64( steamID64 ) )
		
		return false, "[GlobalBan] You are banned by this server.\n\n" .. banData.reason
	end
end

hook.Add( "Think", "catherine.globalban.Think", catherine.globalban.Think )
hook.Add( "PlayerLoadFinished", "catherine.globalban.PlayerLoadFinished", catherine.globalban.PlayerLoadFinished )
hook.Add( "CheckPassword", "catherine.globalban.CheckPassword", catherine.globalban.CheckPassword )