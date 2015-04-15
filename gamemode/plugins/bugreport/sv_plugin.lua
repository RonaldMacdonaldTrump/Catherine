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

local PLUGIN = PLUGIN

PLUGIN.IsLoaded = PLUGIN.IsLoaded or false
PLUGIN.datas = PLUGIN.datas or {
	APIKey = "bag6mFbPuj1tzeT2ZqBBmdMUXdoFbSftWTvMbbplalAeV3TywDyVvgafkUjRGOzenN4gHESPOUzYkm0soGKJAslQgiC4pykojDuxCJazLacNCYSsbjHUyGUdaksYXcRYcVyWueYdbPEuhQuUzeFNTZPqbbGeRCxTFAueizIIRYqdhzXQSFFaJSDKKTTjsS4JghIjWXYxmJSeXhWcobcTUfnrKAwZGuVYWmysQCkcTCSsCkmeEteHQyKsffKKn4mfzflhujztGHaxcNyBTdDObVLOPQFHAJdOhQaQDuBBUlxd8hnOoCIDEOfNQOjVIUGHDSyFpbGBXOEVJBDjjmzOwovZQruzCbSbkUofiOfBFvmYJqTSEwbEUqJpUT8ZoePNHuuFYFcalbBvEhSbrPngZb4dAEpyaZaRwgqFAtjwYBsFExBeutEfNTZDqHwovpjSgzhzapKKpAFebzaaE7uaesbjMmxhVXNbaKPbrkDMGUFoUezX1BjwCnGPheVMiLMYINORBepikeSHmNZR",
	UserKey = "",
	Formats = [[
Player Steam Name : %s
Player Steam ID : %s
Player Steam ID 64 : %s
Hostname : %s
Report Title : %s

Report Value :
%s
	]],
	ID = "L7pDyz_ReCRkzHQeboFKcphKVdUHoohocbszryhLnOBBltUWDWzUyrzIWOXoMNudAkDzPDTULqwJkF0ZAPlRBqUlYJk1FZqjaGpdKVAFc",
	PWD = "12H3UZ4cdI5vfKp6WvxKr7DKiiiA8laUsXul9KLskBqHz0hlBLRONNulMjZzPpzAIo7RXFnLCqnlnQdLlCBYoJmfCyt",
	CreateURL = "htktvRpZbG:fwsQ/gNTLW/WygSiLpKncvTHjaMhJCrKngsjTmQQCtPCtqMoSiNDUFqeJqVauifHUaRbCpTBfMqxwBESifmGMWFsLWUivNnLwRAegMWLQKEMd.iUkcjtgIyTykJffcQAjZUAfdiMfvYVFZoSkeCIiYIgocOfxLekmIyWBdNFbiwcEjmDuiD/ypfIGcuvdfbPQnnbmYPaBxgZSNiyWYGzFBbUIxRspOqjMlXTVUGtguvHgKRRZriRNbayKrDzdhmicrJOcevxt/BzTYMVVrKMmojZvznEeWNxlaNzTKeBRaehppZdXxYZncEQwKpwGjwbIjQztYTfZwlFCJjXYPkziOXLRjluhsAEqOIjIIKUCeCoyIS_TTogJLUFZCdozkcgoLqUgBaDyuspeORPWjIIuWOXAZUjWktuPSHDKdpaoRRiuLFoxcOpVPRpaylOgbFaVnGmQosOgLYvhplffARrQPOIvByfYxLYmReZxtwbvVYHNCDAKMJjdQebfCMYDXSIfrwBw.BrnjopQjddhQlyLUJAuwUZaLrCeXNPhlpJnPmDZTNQiXRtFrKgMxshjjmqcSSrdcVehfnhJdKVZprhnZQoFOuNJEodRSxWHmOrxoKpxwsFTsTIiaqhCEhTedVDlHCDnXgVAMBDKcD",
	UserURL = "htVtRYpjnm:IHtz/XDRaV/CElqTdpLsBsdMHaYMInYJCGsQhjpdGFFNtpTggFiwcGNegNAHPgCvneQbauNtnrSwiMNeibRzNBaEWHXMHknjvAlFBBwiNBJzK.RWGlwJDalHCYafycCWMxQjBWTUSvkUEOoilaSSBwYEtNJvClUbmPZjGAzbttlaZvwcCsA/fWdsUiLnGRcsWxGJgKOaooQJkXyxtruQlYAULSgjpORImvAkDzJAMNTNiGBxGQiEQmoiorpHwNHEiMdqAOYtF/UYbwWRdzqyEKSiXtqZYnqGtaRahUvnAZSRkUTpLIkvWONmUHpVcbAYoPyHpjIYhCfAoCXSfOvLikkFWJjipcNwynVFaBmExzDOKli_chJXwbBvLTIpBbDeSorNWMFRAHolIDjfweAEdrLrqhtNOIbuWoZkvgwooITSrdRJnxUUThDdqrpZZyvZMqNxLUgjxzOEcnuZGjDxlYXNTqQMQevkfQxowiODrsfxTUsgwWHObQKFMoVQdkZlpxubUnZGTqLworSpjbuIqNeUVrrDjAvLHIKWyh.ZpShgonFodbdRSSvUrofqUaRZGBaVOICgpBPMPjTkFfxROhzcPggEzsJiIDxLiZuGgaxhZIUvnEnYZMegyQuUykxVEjitACRwLpnBAJvpUDzSEROtPyivLqsrxBrZRLZkvNIYIizZmUCP"
}

