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

catherine.chat = catherine.chat or { }
catherine.chat.Classes = { }

function catherine.chat.RegisterClass( class, tab )
	table.Merge( tab, { class = class } )
	catherine.chat.Classes[ #catherine.chat.Classes + 1 ] = tab
end

function catherine.chat.FindByClass( class )
	for k, v in pairs( catherine.chat.Classes ) do
		if ( v.class == class ) then
			return v
		end
	end
end

function catherine.chat.PreSet( text )
	return "\"" .. text .. "\""
end

function catherine.chat.FetchClassByText( text )
	for k, v in pairs( catherine.chat.Classes ) do
		local command = v.command or ""
		
		if ( type( command ) == "table" ) then
			for k2, v2 in pairs( command ) do
				if ( text:sub( 1, #v2 ) == v2 ) then
					return v.class or "ic"
				end
			end
		end
	end
	
	return "ic"
end

catherine.chat.RegisterClass( "ic", {
	onChat = function( pl, text )
		local name, desc = hook.Run( "GetPlayerInformation", LocalPlayer( ), pl )
		
		if ( hook.Run( "GetUnknownTargetName", LocalPlayer( ), pl ) == name ) then
			name = desc
		end
		
		chat.AddText( Color( 255, 255, 150 ), LANG( "Chat_Str_IC", name, catherine.chat.PreSet( text ) ) )
	end,
	canHearRange = 300,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.RegisterClass( "me", {
	onChat = function( pl, text )
		chat.AddText( Color( 255, 150, 255 ), "** " .. pl:Name( ) .. " " .. text )
	end,
	command = { "/me" },
	canHearRange = 1500,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.RegisterClass( "it", {
	onChat = function( pl, text )
		chat.AddText( Color( 255, 150, 0 ), "*** " .. pl:Name( ) .. " " .. text )
	end,
	command = { "/it" },
	canHearRange = 1000,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.RegisterClass( "roll", {
	onChat = function( pl, text )
		local name, desc = hook.Run( "GetPlayerInformation", LocalPlayer( ), pl )
		
		if ( hook.Run( "GetUnknownTargetName", LocalPlayer( ), pl ) == name ) then
			name = desc
		end
		
		chat.AddText( Color( 158, 122, 19 ), LANG( "Chat_Str_Roll", name, catherine.chat.PreSet( text ) ) )
	end,
	canHearRange = 600,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.RegisterClass( "pm", {
	onChat = function( pl, text, ex )
		chat.AddText( Color( 255, 255, 0 ), "[PM] " .. pl:Name( ) .. " : " .. text )
	end,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.RegisterClass( "event", {
	onChat = function( _, text )
		chat.AddText( Color( 194, 93, 39 ), text )
	end,
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	command = { "/event" }
} )

catherine.chat.RegisterClass( "yell", {
	onChat = function( pl, text )
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

catherine.chat.RegisterClass( "whisper", {
	onChat = function( pl, text )
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

catherine.chat.RegisterClass( "ooc", {
	onChat = function( pl, text )
		local icon = Material( "icon16/user.png" )
		
		if ( pl:IsSuperAdmin( ) ) then
			icon = Material( "icon16/shield.png" )
		elseif ( pl:IsAdmin( ) ) then
			icon = Material( "icon16/star.png" )
		end
		
		chat.AddText( icon, Color( 250, 40, 40 ), "[OOC] ", pl, color_white, " : ".. text )
	end,
	global = true,
	command = {
		"/ooc", "//"
	},
	noSpace = true
} )

catherine.chat.RegisterClass( "looc", {
	onChat = function( pl, text )
		chat.AddText( Color( 250, 255, 40 ), "[LOOC] ", pl, color_white, " : ".. text )
	end,
	canHearRange = 600,
	command = {
		"/looc", ".//", "[["
	},
	noSpace = true
} )

catherine.chat.RegisterClass( "connect", {
	onChat = function( pl, text )
		local icon = Material( "icon16/user.png" )
		
		if ( pl:IsSuperAdmin( ) ) then
			icon = Material( "icon16/shield.png" )
		elseif ( pl:IsAdmin( ) ) then
			icon = Material( "icon16/star.png" )
		end
		
		chat.AddText( icon, Color( 50, 255, 50 ), LANG( "Chat_Str_Connect", pl:SteamName( ) ) )
	end,
	global = true
} )

catherine.chat.RegisterClass( "disconnect", {
	onChat = function( pl, text )
		local icon = Material( "icon16/user.png" )
		
		if ( pl:IsSuperAdmin( ) ) then
			icon = Material( "icon16/shield.png" )
		elseif ( pl:IsAdmin( ) ) then
			icon = Material( "icon16/star.png" )
		end
		
		chat.AddText( icon, Color( 50, 255, 50 ), LANG( "Chat_Str_Disconnect", pl:SteamName( ) ) )
	end,
	global = true
} )

if ( SERVER ) then
	function catherine.chat.Send( pl, classTable, text, target, ... )
		if ( type( classTable ) == "string" ) then
			classTable = catherine.chat.FindByClass( classTable )
		end
		
		if ( !classTable or type( classTable ) != "table" ) then return end
		local class = classTable.class
		
		if ( classTable.global and !target ) then
			catherine.netXync.Send( nil, "catherine.chat.Post", { pl, class, text, { ... } } )
		else
			if ( type( target ) == "table" and #target > 0 ) then
				for k, v in pairs( target ) do
					catherine.netXync.Send( v, "catherine.chat.Post", { pl, class, text, { ... } } )
				end
			else
				local listener = catherine.chat.GetListener( pl, class )
				
				for k, v in pairs( listener ) do
					catherine.netXync.Send( v, "catherine.chat.Post", { pl, class, text, { ... } } )
				end
			end
		end
	end
	
	function catherine.chat.GetListener( pl, class )
		local classTable = catherine.chat.FindByClass( class )
		local target = { pl }
		
		if ( !classTable or !classTable.canHearRange ) then return target end
		
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			if ( pl != v and catherine.util.CalcDistanceByPos( pl, v ) <= classTable.canHearRange ) then
				target[ #target + 1 ] = v
			end
		end
		
		return target
	end
	
	function catherine.chat.CanChat( pl, classTable )
		return classTable.canRun and classTable.canRun( pl ) or true
	end
	
	function catherine.chat.Work( pl, text )
		local class = catherine.chat.FetchClassByText( text )
		local classTable = catherine.chat.FindByClass( class )
		if ( !classTable ) then return end
		
		if ( !catherine.chat.CanChat( pl, classTable ) ) then
			catherine.util.Notify( pl, "You can run this work now!" )
			return
		end

		local commandTable = classTable.command or { }
		if ( type( commandTable ) == "table" and #commandTable > 1 ) then
			table.sort( classTable.command, function( a, b )
				return #a > #b
			end )
		end
		
		local fix, isFin, noSpace = "", false, classTable.noSpace
		
		if ( type( commandTable ) == "table" ) then
			for k, v in ipairs( commandTable ) do
				if ( text:sub( 1, #v + ( noSpace and 0 or 1 ) ) == v .. ( noSpace and "" or " " ) ) then
					isFin = true
					fix = v .. ( noSpace and "" or " " )
					break
				end
			end
		elseif ( type( commandTable ) == "string" ) then
			isFin = text:sub( 1, #commandTable + ( noSpace and 1 or 0 ) ) == commandTable .. ( noSpace and "" or " " )
			fix = commandTable .. ( noSpace and "" or " " )
		end

		if ( isFin ) then
			text = text:sub( #fix + 1 )
			
			if ( noSpace and text:sub( 1, 1 ):match( "%s" ) ) then
				text = text:sub( 2 )
			end
		end

		if ( catherine.command.IsCommand( text ) ) then
			catherine.command.RunByText( pl, text )
			return
		end
		
		local adjustInfo = {
			text = text,
			class = class,
			player = pl
		}
		
		adjustInfo = hook.Run( "ChatAdjust", adjustInfo ) or adjustInfo
		catherine.chat.Send( pl, classTable, ( hook.Run( "ChatPrefix", pl, adjustInfo.class ) or "" ) .. adjustInfo.text )
		hook.Run( "ChatSended", adjustInfo )
	end
	
	function catherine.chat.RunByClass( pl, class, text, target, ... )
		local classTable = catherine.chat.FindByClass( class )
		if ( !classTable ) then return end
		
		local adjustInfo = {
			text = text,
			class = class,
			player = pl
		}
		
		adjustInfo = hook.Run( "ChatAdjust", adjustInfo ) or adjustInfo
		catherine.chat.Send( pl, classTable, ( hook.Run( "ChatPrefix", pl, adjustInfo.class ) or "" ) .. adjustInfo.text, target, ... )
		hook.Run( "ChatSended", adjustInfo )
	end
	
	catherine.netXync.Receiver( "catherine.chat.Run", function( pl, data )
		hook.Run( "PlayerSay", pl, data, true )
	end )
else
	catherine.chat.backpanel = catherine.chat.backpanel or nil
	catherine.chat.chatpanel = catherine.chat.chatpanel or nil
	catherine.chat.isOpened = catherine.chat.isOpened or false
	catherine.chat.msg = catherine.chat.msg or { }
	catherine.chat.history = catherine.chat.history or { }

	local CHATBox_w, CHATBox_h = ScrW( ) * 0.5, ScrH( ) * 0.3
	local CHATBox_x, CHATBox_y = 5, ScrH( ) - CHATBox_h - 5
	
	catherine.netXync.Receiver( "catherine.chat.Post", function( data )
		if ( !IsValid( LocalPlayer( ) ) or !LocalPlayer( ):IsCharacterLoaded( ) ) then return end
		local speaker, class, text, ex = data[ 1 ], data[ 2 ], data[ 3 ], data[ 4 ]
		local class = catherine.chat.FindByClass( class )
		if ( !IsValid( speaker ) ) then return end
		
		class.onChat( speaker, text, ex )
	end )
	
	catherine.hud.RegisterBlockModule( "CHudChat" )

	hook.Add( "PlayerBindPress", "catherine.chat.PlayerBindPress", function( pl, code, pressed )
		if ( code:find( "messagemode" ) and pressed ) then
			catherine.chat.SetStatus( true )
			
			return true
		end
	end )

	chat.AddTextBuffer = chat.AddTextBuffer or chat.AddText
	
	function chat.AddText( ... )
		if ( !LocalPlayer( ):IsCharacterLoaded( ) ) then return end
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
		catherine.chat.backpanel:SetSize( CHATBox_w, CHATBox_h - 30 )
		catherine.chat.backpanel.Paint = function( ) end

		catherine.chat.backpanel.history = vgui.Create( "DScrollPanel", catherine.chat.backpanel )
		catherine.chat.backpanel.history:Dock( FILL )
		catherine.chat.backpanel.history.VBar:SetWide( 0 )
	end
	
	function catherine.chat.SetStatus( bool )
		if ( !LocalPlayer( ):IsCharacterLoaded( ) ) then return end
		
		catherine.chat.CreateBase( )
		catherine.chat.isOpened = bool
		
		local self = catherine.chat.chatpanel
		
		local initHistoryKey = #catherine.chat.history + 1
		local onEnterFunc = function( pnl )
			local text = pnl:GetText( )
			
			if ( text != "" ) then
				text = string.utf8sub( text, 1 )
				catherine.netXync.Send( "catherine.chat.Run", text )
				catherine.chat.history[ #catherine.chat.history + 1 ] = text
				
				if ( #catherine.chat.history > 20 ) then
					table.remove( catherine.chat.history, 1 )
				end
			end
			
			catherine.chat.isOpened = false
			
			self:Remove( )
			self = nil
			hook.Run( "FinishChat" )
		end
		
		self = vgui.Create( "EditablePanel", self )
		self:SetPos( CHATBox_x, CHATBox_y + CHATBox_h - 25 )
		self:SetSize( CHATBox_w, 25 )
		self.Paint = function( ) end
		
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