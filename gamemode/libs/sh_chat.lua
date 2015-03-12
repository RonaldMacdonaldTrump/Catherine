catherine.chat = catherine.chat or { }
catherine.chat.Classes = { }

function catherine.chat.RegisterClass( tab )
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

catherine.chat.RegisterClass( {
	class = "ic",
	doChat = function( pl, text )
		local name = hook.Run( "GetTargetInformation", LocalPlayer( ), pl )
		local nameText = name[ 1 ] == "Unknown..." and name[ 2 ] or name[ 1 ]
		chat.AddText( Color( 255, 255, 255 ), nameText .. " 님의 말 : " .. text )
	end,
	canHearRange = 300,
	canRun = function( pl )
		return pl:Alive( )
	end
} )

catherine.chat.RegisterClass( {
	class = "me",
	doChat = function( pl, text )
		chat.AddText( Color( 255, 150, 255 ), "** " .. pl:Name( ) .. " " .. text )
	end,
	command = { "/me" },
	canHearRange = 1500,
	canRun = function( pl )
		return pl:Alive( )
	end
} )

catherine.chat.RegisterClass( {
	class = "it",
	doChat = function( pl, text )
		chat.AddText( Color( 255, 150, 0 ), "*** " .. pl:Name( ) .. " " .. text )
	end,
	command = { "/it" },
	canHearRange = 1000,
	canRun = function( pl )
		return pl:Alive( )
	end
} )

catherine.chat.RegisterClass( {
	class = "pm",
	doChat = function( pl, text, ex )
		chat.AddText( Color( 255, 255, 0 ), pl:Name( ) .. " 님이 " .. ex[ 1 ]:Name( ) .. " 님에게 귓속말 : " .. text )
	end,
	canRun = function( pl )
		return pl:Alive( )
	end
} )

catherine.chat.RegisterClass( {
	class = "yell",
	doChat = function( pl, text )
		local name = hook.Run( "GetTargetInformation", LocalPlayer( ), pl )
		local nameText = name[ 1 ] == "Unknown..." and name[ 2 ] or name[ 1 ]
		chat.AddText( Color( 255, 255, 255 ), nameText .. " 님의 외침 : " .. text )
	end,
	canHearRange = 600,
	command = { "/y", "/yell" },
	canRun = function( pl )
		return pl:Alive( )
	end
} )

catherine.chat.RegisterClass( {
	class = "whisper",
	doChat = function( pl, text )
		local name = hook.Run( "GetTargetInformation", LocalPlayer( ), pl )
		local nameText = name[ 1 ] == "Unknown..." and name[ 2 ] or name[ 1 ]
		chat.AddText( Color( 255, 255, 255 ), nameText .. " 님의 속삭임 : " .. text )
	end,
	canHearRange = 150,
	command = { "/w", "/whisper" },
	canRun = function( pl )
		return pl:Alive( )
	end
} )

