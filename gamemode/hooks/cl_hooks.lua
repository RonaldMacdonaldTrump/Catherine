
catherine.loading = catherine.loading or false
catherine.errorText = catherine.errorText or ""
catherine.alpha = catherine.alpha or 255
catherine.color = catherine.color or 0
catherine.textColor = catherine.textColor or 255
catherine.loadingStarting = catherine.loadingStarting or false
catherine.progressBar = catherine.progressBar or 0
catherine.percent = catherine.percent or 0
catherine.menuList = catherine.menuList or { }
catherine.locationRandom = catherine.locationRandom or table.Random( catherine.configs.locationRandom )


for i = 15, 64 do
	surface.CreateFont( "catherine_font01_" .. i, { font = "Segoe UI", size = i, weight = 1000, antialias = true } )
	surface.CreateFont( "catherine_font02_" .. i, { font = "Segoe UI", size = i, weight = 1000, antialias = true, outline = true } )
end

function GM:HUDShouldDraw( element )
	if ( element == "CHudHealth" or element == "CHudBattery" or element == "CHudAmmo" or element == "CHudSecondaryAmmo" ) then
		return false
	end
	
	if ( element == "CHudCrosshair" ) then
		return false
	end

	return true
end

function GM:CalcView( pl, pos, ang, fov )
	if ( IsValid( catherine.vgui.character ) ) then
		local sin = math.sin( CurTime( ) / 4 )
		local sin2 = math.sin( CurTime( ) / 5 )
		viewSin = ( 10 / 1 ) * sin
		viewSin2 = ( 10 / 1 ) * sin2
		local view = { }
		view.origin = catherine.locationRandom.pos
		view.angles = Angle( catherine.locationRandom.ang.p + ( viewSin / 2 ), catherine.locationRandom.ang.y + ( viewSin2 / 2 ), catherine.locationRandom.ang.r ) 
		view.fov = fov
		return view
	end
end

local nextRefresh = 0

local entity = nil
local entityIDCache = { }

function GM:HUDDrawTargetID( )
	
end

local toscreen = FindMetaTable("Vector").ToScreen

function GM:DrawEntityInformation( ent, alpha )
	if ( ent:IsPlayer( ) ) then
		local lp = LocalPlayer( )
		local position = toscreen(ent:EyePos())
		local x, y = position.x, position.y - 100
		local x2, y2 = 0, 0
		
		draw.SimpleText( ent:Name( ), "catherine_font02_25", x, y, Color( 255, 255, 255, alpha ), 1, 1 )
		
		y = y + 20
		
		draw.SimpleText( ent:Desc( ), "catherine_font02_15", x, y, Color( 255, 255, 255, alpha ), 1, 1 )
		
		y = y + 15
		
		hook.Run( "PlayerInformationDraw", x, y, alpha )
	end
end

function GM:HUDDrawScoreBoard( )
	local scrW, scrH = ScrW( ), ScrH( )
	if ( catherine.loading ) then
		if ( catherine.loadingStarting ) then
			catherine.alpha = Lerp( 0.01, catherine.alpha, 255 )
			catherine.color = Lerp( 0.01, catherine.color, 0 )
			catherine.textColor = Lerp( 0.01, catherine.textColor, 255 )
		else
			catherine.color = Lerp( 0.01, catherine.color, 255 )
			catherine.alpha = Lerp( 0.01, catherine.alpha, 255 )
			catherine.textColor = Lerp( 0.01, catherine.textColor, 50 )
		end
	else
		catherine.alpha = Lerp( 0.005, catherine.alpha, 0 )
	end
	
	catherine.progressBar = Lerp( 0.05, catherine.progressBar, ( scrW - 20 ) * catherine.percent )

	draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( catherine.color, catherine.color, catherine.color, catherine.alpha ) )
	
	surface.SetDrawColor( catherine.color - 55, catherine.color - 55, catherine.color - 55, catherine.alpha )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 0, 0, scrW, scrH )

	surface.SetDrawColor( catherine.textColor, catherine.textColor, catherine.textColor, catherine.alpha )
	surface.SetMaterial( Material( "catherine/logo.png" ) )
	surface.DrawTexturedRect( scrW / 2 - 512 / 2, scrH / 2 - 256 / 2, 512, 256 )
	
	//draw.RoundedBox( 0, 10, scrH - 20, scrW - 20, 10, Color( catherine.textColor * 2, catherine.textColor * 2, catherine.textColor * 2, catherine.alpha ) )
	//draw.RoundedBox( 0, 10, scrH - 20, catherine.progressBar, 10, Color( catherine.textColor, catherine.textColor, catherine.textColor, catherine.alpha ) )
	
	draw.SimpleText( catherine.errorText, "catherine_font01_40", scrW / 2, scrH - 70, Color( 255, 0, 0, catherine.alpha ), 1, 1 )
