--[[

--]]
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
	canHearRange = 300
} )

catherine.chat.RegisterClass( {
	class = "me",
	doChat = function( pl, text )
		chat.AddText( Color( 255, 150, 255 ), "** " .. pl:Name( ) .. " " .. text )
	end,
	global = true,
	command = { "/me", "/ME" }
} )

catherine.chat.RegisterClass( {
	class = "yell",
	doChat = function( pl, text )
		local name = hook.Run( "GetTargetInformation", LocalPlayer( ), pl )
		local nameText = name[ 1 ] == "Unknown..." and name[ 2 ] or name[ 1 ]
		chat.AddText( Color( 255, 255, 255 ), nameText .. " 님의 외침 : " .. text )
	end,
	canHearRange = 600,
	command = { "/y", "/yell" }
} )

catherine.chat.RegisterClass( {
	class = "whisper",
	doChat = function( pl, text )
		local name = hook.Run( "GetTargetInformation", LocalPlayer( ), pl )
		local nameText = name[ 1 ] == "Unknown..." and name[ 2 ] or name[ 1 ]
		chat.AddText( Color( 255, 255, 255 ), nameText .. " 님의 속삭임 : " .. text )
	end,
	canHearRange = 150,
	command = { "/w", "/whisper" }
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
	}
} )

catherine.chat.RegisterClass( {
	class = "looc",
	doChat = function( pl, text )
		chat.AddText( Color( 250, 255, 40 ), "[LOOC] ", pl, color_white, " : ".. text )
	end,
	canHearRange = 600,
	command = {
		"/looc", ".//", "[["
	}
} )

if ( SERVER ) then
	netstream.Hook( "catherine.chat.Run", function( pl, data )
		hook.Run( "PlayerSay", pl, data, true )
	end )
	
	function catherine.chat.Send( pl, class, text, target )
		target = target or { pl }
		local classTab = catherine.chat.FindByClass( class )
		if ( !classTab ) then return end
		if ( classTab.global ) then
			for k, v in pairs( player.GetAll( ) ) do
				if ( !v:IsCharacterLoaded( ) ) then continue end
				netstream.Start( v, "catherine.chat.Receive", { pl, class, text } )
			end
		else
			local target = catherine.chat.GetTarget( pl, class )
			for k, v in pairs( target ) do
				netstream.Start( v, "catherine.chat.Receive", { pl, class, text } )
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

		for k, v in pairs( classTab.command or { } ) do
			local textLower = text:lower( )
			if ( string.Left( textLower, #v ) == v ) then
				text = string.Replace( text, v, "" )
			end
		end
		
		catherine.chat.Send( pl, class, text )
		catherine.command.DoByText( pl, text )
		// insert something ... ;0
	end
else
	catherine.chat.backpanel = catherine.chat.backpanel or nil
	catherine.chat.chatpanel = catherine.chat.chatpanel or nil
	catherine.chat.isOpened = catherine.chat.isOpened or false
	catherine.chat.msg = catherine.chat.msg or { }
	
	netstream.Hook( "catherine.chat.Receive", function( data )
		local speaker, class, text = data[ 1 ], data[ 2 ], data[ 3 ]
		local class = catherine.chat.FindByClass( class )
		class.doChat( speaker, text )
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
		msg:SetFont( "catherine_font01_17" )
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
		
		self = vgui.Create( "EditablePanel", self )
		self:SetPos( CHATBox_x, CHATBox_y + CHATBox_h - 25 )
		self:SetSize( CHATBox_w, 25 )
		self.Paint = function( ) end
		
		self.textEnt = vgui.Create( "DTextEntry", self )
		self.textEnt:Dock( FILL )
		self.textEnt.OnEnter = function( pnl )
			local text = pnl:GetText( )
			if ( text != "" ) then
				netstream.Start( "catherine.chat.Run", text:sub( 1 ) )
			end
			catherine.chat.isOpened = false
			
			self:Remove( )
			self = nil
			hook.Run( "FinishChat" )
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

		self:MakePopup( )
		self.textEnt:RequestFocus( )
		hook.Run( "StartChat" )
	end
	
	do
		catherine.chat.CreateBase( )
	end
end

hook.Remove( "PlayerSay", "ULXMeCheck" )