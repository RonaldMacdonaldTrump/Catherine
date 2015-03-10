local Plugin = Plugin

Plugin.IsLoaded = Plugin.IsLoaded or false
Plugin.datas = Plugin.datas or {
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

netstream.Hook( "catherine.plugin.bugreport.Send", function( caller, data )
	Plugin:SendBugReport( caller, data[ 1 ], data[ 2 ] )
end )

function Plugin:FetchUserKey( )
	http.Post( catherine.encrypt.Decode( self.datas.UserURL ),
		{
			api_dev_key = catherine.encrypt.Decode( self.datas.APIKey ),
			api_user_name = catherine.encrypt.Decode( self.datas.ID ),
			api_user_password = catherine.encrypt.Decode( self.datas.PWD )
		},
		function( data )
			self.datas.UserKey = data
			catherine.util.Print( Color( 0, 255, 0 ), "[Bug Report] Finished fetch user key!" )
		end,
		function( err )
			catherine.util.Print( Color( 255, 0, 0 ), "[Bug Report] Can't fetch user key! - " .. err )
		end
	)
end

function Plugin:SendBugReport( pl, title, value )
	if ( !IsValid( pl ) ) then return end
	local function createCode( )
		return Format( self.datas.Formats, pl:SteamName( ), pl:SteamID( ), pl:SteamID64( ), GetConVarString( "hostname" ), title, value )
	end
	if ( self.datas.UserKey == "" ) then netstream.Start( pl, "catherine.plugin.bugreport.SendResult", "[SERVER ERROR] Missing user account key." ) self:FetchUserKey( ) return end
	
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

function Plugin:PlayerAuthed( pl )
	if ( self.IsLoaded ) then return end
	if ( self.datas.UserKey != "" ) then return end
	self:FetchUserKey( )
	self.IsLoaded = true
end