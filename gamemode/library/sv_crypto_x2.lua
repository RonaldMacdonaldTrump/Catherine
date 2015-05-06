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

catherine.cryptoX2 = catherine.cryptoX2 or { }
local se = string.Explode
local sc = string.char
local mr = math.random
local tc = table.concat

function catherine.cryptoX2.Encode( text )
	local toTable = se( "", text )
	local k = 0
	
	for i = 1, #toTable do
		local randStr = ""
		
		if ( k != 0 ) then
			for i2 = 1, k do
				local charRand = sc( mr( 65, 90 ) )
				local sizeRand = mr( 0, 1 )
				
				if ( sizeRand == 1 ) then
					charRand = charRand:lower( )
				end
				
				randStr = randStr .. charRand
			end
		end
		
		k = k + 1
		toTable[ i ] = toTable[ i ] .. randStr
	end

	return tc( toTable, "" )
end

function catherine.cryptoX2.Decode( text )
	local tab = { }
	local a = 1
	local b = 1
	local ap = 0
	local bp = 1
	
	for i = 1, #text do
		local find = text:sub( a, b )
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

	return tc( tab, "" )
end

--[[ 이게 더 좋은가;?
function catherine.cryptoX2.Decode( text )
	local tab = { }
	local a = 1
	local b = 1
	local ap = 0
	local bp = 1
	
	for i = 1, #text do
		local find = text:sub( a, b )
		if ( find == "" ) then break end
		
		ap = ap + 1
		bp = bp + 1
		a = a + ap
		b = b + bp
		
		tab[ #tab + 1 ] = find
	end
	
	local result = ""
	for i = 1, #tab do
		result = result .. tab[ i ]:sub( 1, 1 )
		
		if ( i == #tab ) then
			return result
		end
	end
end
--]]