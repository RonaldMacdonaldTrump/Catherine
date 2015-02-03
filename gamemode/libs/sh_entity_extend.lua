
local Nexus_Ent = FindMetaTable( "Entity" )
if !Nexus_Ent then return end



function Nexus_Ent:EmitSoundEx( sndfile, single, delay )
	timer.Simple( delay or 0, function( )
		self:EmitSound( sndfile, 100, 100, 1, single or 0 )
	end )
end