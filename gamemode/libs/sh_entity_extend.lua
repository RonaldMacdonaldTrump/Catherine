
local Nexus_Ent = FindMetaTable( "Entity" )
if !Nexus_Ent then return end

function Nexus_Ent:IsDoor( )
	if !IsValid(self) then return false end
	
	local class = self:GetClass( )
	if class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating" or class == "prop_dynamic" then
		return true
	end
	
	return false
end

function Nexus_Ent:EmitSoundEx( sndfile, single, delay )
	timer.Simple( delay or 0, function( )
		self:EmitSound( sndfile, 100, 100, 1, single or 0 )
	end )
end