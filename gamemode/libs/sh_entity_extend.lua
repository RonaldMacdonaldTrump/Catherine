
local m_Entity = FindMetaTable( "Entity" )
if !m_Entity then return end

function m_Entity:IsDoor( )
	if !IsValid(self) then return false end
	
	local class = self:GetClass( )
	if class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating" or class == "prop_dynamic" then
		return true
	end
	
	return false
end

function m_Entity:BuyDoor( )

	local ent = ply:GetEyeTrace( 70 ).Entity

	if !ent:IsDoor( ) then return end

end

function m_Entity:EmitSoundEx( sndfile, single, delay )
	timer.Simple( delay or 0, function( )
		self:EmitSound( sndfile, 100, 100, 1, single or 0 )
	end )
end