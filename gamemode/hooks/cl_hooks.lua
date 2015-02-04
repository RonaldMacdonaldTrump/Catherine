
function GM:HUDShouldDraw( name )
	if (name == "CHudHealth") or (name == "CHudDeathNotice") or (name == "CHudBattery") or (name == "CHudSuitPower") or (name == "CHudSecondaryAmmo") or (name == "CHudAmmo") or (name == "CHudWeapon") or (name == "CHudZoom") then
             return false
        end
end