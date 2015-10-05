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

catherine.news = catherine.news or { }

if ( SERVER ) then
	catherine.news.updated = catherine.news.updated or false
	catherine.news.lists = catherine.news.lists or { }
	
	function catherine.news.Update( )
		http.Fetch( catherine.crypto.Decode( "htKtwXpOKj:osZW/FKyaS/cePEaDtjXPVhUpeANnCkDNOxYnhDOCkFrtUhlsbIJyfouqfdixlNwzgAphDWamfeoKSVTladyTGPIxHoWDsofTuLFsTXrtCCrIaUofyHxsftcNOcBmdqIAncnHntLiBpnEpeNymozJFYaQCWxZAejrihJsoPZyEwfQeDBjpL.EBlfjSwvCQludrtLTGCcssLZjQMMjBxBUqruBfsDoHoWrTOHGivzSRRemAXhHPmGHYNeHBCkIjmbLcWZwdXFz/obGtetMLvRrdznpvfIZfsiqaGucNipWwMxYQHUyyMXZxsjeS1ADjyDgciJOWcbbrpGJQJIYZaRgSAeQpWCXFuzVBrzHxADcgScoED3vldaZKTlcjnhAZESWvDYPdeBnedcEjhoVmGOfUlNyuolWlWpRftJxeUz/rtidpmIGetPhkRgISUObhITTNafCernrgUMnqkCItHwsYbIrZVJWNiuinNknaNuJOUCiaewCdyOaqpzTZKXIjphkdRjawmMjAPXhvqxaseJtVkMbzgqFIBAJxmziu" ),
			function( data )
				if ( data:find( "Error 404</p>" ) ) then
					MsgC( Color( 255, 0, 0 ), "[CAT News ERROR] Failed to update news data! [404 ERROR]\n" )
					return
				end

				if ( data:find( "<!DOCTYPE HTML>" ) or data:find( "<title>Textuploader.com" ) ) then
					MsgC( Color( 255, 0, 0 ), "[CAT News ERROR] Failed to update news data! [Unknown Error]\n" )
					return
				end
			
				local val = util.JSONToTable( data )
				
				if ( val ) then
					catherine.net.SetNetGlobalVar( "cat_news", val )
				end
			end, function( err )
				MsgC( Color( 255, 0, 0 ), "[CAT News ERROR] Failed to update news data! [" .. err .. "]\n" )
			end
		)
	end
	
	function catherine.news.PlayerLoadFinished( )
		if ( catherine.news.updated ) then return end

		catherine.news.Update( )
		catherine.news.updated = true
	end
	
	hook.Add( "PlayerLoadFinished", "catherine.news.PlayerLoadFinished", catherine.news.PlayerLoadFinished )
end