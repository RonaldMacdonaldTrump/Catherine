--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Develop by L7D.

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

catherine.encrypt = catherine.encrypt or { }

function catherine.encrypt.Encode( str )
	if ( !str or type( str ) != "string" ) then return "" end
	local toTable, k = string.Explode( "", str ), 0
	
	for i = 1, #toTable do
		local randStr = ""
		if ( k != 0 ) then
			for i2 = 1, k do
				local charRand = string.char( math.random( 65, 90 ) )
				local sizeRand = math.random( 0, 1 )
				if ( sizeRand == 1 ) then charRand = charRand:lower( ) end
				randStr = randStr .. charRand
			end
		end
		k = k + 1
		toTable[ i ] = toTable[ i ] .. randStr
	end

	return table.concat( toTable, "" )
end

function catherine.encrypt.Decode( str )
	if ( !str or type( str ) != "string" ) then return "" end
	local tab, a, b, ap, bp = { }, 1, 1, 0, 1
	
	for i = 1, #str do
		local find = str:sub( a, b )
		if ( find == "" ) then break end
		
		ap = ap + 1
		bp = bp + 1
		a = a + ap
		b = b + bp
		
		tab[ #tab + 1 ] = find
	end
	
	for i = 1, #tab do
		tab[ i ] = tab[ i ]:sub( 1, 1 )
	end

	return table.concat( tab, "" )
end