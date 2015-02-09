
local META = FindMetaTable( "Entity" )

if ( SERVER ) then
	local function sendDelayRegister( pl, ent, key )
		if ( !IsValid( pl ) or !IsValid( ent ) ) then return end
		local timerID = "catherine.network.timer_" .. pl:SteamID( ) .. ":" .. ent:EntIndex( ) .. ":" .. key
		timer.Create( timerID, math.max( pl:Ping( ) / 75, 0.75 ), 10, function( )
			if ( !IsValid( pl ) or !IsValid( ent ) ) then
				timer.Destroy( timerID )
				return
			end
			ent:SendNetworkValues( key, pl )
		end )
	end
	
	function META:SyncNetworkValues( pl )
		if ( !self.catherine_networkValues ) then return end
		for k, v in pairs( self.catherine_networkValues ) do
			self:SendNetworkValues( k, pl )
		end
	end

	function META:SendNetworkValues( key, target )
		local value = self.catherine_networkValues[ key ]
		if ( value and value == nil ) then
			netstream.Start( nil, "catherine.network.NilEntityValues", {
				self:EntIndex( ),
				key
			} )
		else
			if ( target ) then
				netstream.Start( target, "catherine.network.ReceiveEntityValues", {
					self:EntIndex( ),
					key,
					value
				} )
				sendDelayRegister( target, self, key )
			else
				netstream.Start( nil, "catherine.network.ReceiveEntityValues", {
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
		self.catherine_networkValues = self.catherine_networkValues or { }
		self.catherine_networkValues[ key ] = value
	
		self:CallOnRemove( "ClearNetworkValues", function( )
			netstream.Start( nil, "catherine.network.NilEntityValues", {
				self:EntIndex( ),
				key
			} )
		end )
		self:SendNetworkValues( key, target )
	end
	
	hook.Add( "PlayerAuthed", "catherine.network.PlayerAuthed", function( pl )
		timer.Simple( 5, function( )
			for k, v in pairs( ents.GetAll( ) ) do
				if ( !IsValid( v ) ) then continue end
				v:SyncNetworkValues( pl )
			end
		end )
	end )
	
	netstream.Hook( "catherine.network.DelayRemove", function( pl, data )
		timer.Destroy( "catherine.network.timer_" .. pl:SteamID( ) .. data )
	end )
else
	catherine.network = catherine.network or { }
	catherine.network.LocalNetworkValues = catherine.network.LocalNetworkValues or { }
	
	netstream.Hook( "catherine.network.ReceiveEntityValues", function( data )
		local index = data[ 1 ]
		local key = data[ 2 ]
		local value = data[ 3 ]
		catherine.network.LocalNetworkValues[ index ] = catherine.network.LocalNetworkValues[ index ] or { }
		catherine.network.LocalNetworkValues[ index ][ key ] = value
		netstream.Start("catherine.network.DelayRemove", ":" .. index .. ":" .. key )
	end )
	
	netstream.Hook( "catherine.network.NilEntityValues", function( data )
		local index = data[ 1 ]
		local key = data[ 2 ]
		catherine.network.LocalNetworkValues[ index ][ key ] = nil
	end )
end

function META:GetNetworkValue( key, default )
	if ( SERVER and self.catherine_networkValues ) then
		if ( self.catherine_networkValues[ key ] != nil ) then
			return self.catherine_networkValues[ key ]
		else
			return default
		end
	elseif ( CLIENT and catherine.network.LocalNetworkValues[ self:EntIndex( ) ] ) then
		if ( catherine.network.LocalNetworkValues[ self:EntIndex( ) ][ key ] != nil ) then
			return catherine.network.LocalNetworkValues[ self:EntIndex( ) ][ key ]
		else
			return default
		end
	end
	
	return default
end