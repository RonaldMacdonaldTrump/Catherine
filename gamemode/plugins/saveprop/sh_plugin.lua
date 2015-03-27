local PLUGIN = PLUGIN
PLUGIN.name = "Save Prop"
PLUGIN.author = "L7D"
PLUGIN.desc = "Good stuff."

if ( SERVER ) then
	function PLUGIN:DataSave( )
		local data = { }
		for k, v in pairs( ents.GetAll( ) ) do
			if ( !v:GetNetVar( "isPersistent" ) ) then continue end
			data[ #data + 1 ] = v
		end
		
		if ( #data == 0 ) then return end
		local persistentData = duplicator.CopyEnts( data )
		if ( !persistentData ) then return end
		catherine.data.Set( "props", persistentData )
	end
	
	function PLUGIN:DataLoad( )
		local data = catherine.data.Get( "props", nil )
		if ( !data ) then return end
		
		local ents, consts = duplicator.Paste( nil, data.Entities or { }, data.Contraints or { } )
		
		for k, v in pairs( ents ) do
			v:SetNetVar( "isPersistent", true )
		end
	end
end

catherine.command.Register( {
	command = "staticprop",
	syntax = "",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		local tr = pl:GetEyeTraceNoCursor( )
		local ent = tr.Entity
		
		if ( IsValid( ent ) ) then
			if ( ent:GetClass( ):find( "prop_" ) and !ent:IsDoor( ) ) then
				ent:SetNetVar( "isPersistent", !ent:GetNetVar( "isPersistent", false ) )
				
				if ( ent:GetNetVar( "isPersistent" ) ) then
					catherine.util.Notify( pl, "You has add this entity in static props." )
				else
					catherine.util.Notify( pl, "You has remove this entity in static props." )
				end
				
				PLUGIN:DataSave( )
			else
				catherine.util.Notify( pl, "You can't work this for this entity!" )
			end
		else
			catherine.util.Notify( pl, "This is not a prop!" )
		end
	end
} )