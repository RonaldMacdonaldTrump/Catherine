
nexus.character = nexus.character or { }
nexus.character.buffer = nexus.character.buffer or { }
nexus.character.valueTypes = nexus.character.valueTypes or { }

local META = { }
META.__index = META

NEXUS_CHARACTER_PUBLIC = 0
NEXUS_CHARACTER_PRIVAITE = 1


function META:NewValues( key, value, status )
	local types = type( value )
	if ( status == NEXUS_CHARACTER_PUBLIC ) then
		self.publicValues[ key ] = { value, types }
	else
		self.privaiteValues[ key ] = { value, types }
	end
end

function META:SetValues( key, value, status )
	local types = type( value )
	local receivers = nil
	if ( self.publicValues[ key ] ) then
		self.publicValues[ key ] = { value, types }
		if ( SERVER ) then
			self:SendValues( key, receivers )
		end
	else
		self.privaiteValues[ key ] = { value, types }
		if ( SERVER ) then
			receivers = self.Player
			self:SendValues( key, receivers )
		end
	end
end

function META:SendValues( key, receivers )
	local publcValues = self.publicValues[ key ]
	local privaiteValues = self.privaiteValues[ key ]
	local pl = self.Player
	if ( !key ) then
		for k, v in pairs( self.publicValues ) do
			self:SendValues( k, receivers )
		end
		if ( !receivers or receivers == pl ) then
			for k, v in pairs( self.privaiteValues ) do
				self:SendValues( k, pl )
			end
		end
	elseif ( publcValues != nil ) then
		netstream.Start( receivers, "nexus.network.SendCharacterData", { pl:EntIndex( ), key, publcValues } )
	elseif ( privaiteValues != nil ) then
		netstream.Start( pl, "nexus.network.SendLocalCharacterData", { key, privaiteValues } )
	end
end

function META:GetValues( key, default )
	if ( self.publicValues and self.publicValues[ key ][ 1 ] ) then
		return self.publicValues[ key ][ 1 ]
	elseif ( self.privaiteValues and self.privaiteValues[ key ][ 1 ] ) then
		return self.privaiteValues[ key ][ 1 ]
	end
	return default
end


if ( CLIENT ) then


end