
local catherine_Ent = FindMetaTable( "Entity" )
if !catherine_Ent then return end



function catherine_Ent:EmitSoundEx( sndfile, single, delay )
	timer.Simple( delay or 0, function( )
		self:EmitSound( sndfile, 100, 100, 1, single or 0 )
	end )
end