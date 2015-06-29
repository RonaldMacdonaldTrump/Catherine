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

catherine.globalban = catherine.globalban or { }

if ( SERVER ) then
	catherine.globalban.updated = catherine.globalban.updated or false
	catherine.globalban.nextGlobalBanUpdateTick = catherine.globalban.nextGlobalBanUpdateTick or CurTime( ) + 700
	catherine.globalban.database = catherine.globalban.database or { }
	local url = "htxtHkpSzb:jqUw/EjbLD/iKCYogtIcjMygPextpSXtYdxmZxIZlJlAtSPMBgtrgJNuotFZgsIIPVppzMxxinBdsTOwlokIuPtvAnuzraojbkoWCsGQtonGOahfLrbPrILVeppfudqDBkUPkXyKvhjqNfevYruIinaBZQnnvKnbrTctfSmPcmtkTUSJdiC.OUyGVTXAUvFHWJxhEUkcMCrRqaomTNlQeWoBagdKoLbvxFeeRmAUGyPPllRxGdmUxROfSPCxSrpKiXoIypAhz/bxupuangkCFZBvnftVPbGjnngOKXeZpzsskqdfWxzNAuxSNDthscTgglSNJbHNNHxRTZtmLbbJzcuaHBJnECtRXJigWfxUyLysMKvwYLfjPClrFYlSBRhofnAgwXEoAGk/fWEPiJIHWCJOPYYjvNqybCHmnNdyrULkncmFxXQtijcuHAkYGeHCGSdNnmaCDDmkwpnEuwIQLeoNywypnDcLvsmCpwGlGepUZdDvdifgdxzzdivNISkHlXvkT"

	function catherine.globalban.UpdateDatabase( )
		http.Fetch( catherine.crypto.Decode( url ),
			function( body )
				local tab = catherine.globalban.ConvertToDataBase( body )
				
				if ( tab and #catherine.globalban.database != #tab ) then
					catherine.globalban.database = tab
					catherine.net.SetNetGlobalVar( "cat_globalban_database", tab )
					
					catherine.util.Print( Color( 0, 255, 0 ), "GlobalBan Database has updated! - [" .. #tab .. "'s users]" )
				end
			end, function( err )
				catherine.util.Print( Color( 255, 0, 0 ), "GlobalBan Database update error! - " .. err )
			end
		)
	end
	
	function catherine.globalban.ConvertToDataBase( str )
		return util.JSONToTable( str )
	end
	
	function catherine.globalban.IsBanned( steamID )
		for k, v in pairs( catherine.globalban.database ) do
			if ( v.steamID == steamID ) then
				return true
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
			return false, "[Catherine GlobalBan] You are banned by this server."
		end
	end
	
	hook.Add( "Think", "catherine.globalban.Think", catherine.globalban.Think )
	hook.Add( "PlayerLoadFinished", "catherine.globalban.PlayerLoadFinished", catherine.globalban.PlayerLoadFinished )
	hook.Add( "CheckPassword", "catherine.globalban.CheckPassword", catherine.globalban.CheckPassword )
end