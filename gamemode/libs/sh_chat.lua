catherine.chat = catherine.chat or { }
catherine.chat.Classes = { }

function catherine.chat.RegisterClass( class, tab )
	table.Merge( tab, { class = class } )
	catherine.chat.Classes[ #catherine.chat.Classes + 1 ] = tab
end

function catherine.chat.FindByClass( class )
	if ( !class ) then return nil end
	for k, v in pairs( catherine.chat.Classes ) do
		if ( v.class == class ) then
			return v
		end
	end
	return nil
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
		chat.AddText( Color( 255, 255, 255 ), name .. " says " .. catherine.chat.PreSet( text ) )
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

catherine.chat.RegisterClass( "pm", {
	onChat = function( pl, text, ex )
		chat.AddText( Color( 255, 255, 0 ), "[PM] " .. pl:Name( ) .. " : " .. text )
	end,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.RegisterClass( "yell", {
	onChat = function( pl, text )
		local name, desc = hook.Run( "GetPlayerInformation", LocalPlayer( ), pl )
		if ( hook.Run( "GetUnknownTargetName", LocalPlayer( ), pl ) == name ) then
			name = desc
		end
		chat.AddText( Color( 255, 255, 255 ), name .. " yells " .. catherine.chat.PreSet( text ) )
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
		chat.AddText( Color( 255, 255, 255 ), name .. " whispers " .. catherine.chat.PreSet( text ) )
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

catherine.command.Register( {
	command = "pm",
	syntax = "[name] [text]",
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				if ( IsValid( target ) ) then
					catherine.chat.Send( pl, "pm", args[ 2 ], { pl, target }, target )
				else
					catherine.util.Notify( pl, "Can't found player!" )
				end
			else
				catherine.util.Notify( pl, "Please input second value!" )
			end
		else
			catherine.util.Notify( pl, "Please input first value!" )
		end
	end
} )

if ( SERVER ) then
	netstream.Hook( "catherine.chat.Run", function( pl, data )
		hook.Run( "PlayerSay", pl, data, true )
	end )
	
	function catherine.chat.Send( pl, classTable, text, target, ... )
		if ( type( classTable ) == "string" ) then
			classTable = catherine.chat.FindByClass( classTable )
		end
		if ( !classTable or type( classTable ) != "table" ) then return end
		local class = classTable.class
		
		if ( classTable.global and !target ) then
			netstream.Start( nil, "catherine.chat.Post", { pl, class, text, { ... } } )
		else
			if ( type( target ) == "table" and #target > 1 ) then
				for k, v in pairs( target ) do
					netstream.Start( v, "catherine.chat.Post", { pl, class, text, { ... } } )
				end
			else
				local listener = catherine.chat.GetListener( pl, class )
				for k, v in pairs( listener ) do
					netstream.Start( v, "catherine.chat.Post", { pl, class, text, { ... } } )
				end
			end
		end
	end
	
	function catherine.chat.GetListener( pl, class )
		local classTable, target = catherine.chat.FindByClass( class ), { pl }
		if ( !classTable or ( classTable and !classTable.canHearRange ) ) then return target end
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			if ( pl == v ) then continue end
			if ( catherine.util.CalcDistanceByPos( pl, v ) <= classTable.canHearRange ) then
				target[ #target + 1 ] = v
			end
		end
		return target
	end
	
	function catherine.chat.CanChat( pl, classTable )
		if ( !IsValid( pl ) or !classTable ) then return false end
		if ( classTable.canRun and classTable.canRun( pl ) == false ) then
			return false
		end
		return true
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
		catherine.chat.Send( pl, classTable, adjustInfo.text )
		hook.Run( "ChatSended", adjustInfo )
	end
	
	function catherine.chat.RunByClass( pl, class, text, target )
		local classTable = catherine.chat.FindByClass( class )
		if ( !classTable ) then return end
		local adjustInfo = {
			text = text,
			class = class,
			player = pl
		}
		adjustInfo = hook.Run( "ChatAdjust", adjustInfo ) or adjustInfo
		catherine.chat.Send( pl, classTable, adjustInfo.text, target )
		hook.Run( "ChatSended", adjustInfo )
	end
else
	catherine.chat.backpanel = catherine.chat.backpanel or nil
	catherine.chat.chatpanel = catherine.chat.chatpanel or nil
	catherine.chat.isOpened = catherine.chat.isOpened or false
	catherine.chat.msg = catherine.chat.msg or { }
	catherine.chat.history = catherine.chat.history or { }
	
	local CHATBox_w, CHATBox_h = ScrW( ) * 0.5, ScrH( ) * 0.3
	local CHATBox_x, CHATBox_y = 5, ScrH( ) - CHATBox_h - 5
	
	netstream.Hook( "catherine.chat.Post", function( data )
		if ( !LocalPlayer( ):IsCharacterLoaded( ) ) then return end
		local speaker, class, text, ex = data[ 1 ], data[ 2 ], data[ 3 ], data[ 4 ]
		local class = catherine.chat.FindByClass( class )
		class.onChat( speaker, text, ex )
	end )
	
	local PANEL = { }
	
	function PANEL:Init( )
		self:SetDrawBackground( false )
		self.start = CurTime( )
		self.finish = CurTime( ) + 15
	end

	function PANEL:SetMaxWidth( w )
		self.maxWidth = w
	end

	function PANEL:SetFont( font )
		self.font = font
	end

	function PANEL:Run( ... )
		local data, latestColor = "", Color( 255, 255, 255 )
		if ( self.font ) then data = "<font=" .. self.font .. ">" end

		for k, v in ipairs( { ... } ) do
			local types = type( v )
			if ( types == "table" and v.r and v.g and v.b ) then
				if ( v != latestColor ) then data = data .. "</color>" end
				latestColor = v
				data = data .. "<color="..v.r..","..v.g..","..v.b..">"
			elseif ( types == "Player" ) then
				local col = team.GetColor( v:Team( ) )
				data = data .. "<color=" .. col.r .. "," .. col.g .. "," .. col.b .. ">" .. v:Name( ) .. "</color>"
			elseif ( types == "IMaterial" or types == "table" and type( v[ 1 ] ) == "IMaterial" ) then
				local w, h = 12, 12
				local material = v
				if ( type( v ) == "table" and v[ 2 ] and v[ 3 ] ) then
					material = v[ 1 ]
					w = v[ 2 ]
					h = v[ 3 ]
				end
				data = data .. "<img=" .. material:GetName( )..".png," .. w .. "x" .. h .. "> "
			else
				v = tostring( v )
				v = string.gsub( v, "&", "&amp;" )
				v = string.gsub( v, "<", "&lt;" )
				v = string.gsub( v, ">", "&gt;" )
				data = data .. v
			end
		end

		if ( self.font ) then data = data .. "</font>" end

		self.markup = catherine.markup.Parse( data, self.maxWidth )

		function self.markup:DrawText( text, font, x, y, color, hAlign, vAlign, alpha )
			draw.SimpleTextOutlined( text, font, x, y, color, hAlign, vAlign, 1, Color( 0, 0, 0, 255 ) )
		end

		self:SetSize( self.markup:GetWidth( ), self.markup:GetHeight( ) )
	end

	function PANEL:Paint( w, h )
		if ( !self.markup ) then return end
		local alpha = 255
		if ( self.start and self.finish ) then alpha = math.Clamp( 255 - math.TimeFraction( self.start, self.finish, CurTime( ) ) * 255, 0, 255 ) end
		if ( catherine.chat.isOpened ) then alpha = 255 end
		self:SetAlpha( alpha )
		if ( alpha > 0 ) then
			self.markup:Draw( 1, 0, 0, 0 )
		end
	end
	vgui.Register( "catherine.vgui.ChatMarkUp", PANEL, "DPanel" )
	
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
		catherine.chat.CreateBase( )
		catherine.chat.isOpened = bool
		
		local self = catherine.chat.chatpanel
		
		local initHistoryKey = #catherine.chat.history + 1
		local onEnterFunc = function( pnl )
			local text = pnl:GetText( )
			if ( text != "" ) then
				netstream.Start( "catherine.chat.Run", text:sub( 1 ) )
				catherine.chat.history[ #catherine.chat.history + 1 ] = text:sub( 1 )
				if ( #catherine.chat.history > 10 ) then
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
				end
			elseif ( code == KEY_DOWN ) then
				if ( initHistoryKey < #catherine.chat.history ) then
					initHistoryKey = initHistoryKey + 1
					pnl:SetText( catherine.chat.history[ initHistoryKey ] )
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