catherine.chat.RegisterClass( {
	class = "ooc",
	doChat = function( pl, text )
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

catherine.chat.RegisterClass( {
	class = "looc",
	doChat = function( pl, text )
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
				local player = catherine.util.FindPlayerByName( args[ 1 ] )
				if ( IsValid( player ) ) then
					catherine.chat.Send( pl, "pm", args[ 2 ], { pl, player }, player )
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
	
	function catherine.chat.Send( pl, class, text, target, ... )
		local targetB = { }
		if ( type( target ) == "table" ) then targetB = { pl, target } else targetB = pl end
		local classTab = catherine.chat.FindByClass( class )
		if ( !classTab ) then return end
		if ( type( targetB ) == "table" ) then
			for k, v in pairs( target ) do
				netstream.Start( v, "catherine.chat.Receive", { pl, class, text, { ... } } )
			end
		elseif ( type( targetB ) == "Player" ) then
			if ( classTab.global ) then
				for k, v in pairs( player.GetAll( ) ) do
					if ( !v:IsCharacterLoaded( ) ) then continue end
					netstream.Start( v, "catherine.chat.Receive", { pl, class, text, { ... } } )
				end
			else
				local targetEx = catherine.chat.GetTarget( pl, class )
				for k, v in pairs( targetEx ) do
					netstream.Start( v, "catherine.chat.Receive", { pl, class, text, { ... } } )
				end
			end
		end
	end
	
	function catherine.chat.GetTarget( pl, class )
		local class = catherine.chat.FindByClass( class )
		if ( !class or ( class and !class.canHearRange ) ) then return { pl } end
		
		local target = { pl }
		
		for k, v in pairs( player.GetAll( ) ) do
			if ( !v:IsCharacterLoaded( ) ) then continue end
			if ( pl == v ) then continue end
			if ( pl:GetPos( ):Distance( v:GetPos( ) ) <= class.canHearRange ) then
				target[ #target + 1 ] = v
			end
		end
		
		return target
	end
	
	function catherine.chat.Progress( pl, text )
		local class = catherine.chat.FetchClassByText( text )
		local classTab = catherine.chat.FindByClass( class )
		if ( !classTab ) then return end
		local commandT = classTab.command or { }
		if ( type( commandT ) == "table" and #commandT > 1 ) then
			table.sort( classTab.command, function( a, b )
				return #a > #b
			end )
		end
		
		local fix = ""
		local isFin = false
		local noSpace = classTab.noSpace
		if ( type( commandT ) == "table" ) then
			for k, v in ipairs( commandT ) do
				if ( text:sub( 1, #v + ( noSpace and 0 or 1 ) ) == v .. ( noSpace and "" or " " ) ) then
					isFin = true
					fix = v .. ( noSpace and "" or " " )
					break
				end
			end
		elseif ( type( commandT ) == "string" ) then
			isFin = text:sub( 1, #commandT + ( noSpace and 1 or 0 ) ) == commandT .. ( noSpace and "" or " " )
			fix = commandT .. ( noSpace and "" or " " )
		end

		if ( isFin ) then
			text = text:sub( #fix + 1 )
			if ( noSpace and text:sub( 1, 1 ):match( "%s" ) ) then
				text = text:sub( 2 )
			end
		end

		if ( classTab.canRun and ( classTab.canRun( pl ) == false ) ) then
			catherine.util.Notify( pl, "You can run this work now!" )
			return
		end
		
		local adjustInfo = {
			text = text,
			class = class
		}
		
		if ( catherine.command.IsCommand( adjustInfo.text ) ) then
			catherine.command.DoByText( pl, adjustInfo.text )
			return
		end
		local adjustTransfer = hook.Run( "ChatAdjust", pl, adjustInfo )
		catherine.chat.Send( pl, class, ( adjustTransfer and adjustTransfer.text ) or text )
		hook.Run( "PostChated", pl, adjustTransfer or adjustInfo )
	end
	
	function catherine.chat.RunByClass( pl, class, text, target )
		if ( !target ) then target = pl end
		local classTab = catherine.chat.FindByClass( class )
		if ( !classTab ) then return end
		
		local adjustInfo = {
			text = text,
			class = class
		}

		local adjustTransfer = hook.Run( "ChatAdjust", pl, adjustInfo ) or nil
		catherine.chat.Send( pl, class, adjustTransfer.text or text, target )
		hook.Run( "PostChated", pl, adjustTransfer or text )
	end
else
	catherine.chat.backpanel = catherine.chat.backpanel or nil
	catherine.chat.chatpanel = catherine.chat.chatpanel or nil
	catherine.chat.isOpened = catherine.chat.isOpened or false
	catherine.chat.msg = catherine.chat.msg or { }
	catherine.chat.history = catherine.chat.history or { }
	
	netstream.Hook( "catherine.chat.Receive", function( data )
		local speaker, class, text, ex = data[ 1 ], data[ 2 ], data[ 3 ], data[ 4 ]
		local class = catherine.chat.FindByClass( class )
		class.doChat( speaker, text, ex )
	end )
	
	local CHATBox_w, CHATBox_h = ScrW( ) * 0.3, ScrH( ) * 0.3
	local CHATBox_x, CHATBox_y = 5, ScrH( ) - CHATBox_h - 5
	
	local PANEL = {}
	
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
		local data = ""
		local latestColor = Color( 255, 255, 255 )

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
				local w, h = 16, 16
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
		surface.SetDrawColor( 50, 50, 50, alpha )
		surface.SetMaterial( Material( "gui/gradient" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
		
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
		msg:SetFont( "catherine_normal15" )
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

hook.Remove( "PlayerSay", "ULXMeCheck" ) // lol ulx me shit.