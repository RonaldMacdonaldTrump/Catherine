local Plugin = Plugin

netstream.Hook( "catherine.plugin.bugreport.SendResult", function( data )
	if ( type( data ) == "boolean" ) then
		if ( IsValid( catherine.vgui.bugreport ) ) then
			catherine.vgui.bugreport:SetNotify( true, "Your report has been sent, thank you! :)" )
		end
	else
		if ( IsValid( catherine.vgui.bugreport ) ) then
			catherine.vgui.bugreport:SetNotify( false, data, false, true )
		end
	end
end )