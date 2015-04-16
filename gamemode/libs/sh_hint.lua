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
catherine.hint.Lists = { }

function catherine.hint.Register( message, canLook )
	catherine.hint.Lists[ #catherine.hint.Lists + 1 ] = { message = message, canLook = canLook }
end

if ( SERVER ) then
	catherine.hint.NextSendTick = catherine.hint.NextSendTick or CurTime( ) + catherine.configs.hintInterval
	
	function catherine.hint.Work( )
		local rand = math.random( 1, #catherine.hint.Lists )
		local hintTable = catherine.hint.Lists[ rand ]

		for k, v in pairs( hintTable and player.GetAllByLoaded( ) or { } ) do
			if ( v:GetInfo( "cat_convar_hint" ) == "0" or hintTable.canLook and hintTable.canLook( v ) == false ) then continue end
			
			netstream.Start( v, "catherine.hint.Receive", rand )
		end
	end
	
	function catherine.hint.Think( )
		if ( #catherine.hint.Lists == 0 ) then return end
		
		if ( catherine.hint.NextSendTick <= CurTime( ) ) then
			catherine.hint.Work( )
			catherine.hint.NextSendTick = CurTime( ) + catherine.configs.hintInterval + math.random( 10, 20 )
		end
	end

	hook.Add( "Think", "catherine.hint.Think", catherine.hint.Think )
else
	catherine.hint.CurHint = catherine.hint.CurHint or nil
	
	CAT_CONVAR_HINT = CreateClientConVar( "cat_convar_hint", 1, true, true )
	catherine.option.Register( "CONVAR_HINT", "cat_convar_hint", "Hint", "Displays the hint.", "Framework Settings", CAT_OPTION_SWITCH )
	
	netstream.Hook( "catherine.hint.Receive", function( data )
		local msg = catherine.hint.Lists[ data ].message
		surface.SetFont( "catherine_normal25" )
		local tw, th = surface.GetTextSize( msg )
		
		catherine.hint.CurHint = {
			message = msg,
			time = CurTime( ) + 15,
			targetX = ScrW( ) - ( tw / 2 ) - 10,
			x = ScrW( )
		}
	end )
	
	function catherine.hint.Draw( )
		if ( !catherine.hint.CurHint ) then return end
		local t = catherine.hint.CurHint

		if ( t.time <= CurTime( ) ) then
			t.x = Lerp( 0.003, t.x, ScrW( ) * 1.5 )
			
			if ( math.Round( t.x ) >= ScrW( ) * 1.3 ) then
				catherine.hint.CurHint = nil
				return
			end
		else
			t.x = Lerp( 0.03, t.x, t.targetX )
		end

		draw.SimpleText( t.message, "catherine_normal25", t.x, 5, Color( 255, 255, 255, 255 ), 1 )
	end
end

catherine.hint.Register( "Type // before your message to talk out-of-character." )
catherine.hint.Register( "Type .// or [[ before your message to talk out-of-character locally." )
catherine.hint.Register( "Press 'F1 key' to view your character and roleplay information." )
catherine.hint.Register( "Press 'Tab key' to view the main menu." )