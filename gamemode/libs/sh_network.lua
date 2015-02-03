
local META = FindMetaTable( "Entity" )

if ( SERVER ) then
	local function sendDelayRegister( pl, ent, key )
		if ( !IsValid( pl ) or !IsValid( ent ) ) then return end
		local timerID = "nexus.network.timer_" .. pl:SteamID( ) .. ":" .. ent:EntIndex( ) .. ":" .. key
		timer.Create( timerID, math.max( pl:Ping( ) / 75, 0.75 ), 10, function( )
			if ( !IsValid( pl ) or !IsValid( ent ) ) then
				timer.Destroy( timerID )
				return
			end
			ent:SendNetworkValues( key, pl )
		end )
	end
	
	function META:SyncNetworkValues( pl )
		if ( !self.nexus_networkValues ) then return end
		for k, v in pairs( self.nexus_networkValues ) do
			self:SendNetworkValues( k, pl )
		end
	end

	function META:SendNetworkValues( key, target )
		local value = self.nexus_networkValues[ key ]
		if ( value and value == nil ) then
			netstream.Start( nil, "nexus.network.NilEntityValues", {
				self:EntIndex( ),
				key
			} )
		else
			if ( target ) then
				netstream.Start( target, "nexus.network.ReceiveEntityValues", {
					self:EntIndex( ),
					key,
					value
				} )
				sendDelayRegister( target, self, key )
			else
				netstream.Start( nil, "nexus.network.ReceiveEntityValues", {
					self:EntIndex( ),
					key,
					value
				} )
				for k, v in pairs( player.GetAll( ) ) do
					sendDelayRegister( v, self, key )
				end
			end
		end
	end
	
	// SetNetworkValue
	function META:SetNetworkValue( key, value, target )
		self.nexus_networkValues = self.nexus_networkValues or { }
		self.nexus_networkValues[ key ] = value
	
		self:CallOnRemove( "ClearNetworkValues", function( )
			netstream.Start( nil, "nexus.network.NilEntityValues", {
				self:EntIndex( ),
				key
			} )
		end )
		self:SendNetworkValues( key, target )
	end
	
	hook.Add( "PlayerAuthed", "nexus.network.PlayerAuthed", function( pl )
		timer.Simple( 5, function( )
			for k, v in pairs( ents.GetAll( ) ) do
				if ( !IsValid( v ) ) then continue end
				v:SyncNetworkValues( pl )
			end
		end )
	end )
	
	netstream.Hook( "nexus.network.DelayRemove", function( pl, data )
		timer.Destroy( "nexus.network.timer_" .. pl:SteamID( ) .. data )
	end )
else
	nexus.network = nexus.network or { }
	nexus.network.LocalNetworkValues = nexus.network.LocalNetworkValues or { }
	
	netstream.Hook( "nexus.network.ReceiveEntityValues", function( data )
		local index = data[ 1 ]
		local key = data[ 2 ]
		local value = data[ 3 ]
		nexus.network.LocalNetworkValues[ index ] = nexus.network.LocalNetworkValues[ index ] or { }
		nexus.network.LocalNetworkValues[ index ][ key ] = value
		netstream.Start("nexus.network.DelayRemove", ":" .. index .. ":" .. key )
	end )
	
	netstream.Hook( "nexus.network.NilEntityValues", function( data )
		local index = data[ 1 ]
		local key = data[ 2 ]
		nexus.network.LocalNetworkValues[ index ][ key ] = nil
	end )
end

function META:GetNetworkValue( key, default )
	if ( SERVER and self.nexus_networkValues ) then
		if ( self.nexus_networkValues[ key ] != nil ) then
			return self.nexus_networkValues[ key ]
		else
			return default
		end
	elseif ( CLIENT and nexus.network.LocalNetworkValues[ self:EntIndex( ) ] ) then
		if ( nexus.network.LocalNetworkValues[ self:EntIndex( ) ][ key ] != nil ) then
			return nexus.network.LocalNetworkValues[ self:EntIndex( ) ][ key ]
		else
			return default
		end
	end
	
	return default
end