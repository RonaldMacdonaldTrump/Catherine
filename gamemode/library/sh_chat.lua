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

catherine.chat = catherine.chat or { lists = { } }

function catherine.chat.Register( uniqueID, classTable )
	classTable = classTable or { }
	
	table.Merge( classTable, {
		uniqueID = uniqueID
	} )
	
	if ( classTable.command and #classTable.command > 1 ) then
		table.sort( classTable.command, function( a, b )
			return string.utf8len( a ) > string.utf8len( b )
		end )
	end
	
	catherine.chat.lists[ uniqueID ] = classTable
end

function catherine.chat.GetAll( )
	return catherine.chat.lists
end

function catherine.chat.FindByID( uniqueID )
	return catherine.chat.lists[ uniqueID ]
end

function catherine.chat.FindIDByText( text )
	for k, v in pairs( catherine.chat.GetAll( ) ) do
		local command = v.command or ""
		
		for k2, v2 in pairs( type( command ) == "table" and command or { } ) do
			if ( text:sub( 1, #v2 ) != v2 ) then continue end
			
			return k or "ic"
		end
	end
	
	return "ic"
end

function catherine.chat.PreSet( text )
	return "\"" .. text .. "\""
end

catherine.chat.Register( "ic", {
	func = function( pl, text )
		local name, desc = hook.Run( "GetPlayerInformation", LocalPlayer( ), pl )
		
		if ( hook.Run( "GetUnknownTargetName", LocalPlayer( ), pl ) == name ) then
			name = desc
		end
		
		chat.AddText( Color( 255, 255, 150 ), LANG( "Chat_Str_IC", name, catherine.chat.PreSet( text ) ) )
	end,
	canHearRange = 300,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.Register( "me", {
	func = function( pl, text )
		chat.AddText( Color( 255, 150, 255 ), "** " .. pl:Name( ) .. " " .. text )
	end,
	command = { "/me" },
	canHearRange = 1500,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.Register( "it", {
	func = function( pl, text )
		chat.AddText( Color( 255, 150, 0 ), "*** " .. pl:Name( ) .. " " .. text )
	end,
	command = { "/it" },
	canHearRange = 1000,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.Register( "roll", {
	func = function( pl, text )
		local name, desc = hook.Run( "GetPlayerInformation", LocalPlayer( ), pl )
		
		if ( hook.Run( "GetUnknownTargetName", LocalPlayer( ), pl ) == name ) then
			name = desc
		end
		
		chat.AddText( Color( 158, 122, 19 ), LANG( "Chat_Str_Roll", name, catherine.chat.PreSet( text ) ) )
	end,
	canHearRange = 600,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.Register( "pm", {
	func = function( pl, text, ex )
		chat.AddText( Color( 255, 255, 0 ), "[PM] " .. pl:Name( ) .. " : " .. text )
	end,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.Register( "event", {
	func = function( _, text )
		chat.AddText( Color( 194, 93, 39 ), text )
	end,
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	command = { "/event" }
} )

catherine.chat.Register( "yell", {
	func = function( pl, text )
		local name, desc = hook.Run( "GetPlayerInformation", LocalPlayer( ), pl )
		
		if ( hook.Run( "GetUnknownTargetName", LocalPlayer( ), pl ) == name ) then
			name = desc
		end
		
		chat.AddText( Color( 255, 255, 150 ), LANG( "Chat_Str_Yell", name, catherine.chat.PreSet( text ) ) )
	end,
	canHearRange = 600,
	command = { "/y", "/yell" },
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.Register( "whisper", {
	func = function( pl, text )
		local name, desc = hook.Run( "GetPlayerInformation", LocalPlayer( ), pl )
		
		if ( hook.Run( "GetUnknownTargetName", LocalPlayer( ), pl ) == name ) then
			name = desc
		end

		chat.AddText( Color( 255, 255, 150 ), LANG( "Chat_Str_Whisper", name, catherine.chat.PreSet( text ) ) )
	end,
	canHearRange = 150,
	command = { "/w", "/whisper" },
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.Register( "ooc", {
	func = function( pl, text )
		local icon = Material( "icon16/user.png" )
		
		if ( pl:IsSuperAdmin( ) ) then
			icon = Material( "icon16/shield.png" )
		elseif ( pl:IsAdmin( ) ) then
			icon = Material( "icon16/star.png" )
		end
		
		chat.AddText( icon, Color( 250, 40, 40 ), "[OOC] ", pl, color_white, " : ".. text )
	end,
	isGlobal = true,
	command = {
		"/ooc", "//"
	},
	noSpace = true
} )

catherine.chat.Register( "looc", {
	func = function( pl, text )
		chat.AddText( Color( 250, 255, 40 ), "[LOOC] ", pl, color_white, " : ".. text )
	end,
	canHearRange = 600,
	command = {
		"/looc", ".//", "[["
	},
	noSpace = true
} )

catherine.chat.Register( "connect", {
	func = function( pl, text )
		local icon = Material( "icon16/user.png" )
		
		if ( pl:IsSuperAdmin( ) ) then
			icon = Material( "icon16/shield.png" )
		elseif ( pl:IsAdmin( ) ) then
			icon = Material( "icon16/star.png" )
		end
		
		chat.AddText( icon, Color( 50, 255, 50 ), LANG( "Chat_Str_Connect", pl:Name( ) ) )
	end,
	isGlobal = true
} )

catherine.chat.Register( "disconnect", {
	func = function( pl, text )
		local icon = Material( "icon16/user.png" )
		
		if ( pl:IsSuperAdmin( ) ) then
			icon = Material( "icon16/shield.png" )
		elseif ( pl:IsAdmin( ) ) then
			icon = Material( "icon16/star.png" )
		end
		
		chat.AddText( icon, Color( 50, 255, 50 ), LANG( "Chat_Str_Disconnect", pl.SteamName( pl ) ) )
	end,
	isGlobal = true
} )

if ( SERVER ) then
	function catherine.chat.Run( pl, text )
		local classTable = catherine.chat.FindByID( catherine.chat.FindIDByText( text ) )
		if ( !classTable ) then return end

		if ( !catherine.chat.CanChat( pl, classTable ) ) then
			catherine.util.NotifyLang( pl, "Player_Message_HasNotPermission" )
			return
		end

		local commandTable = classTable.command or { }
		local noSpace = classTable.noSpace
		
		for k, v in ipairs( type( commandTable ) == "table" and commandTable or { commandTable } ) do
			if ( text:sub( 1, #v + ( noSpace and 0 or 1 ) ) == v .. ( noSpace and "" or " " ) ) then
				text = text:sub( #( v .. ( noSpace and "" or " " ) ) + 1 )
			
				if ( noSpace and text:sub( 1, 1 ):match( "%s" ) ) then
					text = text:sub( 2 )
				end

				break
			end
		end

		if ( catherine.command.IsCommand( text ) ) then
			catherine.command.RunByText( pl, text )
			return
		end
		
		local chatInformation = {
			text = text,
			uniqueID = classTable.uniqueID,
			pl = pl
		}
		
		chatInformation = hook.Run( "OnChatControl", chatInformation ) or chatInformation
		catherine.chat.Send( pl, classTable, ( hook.Run( "ChatPrefix", pl, classTable ) or "" ) .. chatInformation.text )
		hook.Run( "ChatPosted", chatInformation )
	end
	
	function catherine.chat.Send( pl, classTable, text, target, ... )
		classTable = type( classTable ) == "string" and catherine.chat.FindByID( classTable ) or classTable
		if ( !classTable or type( classTable ) != "table" ) then return end
		local uniqueID = classTable.uniqueID

		if ( classTable.isGlobal and !target ) then
			netstream.Start( nil, "catherine.chat.Post", { pl, uniqueID, text, { ... } } )
		else
			if ( type( target ) == "table" and #target > 0 ) then
				netstream.Start( target, "catherine.chat.Post", {
					pl,
					uniqueID,
					text,
					{ ... }
				} )
			else
				netstream.Start( catherine.chat.GetListener( pl, classTable ), "catherine.chat.Post", {
					pl,
					uniqueID,
					text,
					{ ... }
				} )
			end
		end
	end
	
	function catherine.chat.GetListener( pl, classTable )
		classTable = type( classTable ) == "string" and catherine.chat.FindByID( classTable ) or classTable
		if ( !classTable or !classTable.canHearRange ) then return { pl } end
		local target = { pl }
		local range = classTable.canHearRange
		
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			if ( pl != v and catherine.util.CalcDistanceByPos( pl, v ) <= range ) then
				target[ #target + 1 ] = v
			end
		end
		
		return target
	end
	
	function catherine.chat.CanChat( pl, classTable )
		if ( classTable.canRun ) then
			return classTable.canRun( pl )
		end
		
		return true
	end
	
	function catherine.chat.RunByID( pl, uniqueID, text, target, ... )
		local classTable = catherine.chat.FindByID( uniqueID )
		if ( !classTable ) then return end
		
		local chatInformation = {
			text = text,
			uniqueID = classTable.uniqueID,
			pl = pl
		}
		
		chatInformation = hook.Run( "OnChatControl", chatInformation ) or chatInformation
		catherine.chat.Send( pl, classTable, ( hook.Run( "ChatPrefix", pl, classTable ) or "" ) .. chatInformation.text, target, ... )
		hook.Run( "ChatPosted", chatInformation )
	end
	
	netstream.Hook( "catherine.chat.Run", function( pl, data )
		hook.Run( "PlayerSay", pl, data, true )
	end )
else
	catherine.chat.backpanel = catherine.chat.backpanel or nil
	catherine.chat.chatpanel = catherine.chat.chatpanel or nil
	catherine.chat.isOpened = catherine.chat.isOpened or false
	catherine.chat.msg = catherine.chat.msg or { }
	catherine.chat.history = catherine.chat.history or { }

	local typingText = ""
	local CHATBox_w, CHATBox_h = ScrW( ) * 0.5, ScrH( ) * 0.3
	local CHATBox_x, CHATBox_y = 5, ScrH( ) - CHATBox_h - 5
	
	netstream.Hook( "catherine.chat.Post", function( data )
		if ( !IsValid( LocalPlayer( ) ) or !LocalPlayer( ).IsCharacterLoaded( LocalPlayer( ) ) ) then return end
		local speaker = data[ 1 ]
		local classTable = catherine.chat.FindByID( data[ 2 ] )
		local text = data[ 3 ]
		local ex = data[ 4 ]

		if ( classTable and IsValid( speaker ) ) then
			classTable.func( speaker, text, ex )
		end
	end )
	
	catherine.hud.RegisterBlockModule( "CHudChat" )
	
	chat.AddTextBuffer = chat.AddTextBuffer or chat.AddText
	
	function chat.AddText( ... )
		if ( !LocalPlayer( ).IsCharacterLoaded( LocalPlayer( ) ) ) then return end
		local data = { }
		local lastColor = Color( 255, 255, 255 )

		for k, v in pairs( { ... } ) do
			data[ k ] = v
		end

		catherine.chat.AddText( unpack( data ) )
		chat.PlaySound( )

		for k, v in ipairs( data ) do
			if ( type( v ) != "Player" ) then continue end
			local pl, index = v, k
			
			table.remove( data, index )
			table.insert( data, index, team.GetColor( pl:Team( ) ) )
			table.insert( data, index + 1, pl:Name( ) )
		end
		
		return chat.AddTextBuffer( unpack( data ) )
	end
	
	function catherine.chat.AddText( ... )
		local msg = vgui.Create( "catherine.vgui.ChatMarkUp" )
		msg:Dock( TOP )
		msg:SetFont( "catherine_normal17" )
		msg:SetMaxWidth( CHATBox_w - 16 )
		msg:Run( ... )
		catherine.chat.msg[ #catherine.chat.msg + 1 ] = msg
		
		if ( catherine.chat.backpanel ) then
			catherine.chat.backpanel.history:AddItem( msg )
			local scrollBar = catherine.chat.backpanel.history.VBar
			scrollBar.CanvasSize = scrollBar.CanvasSize + msg:GetTall( )
			scrollBar:AnimateTo( scrollBar.CanvasSize, 0.25, 0, 0.25 )
		end
		
		if ( #catherine.chat.msg > 50 ) then
			catherine.chat.msg[ 1 ]:Remove( )
			table.remove( catherine.chat.msg, 1 )
		end
	end


	function catherine.chat.CreateBase( )
		if ( IsValid( catherine.chat.backpanel ) ) then return end
		
		catherine.chat.backpanel = vgui.Create( "DPanel" )
		catherine.chat.backpanel:SetPos( CHATBox_x, CHATBox_y )
		catherine.chat.backpanel:SetSize( CHATBox_w, CHATBox_h - 25 )
		catherine.chat.backpanel:SetDrawBackground( false )

		catherine.chat.backpanel.history = vgui.Create( "DScrollPanel", catherine.chat.backpanel )
		catherine.chat.backpanel.history:Dock( FILL )
		catherine.chat.backpanel.history.VBar:SetWide( 0 )
		catherine.chat.backpanel.history.alpha = 255
		//catherine.chat.backpanel.history
	end
	
	function catherine.chat.SetStatus( bool )
		if ( !LocalPlayer( ).IsCharacterLoaded( LocalPlayer( ) ) ) then return end
		
		catherine.chat.CreateBase( )
		catherine.chat.isOpened = bool
		
		local self = catherine.chat.chatpanel
		local initHistoryKey = #catherine.chat.history + 1
		local onEnterFunc = function( pnl )
			local text = pnl:GetText( )
			
			if ( text != "" ) then
				text = string.utf8sub( text, 1 )
				netstream.Start( "catherine.chat.Run", text )
				catherine.chat.history[ #catherine.chat.history + 1 ] = text
				
				if ( #catherine.chat.history > 20 ) then
					table.remove( catherine.chat.history, 1 )
				end
			end
			
			catherine.chat.isOpened = false
			
			self:Remove( )
			self = nil
			typingText = ""
			hook.Run( "FinishChat" )
		end
		
		catherine.chat.backpanel.PaintOver = function( pnl, w, h )
			if ( typingText.sub( typingText, 1, 1 ) == "/" ) then
				surface.SetDrawColor( 50, 50, 50, 255 )
				surface.SetMaterial( Material( "gui/gradient_up" ) )
				surface.DrawTexturedRect( 0, 0, w, h )
				
				local commands, sub = catherine.command.GetMatchCommands( typingText )
				local chatY = CHATBox_h - 25

				if ( #commands == 1 ) then
					local commandText = "/" .. commands[ 1 ].command
					surface.SetFont( "catherine_normal25" )
					local tw, th = surface.GetTextSize( commandText )
						
					draw.SimpleText( commandText, "catherine_normal25", 15, chatY - 50, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, 1 )
					draw.SimpleText( commands[ 1 ].syntax, "catherine_normal15", 30 + tw, chatY - 50, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, 1 )
					draw.SimpleText( catherine.util.StuffLanguage( commands[ 1 ].desc ), "catherine_normal20", 15, chatY - 20, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, 1 )
				else
					for k, v in pairs( commands ) do
						local yPos = chatY - ( 20 * k )
						if ( yPos <= 10 ) then continue end
						
						local commandText = "/" .. v.command
						local currText = commandText.sub( commandText, 1, sub + 1 )
						
						surface.SetFont( "catherine_normal20" )
						local tw, th = surface.GetTextSize( currText )

						draw.SimpleText( currText, "catherine_normal20", 15, yPos, Color( 150, 235, 150, 255 ), TEXT_ALIGN_LEFT, 1 )
						draw.SimpleText( commandText.gsub( commandText, currText, "" ), "catherine_normal20", 15 + tw, yPos, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, 1 )
					end
				end
				
				if ( catherine.chat.backpanel.history.alpha > 10 ) then
					catherine.chat.backpanel.history.alpha = Lerp( 0.05, catherine.chat.backpanel.history.alpha, 10 )
					catherine.chat.backpanel.history:SetAlpha( catherine.chat.backpanel.history.alpha )
				end
			else
				if ( catherine.chat.backpanel.history.alpha < 255 ) then
					catherine.chat.backpanel.history.alpha = Lerp( 0.05, catherine.chat.backpanel.history.alpha, 255 )
					catherine.chat.backpanel.history:SetAlpha( catherine.chat.backpanel.history.alpha )
				end
			end
		end
		
		self = vgui.Create( "EditablePanel", self )
		self:SetPos( CHATBox_x, CHATBox_y + CHATBox_h - 25 )
		self:SetSize( CHATBox_w, 25 )
		self.Paint = function( pnl, w, h )

		end
		
		self.textEnt = vgui.Create( "DTextEntry", self )
		self.textEnt:Dock( FILL )
		self.textEnt.OnEnter = function( pnl )
			onEnterFunc( pnl )
		end
		self.textEnt:SetAllowNonAsciiCharacters( true )
		self.textEnt.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 200 ) )
			surface.SetDrawColor( 0, 0, 0, 200 )
			surface.DrawOutlinedRect( 0, 0, w, h )
			
			pnl:DrawTextEntryText( color_black, color_black, color_black )
		end
		self.textEnt.OnTextChanged = function( pnl )
			typingText = pnl:GetText( )
			hook.Run( "ChatTextChanged", pnl:GetText( ) )
		end
		self.textEnt.OnKeyCodeTyped = function( pnl, code )
			if ( code == KEY_ENTER ) then
				onEnterFunc( pnl )
			elseif ( code == KEY_UP ) then
				if ( initHistoryKey > 1 ) then
					initHistoryKey = initHistoryKey - 1
					pnl:SetText( catherine.chat.history[ initHistoryKey ] )
					pnl:SetCaretPos( string.utf8len( catherine.chat.history[ initHistoryKey ] ) )
				end
			elseif ( code == KEY_DOWN ) then
				if ( initHistoryKey < #catherine.chat.history ) then
					initHistoryKey = initHistoryKey + 1
					pnl:SetText( catherine.chat.history[ initHistoryKey ] )
					pnl:SetCaretPos( string.utf8len( catherine.chat.history[ initHistoryKey ] ) )
				end
			end
		end

		self:MakePopup( )
		self.textEnt:RequestFocus( )
		hook.Run( "StartChat" )
	end
	
	do
		catherine.chat.CreateBase( )
	end
end

hook.Remove( "PlayerSay", "ULXMeCheck" ) // ULX -_-;