end

function GM:HUDPaint( )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.SetMaterial( Material( "catherine/vignette.png" ) )
	surface.DrawTexturedRect( 0, 0, ScrW( ), ScrH( ) )
	
	draw.SimpleText( catherine.cash.GetName( LocalPlayer( ):GetCash( ) ), "catherine_font01_25", ScrW( ) - 15, 15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
	catherine.bar.Draw( )
	
	local scrW, scrH = ScrW( ), ScrH( )
	if ( LocalPlayer( ):IsCharacterLoaded( ) and nextRefresh < CurTime( ) ) then
		nextRefresh = CurTime( ) + 0.5
		local ent = LocalPlayer( ):GetEyeTrace( 70 ).Entity
		if ( IsValid( ent ) ) then
			entityIDCache[ ent ] = true
		else
			entityIDCache[ ent ] = nil
		end
	end
	
	for k, v in pairs( entityIDCache ) do
		if ( !IsValid( k ) ) then entityIDCache[ k ] = nil continue end
		local distance = k:GetPos( ):Distance( LocalPlayer( ):GetPos( ) )
		local a = Lerp( 0.03, k.alpha or 0, 255 - ( distance ) )
		k.alpha = a

		if ( math.Round( a ) <= 0 ) then
			entityIDCache[ k ] = nil
		end
		
		hook.Run( "DrawEntityInformation", k, a )
	end
end

function GM:CalcViewModelView( weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAng )
	if ( !IsValid( weapon ) ) then return end
	local pl = LocalPlayer()
	local value = 0
	if ( !pl:GetWeaponRaised( ) ) then value = 100 end

	local fraction = ( pl.wepRaisedFraction or 0 ) / 100
	local lowerAngle = weapon.LowerAngles or Angle( 30, -30, -25 )
	
	eyeAng:RotateAroundAxis( eyeAng:Up( ), lowerAngle.p * fraction)
	eyeAng:RotateAroundAxis( eyeAng:Forward( ), lowerAngle.y * fraction)
	eyeAng:RotateAroundAxis( eyeAng:Right( ), lowerAngle.r * fraction)

	pl.wepRaisedFraction = Lerp( FrameTime( ) * 2, pl.wepRaisedFraction or 0, value )

	viewModel:SetAngles( eyeAng )
	return oldEyePos, eyeAng
end

function GM:AddMenu( )
	catherine.RegisterMenuItem( "Inventory", "catherine.vgui.inventory", "Open the your inventory." )
end

netstream.Hook( "catherine.LoadingStatus", function( data )
	if ( data[ 2 ] == true ) then
		if ( data[ 1 ] == true ) then
			catherine.loading = true
			catherine.loadingStarting = false
		elseif ( data[ 1 ] == false ) then
			catherine.loading = true
			catherine.loadingStarting = true
		end
	elseif ( data[ 2 ] == false ) then
		catherine.loading = true
		catherine.errorText = data[ 3 ] or ""
	end
	catherine.percent = data[ 4 ]
	if ( data[ 5 ] == true ) then
		catherine.loading = false
		catherine.loadingStarting = false
	end
end )