function catherine.RegisterMenuItem( text, vgui, desc )
	catherine.menuList[ text ] = { text = text, vgui = vgui, desc = desc }
end

local PANEL = { }

function PANEL:Init( )
	self.w = ScrW( )
	self.h = ScrH( )

	self.blurAmount = 0
	self.currMenu = nil
	self.lastSelect = nil
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	
	self.CloseMenu = vgui.Create( "catherine.vgui.button", self )
	self.CloseMenu:SetSize( self.w * 0.15, 30 )
	self.CloseMenu:SetPos( 15, 15 )
	self.CloseMenu:SetOutlineColor( Color( 0, 0, 0, 255 ) )
	self.CloseMenu:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.CloseMenu:SetStr( "Close Menu" )
	self.CloseMenu.Click = function( ) self:Close( ) end
	
	self.Character = vgui.Create( "catherine.vgui.button", self )
	self.Character:SetSize( self.w * 0.15, 30 )
	self.Character:SetPos( 15, 50 )
	self.Character:SetOutlineColor( Color( 0, 0, 0, 255 ) )
	self.Character:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.Character:SetStr( "Character" )
	self.Character.Click = function( )
		if ( IsValid( catherine.vgui.character ) ) then
			catherine.vgui.character:Close( )
			catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
		else
			catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
		end
		self:Close( )
	end

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 5, self.h - 45 )
	self.Lists:SetSize( self.w - 10, 40 )
	self.Lists:SetSpacing( 3 )
	self.Lists:EnableHorizontal( true )
	self.Lists:EnableVerticalScrollbar( false )	
	self.Lists.Paint = function( pnl, w, h ) end
	
	self.CharcreateModelPreview = vgui.Create( "DModelPanel", self )
	self.CharcreateModelPreview:SetSize( self.w * 0.15 + 10, self.h * 0.55 )
	self.CharcreateModelPreview:SetPos( 10, self.h * 0.2 )
	self.CharcreateModelPreview.OnCursorEntered = function() 
	end
	self.CharcreateModelPreview.OnCursorExited = function() 
	end
	self.CharcreateModelPreview:SetDisabled( true )
	self.CharcreateModelPreview:SetCursor( "none" )
	self.CharcreateModelPreview:MoveToBack( )
	self.CharcreateModelPreview:SetModel( LocalPlayer( ):GetModel( ) )
	self.CharcreateModelPreview:SetVisible( true )
	self.CharcreateModelPreview:SetFOV( 40 )
	self.CharcreateModelPreview.LayoutEntity = function( pnl, entity )
		entity:SetAngles( Angle( 0, 45, 0 ) )
		self.CharcreateModelPreview:RunAnimation( )
	end
	self.CharcreateModelPreview.PaintOver = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 255, 255, 255 ) )
	end

	hook.Run( "AddMenu" )
	
	self:MenuInit( )
end

function PANEL:Paint( w, h )
	self.blurAmount = Lerp( 0.03, self.blurAmount, 5 )
	
	catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
	
	draw.RoundedBox( 0, 0, h - 50, w, 50, Color( 235, 235, 235, 235 ) )
	draw.RoundedBox( 0, 10, 10, w * 0.15 + 10, 75, Color( 235, 235, 235, 235 ) )
	draw.RoundedBox( 0, 10, h * 0.8 - 30, 10 + ( w * 0.15 ), 65, Color( 235, 235, 235, 235 ) )
	
	draw.SimpleText( LocalPlayer( ):Name( ), "catherine_font01_25", 10 + ( w * 0.15 ) / 2, h * 0.8, Color( 50, 50, 50, 255 ), 1, 1 )
	draw.SimpleText( catherine.cash.GetName( LocalPlayer( ):GetCash( ) ), "catherine_font01_25", ScrW( ) - 15, 15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
end

function PANEL:MenuInit( )
	self.Lists:Clear( )
	for k, v in pairs( catherine.menuList ) do
		local panel = vgui.Create( "catherine.vgui.button", self )
		panel:SetSize( 100, self.Lists:GetTall( ) )
		panel:SetOutlineColor( Color( 0, 0, 0, 255 ) )
		panel:SetStr( v.text )
		panel:SetTextColor( Color( 0, 0, 0, 255 ) )
		panel:SetToolTip( v.desc )
		panel.Click = function( )
			local function createMenu( )
				self.currMenu = vgui.Create( v.vgui, self )
				self.currMenu:SetPos( self.currMenu.x, ScrH( ) )
				self.currMenu:MoveTo( self.currMenu.x, self.h / 2 - self.currMenu.h / 2, 0.3, 0 )
				self.lastSelect = k
			end
			
			if ( self.lastSelect and ( self.lastSelect == k ) ) then
				if ( IsValid( self.currMenu ) ) then
					self.currMenu:MoveTo( self.currMenu.x, ScrH( ), 0.3, 0, nil, function( )
						if ( IsValid( self.currMenu ) ) then
							self.currMenu:Remove( )
							self.currMenu = nil
							self.lastSelect = k
						end
					end )
				else
					createMenu( )
				end
			else
				if ( self.currMenu ) then
					self.currMenu:MoveTo( self.currMenu.x, ScrH( ), 0.3, 0, nil, function( )
						if ( IsValid( self.currMenu ) ) then
							self.currMenu:Remove( )
							self.currMenu = nil
							createMenu( )
						end
					end )
				else
					createMenu( )
				end
			end
		end
		self.Lists:AddItem( panel )
	end
end

function PANEL:Close( )
	self:Remove( )
	self = nil
	catherine.vgui.menu = nil
	gui.EnableScreenClicker( false )
end

vgui.Register( "catherine.vgui.menu", PANEL, "DFrame" )