netstream.Hook( "catherine.plugin.bugreport.Send", function( pl, data )
	PLUGIN:SendBugReport( pl, data[ 1 ], data[ 2 ] )
end )

function PLUGIN:FetchUserKey( )
	http.Post( catherine.encrypt.Decode( self.datas.UserURL ),
		{
			api_dev_key = catherine.encrypt.Decode( self.datas.APIKey ),
			api_user_name = catherine.encrypt.Decode( self.datas.ID ),
			api_user_password = catherine.encrypt.Decode( self.datas.PWD )
		},
		function( data )
			self.datas.UserKey = data
		end,
		function( err )
			catherine.util.Print( Color( 255, 0, 0 ), "[Bug Report] Can't fetch user key! - " .. err )
		end
	)
end

function PLUGIN:SendBugReport( pl, title, value )
	local function createCode( )
		return Format( self.datas.Formats, pl:SteamName( ), pl:SteamID( ), pl:SteamID64( ), GetConVarString( "hostname" ), title, value )
	end
	
	if ( self.datas.UserKey == "" ) then
		netstream.Start( pl, "catherine.plugin.bugreport.SendResult", "[SERVER ERROR] Missing user account key." )
		self:FetchUserKey( )
		return
	end
	
	http.Post( catherine.encrypt.Decode( self.datas.CreateURL ),
		{
			api_dev_key = catherine.encrypt.Decode( self.datas.APIKey ),
			api_option = "paste",
			api_paste_code = createCode( ),
			api_user_key = self.datas.UserKey,
			api_paste_private = "2",
			api_paste_expire_date = "N",
			api_paste_format = "text",
			api_paste_name = pl:SteamName( ) .. "'s bug report."
		},
		function( data )
			pl:SetNWBool( "catherine.plugin.bugreport.Cooltime", true )
			timer.Create( "catherine.plugin.bugreport.Cooltime_" .. pl:SteamID( ), 500, 1, function( )
				if ( !IsValid( pl ) ) then return end
				pl:SetNWBool( "catherine.plugin.bugreport.Cooltime", false )
			end )
			netstream.Start( pl, "catherine.plugin.bugreport.SendResult", true )
			catherine.util.Print( Color( 0, 255, 0 ), "[Bug Report] Finished report!" )
		end,
		function( err )
			netstream.Start( pl, "catherine.plugin.bugreport.SendResult", "[SERVER ERROR] " .. err )
			catherine.util.Print( Color( 255, 0, 0 ), "[Bug Report] Can't report! - " .. err )
		end
	)
end

function PLUGIN:PlayerAuthed( pl )
	if ( self.IsLoaded ) then return end
	if ( self.datas.UserKey != "" ) then return end
	
	self:FetchUserKey( )
	self.IsLoaded = true
end