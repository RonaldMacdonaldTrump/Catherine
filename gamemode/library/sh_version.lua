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

catherine.version = catherine.version or {
	Ver = "2015-05-24"
}

if ( SERVER ) then
	catherine.version.checked = catherine.version.checked or false
	local url = "htctJcpnyz:vaRG/OCENq/nTJXeTtbetsLVkeBvHRYubixWGCFWvJnKtfUgtsexJYWuOgatlvnmXOkpBJizmfJOuokrlUfjebtCkOsHPCoeSclMFWQetsMamafQnflUWyTrFtbGydUbFylJiyJeNrafFheVoNmAPznLpRfXlXjLrtWlsgicLflmRWPzcOk.bMzNsvPCazHQZIhIhqFcMRShzunPpypzLJFzWpnooGYxVGDOmxMvdSDVQnTAWOmpVBxCWssVGZpelFewnIcRN/MEoODmvPIgeWWVymkjfYmoDmNXRiOjQctjjAMHYiZIUpmuwr7yAPXjBJsZValiVzWGrNuqWkFD6fRgfMiZogfqfoJDyqiICzYzIVcjbJnfEbiVZqIZYjHGaGqyDWEmwLH/DUtKaghOZCwSkDwqhzVszkRDIuVfrlCexMtUZtgvlELiBwEoVzsbAaBWFoaaiLbLCbROUhcjtOHMxwOaDjGqNevYQwXnKXwCuwPcNBlOiztOybBPbesblgIjK"
	//687463744a63706e797a3a766152472f4f43454e712f6e544a58655474626574734c566b654276485259756269785747434657764a6e4b74665567747365784a5957754f6761746c766e6d584f6b70424a697a6d664a4f756f6b726c55666a656274436b4f734850436f6553636c4d4657516574734d616d6166516e666c5557795472467462477964556246796c4a69794a654e726166466865566f4e6d41507a6e4c705266586c586a4c7274576c736769634c666c6d5257507a634f6b2e624d7a4e73765043617a48515a496849687146634d5253687a756e507079707a4c4a467a57706e6f6f4759785647444f6d784d7664534456516e5441574f6d705642784357737356475a70656c4665776e4963524e2f4d456f4f446d7650496765575756796d6b6a66596d6f446d4e5852694f6a5163746a6a414d4859695a4955706d75777237794150586a424a735a56616c69567a5747724e7571576b464436665267664d695a6f676671666f4a4479716949437a597a4956636a624a6e66456269565a71495a596a4847614771794457456d774c482f4455744b6167684f5a4377536b447771687a56737a6b524449755666726c4365784d74555a7467766c454c694277456f567a736241614257466f6161694c624c4362524f5568636a744f484d78774f61446a47714e6576595177586e4b587743757750634e426c4f697a744f79624250626573626c67496a4b
	
	function catherine.version.Check( pl )
		http.Fetch( catherine.cryptoX2.Decode( url ),
			function( body )
				local globalVer = catherine.net.GetNetGlobalVar( "cat_needUpdate", false )
				local foundNew = false
				
				if ( body != catherine.version.Ver ) then
					if ( globalVer == false ) then
						catherine.net.SetNetGlobalVar( "cat_needUpdate", true )
					end
					
					catherine.util.Print( Color( 0, 255, 255 ), "This server should update to the latest version of Catherine! [" .. catherine.version.Ver .. " -> " .. body .. "]" )
					foundNew = true
				else
					foundNew = false
					
					if ( globalVer == true ) then
						catherine.net.SetNetGlobalVar( "cat_needUpdate", false )
					end
				end
				
				if ( IsValid( pl ) ) then
					netstream.Start( pl, "catherine.version.CheckResult", {
						false,
						foundNew and LANG( pl, "Version_Notify_FoundNew" ) or LANG( pl, "Version_Notify_AlreadyNew" )
					} )
				end
			end, function( err )
				catherine.util.Print( Color( 255, 0, 0 ), "Update check error! - " .. err )
				
				if ( IsValid( pl ) ) then
					netstream.Start( pl, "catherine.version.CheckResult", {
						false,
						LANG( pl, "Version_Notify_CheckError", err )
					} )
				end
			end
		)
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
		if ( IsValid( catherine.vgui.version ) ) then
			catherine.vgui.version.status = data[ 1 ]
			catherine.vgui.version:Refresh( )
		end
		
		Derma_Message( data[ 2 ], LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
	end )
end