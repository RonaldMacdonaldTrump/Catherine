function GM:ScoreboardShow()
	if ( IsValid( catherine.vgui.menu ) ) then
		catherine.vgui.menu:Close( )
		gui.EnableScreenClicker( false )
	else
		catherine.vgui.menu = vgui.Create( "catherine.vgui.menu" )
		gui.EnableScreenClicker( true )
	end
end

function GM:ScoreboardHide()

end

function catherine.RegisterMenuItem( text, vgui, desc )
	catherine.menuList[ text ] = { text = text, vgui = vgui, desc = desc }
end

local PANEL = { }

function PANEL:Init( )
	local LP = LocalPlayer( )
	
	self.w = ScrW( )
	self.h = ScrH( )

	self.blurAmount = 0
	self.open = CurTime( )
	self.staying = false
	self.currMenu = nil
	self.lastSelect = nil
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	
	self.CloseMenu = vgui.Create( "catherine.vgui.button", self )
	self.CloseMenu:SetSize( self.w * 0.15, 30 )
	self.CloseMenu:SetPos( 15, 50 )
	self.CloseMenu:SetOutlineColor( Color( 255, 255, 255, 255 ) )
	self.CloseMenu:SetStr( "Close Menu" )
	self.CloseMenu.Click = function( )
		self:Close( )
	end
	
	self.Character = vgui.Create( "catherine.vgui.button", self )
	self.Character:SetSize( self.w * 0.15, 30 )
	self.Character:SetPos( 15, 90 )
	self.Character:SetOutlineColor( Color( 255, 255, 255, 255 ) )
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
	self.Lists:SetPos( 15, 150 )
	self.Lists:SetSize( self.w * 0.15, self.h - 50 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )	
	self.Lists.Paint = function( pnl, w, h )

	end
	
	hook.Run( "AddMenu" )
	
	self:MenuInit( )
end

function PANEL:Paint( w, h )
	self.blurAmount = Lerp( 0.03, self.blurAmount, 5 )
	
	catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
	
	surface.SetDrawColor( 40, 40, 40, 200 )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 10, 45, w * 0.15 + 10, h / 2 )
	
	draw.RoundedBox( 0, 10, 45, w * 0.15 + 10, h / 2, Color( 40, 40, 40, 150 ) )
end

function PANEL:Think( )
	if ( self.open <= CurTime( ) + 1 ) then
		self.staying = true
	end
end

function PANEL:MenuInit( )
	self.Lists:Clear( )
	for k, v in pairs( catherine.menuList ) do
		local panel = vgui.Create( "catherine.vgui.button", self )
		panel:SetSize( self.Lists:GetWide( ), 30 )
		panel:SetOutlineColor( Color( 255, 255, 255, 255 ) )
		panel:SetStr( v.text )
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