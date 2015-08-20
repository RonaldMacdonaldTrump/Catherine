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

catherine.hint = catherine.hint or { }
catherine.hint.lists = { }

function catherine.hint.Register( message, canLook )
	catherine.hint.lists[ #catherine.hint.lists + 1 ] = {
		message = message,
		canLook = canLook
	}
end

if ( SERVER ) then
	catherine.hint.NextTick = catherine.hint.NextTick or CurTime( ) + catherine.configs.hintInterval
	
	function catherine.hint.Work( )
		local rand = math.random( 1, #catherine.hint.lists )
		local hintTable = catherine.hint.lists[ rand ]

		for k, v in pairs( hintTable and player.GetAllByLoaded( ) or { } ) do
			if ( v:GetInfo( "cat_convar_hint" ) == "0" ) then continue end
			if ( hook.Run( "CanSendHint", v, hintTable ) == false or ( hintTable.canLook and hintTable.canLook( v ) == false ) ) then continue end
			
			netstream.Start( v, "catherine.hint.Receive", rand )
		end
	end
	
	function catherine.hint.Think( )
		if ( #catherine.hint.lists != 0 and catherine.hint.NextTick <= CurTime( ) ) then
			catherine.hint.Work( )
			
			catherine.hint.NextTick = CurTime( ) + catherine.configs.hintInterval + math.random( 10, 20 )
		end
	end

	hook.Add( "Think", "catherine.hint.Think", catherine.hint.Think )
else
	catherine.hint.curHint = catherine.hint.curHint or nil
	
	netstream.Hook( "catherine.hint.Receive", function( data )
		local msg = catherine.util.StuffLanguage( catherine.hint.lists[ data ].message )
		surface.SetFont( "catherine_normal20" )
		local tw, th = surface.GetTextSize( msg )
		
		catherine.hint.curHint = {
			message = msg,
			time = CurTime( ) + 15,
			targetX = ScrW( ) - ( tw / 2 ) - 10,
			x = ScrW( )
		}
	end )
	
	function catherine.hint.Draw( )
		if ( !catherine.hint.curHint or GetConVarString( "cat_convar_hint" ) == "0" ) then return end
		if ( hook.Run( "CanDrawHint", catherine.pl, catherine.hint.curHint ) == false ) then return end
		local t = catherine.hint.curHint
		
		if ( t.time <= CurTime( ) ) then
			t.x = Lerp( 0.003, t.x, ScrW( ) * 1.5 )
			
			if ( t.x >= ScrW( ) * 1.3 ) then
				catherine.hint.curHint = nil
				return
			end
		else
			t.x = Lerp( 0.03, t.x, t.targetX )
		end
		
		draw.SimpleText( t.message, "catherine_normal20", t.x, 5, Color( 255, 255, 255, 255 ), 1 )
	end
end

for i = 1, 5 do
	catherine.hint.Register( "^Hint_Message_0" .. i )
end