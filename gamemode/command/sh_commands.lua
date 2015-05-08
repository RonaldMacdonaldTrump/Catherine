--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

catherine.command.Register( {
	command = "fallover",
	canRun = function( pl ) return pl:Alive( ) end,
	runFunc = function( pl, args )
		if ( catherine.player.IsRagdolled( pl ) ) then
			catherine.util.Notify( pl, "You are already fallovered!" )
			return
		end
		
		if ( args[ 1 ] ) then
			args[ 1 ] = tonumber( args[ 1 ] )
		end
		
		catherine.player.RagdollWork( pl, !catherine.player.IsRagdolled( pl ), args[ 1 ] )
	end
} )

catherine.command.Register( {
	command = "chargetup",
	canRun = function( pl ) return pl:Alive( ) end,
	runFunc = function( pl, args )
		if ( !pl.CAT_gettingup ) then
			if ( catherine.player.IsRagdolled( pl ) ) then
				pl.CAT_gettingup = true
				catherine.util.TopNotify( pl, false )
				catherine.util.ProgressBar( pl, "You are now getting up ...", 3, function( )
					catherine.player.RagdollWork( pl, false )
					pl.CAT_gettingup = nil
				end )
			else
				catherine.util.Notify( pl, "You are not fallovered!" )
			end
		else
			catherine.util.Notify( pl, "You are already getting uping!" )
		end
	end
} )

catherine.command.Register( {
	command = "charsetname",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local nameBuffer = target:Name( )
					
					catherine.character.SetVar( target, "_name", args[ 2 ] )
					catherine.util.NotifyAllLang( "Character_Notify_SetName", pl:Name( ), args[ 2 ], nameBuffer )
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "charsetdesc",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					catherine.character.SetVar( target, "_desc", args[ 2 ] )
					catherine.util.NotifyAllLang( "Character_Notify_SetDesc", pl:Name( ), args[ 2 ], target:Name( ) )
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "charsetmodel",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					catherine.character.SetVar( target, "_model", args[ 2 ] )
					catherine.util.NotifyAllLang( "Character_Notify_SetModel", pl:Name( ), args[ 2 ], target:Name( ) )
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "charphysdesc",
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local newDesc = args[ 1 ]
			
			if ( newDesc:len( ) >= catherine.configs.characterDescMinLen and newDesc:len( ) < catherine.configs.characterDescMaxLen ) then
				catherine.character.SetVar( pl, "_desc", newDesc )
				catherine.util.NotifyLang( pl, "Character_Notify_SetDescLC", newDesc )
			else
				catherine.util.NotifyLang( pl, "Character_Notify_DescLimitHit" )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "doorlock",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local ent = pl:GetEyeTraceNoCursor( ).Entity
		
		if ( IsValid( ent ) and catherine.entity.IsDoor( ent ) ) then
			ent:Fire( "Lock" )
			ent:EmitSound( "doors/door_latch3.wav" )
			catherine.util.NotifyLang( pl, "Door_Notify_CMD_Locked" )
		else
			catherine.util.NotifyLang( pl, "Entity_Notify_NotDoor" )
		end
	end
} )

catherine.command.Register( {
	command = "doorunlock",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local ent = pl:GetEyeTraceNoCursor( ).Entity
		
		if ( IsValid( ent ) and catherine.entity.IsDoor( ent ) ) then
			ent:Fire( "Unlock" )
			ent:EmitSound( "doors/door_latch3.wav" )
			catherine.util.NotifyLang( pl, "Door_Notify_CMD_UnLocked" )
		else
			catherine.util.NotifyLang( pl, "Entity_Notify_NotDoor" )
		end
	end
} )

catherine.command.Register( {
	command = "flaggive",
	syntax = "[name] [flag name]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, langKey, par = catherine.flag.Give( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Flag_Notify_Give", pl:Name( ), args[ 2 ], target:Name( ) )
					else
						catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "flagtake",
	syntax = "[name] [flag name]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, langKey, par = catherine.flag.Take( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Flag_Notify_Take", pl:Name( ), args[ 2 ], target:Name( ) )
					else
						catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "itemspawn",
	syntax = "[Item ID]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local success = catherine.item.Spawn( args[ 1 ], catherine.util.GetItemDropPos( pl ) )
			
			if ( !success ) then
				catherine.util.NotifyLang( pl, "Item_Notify_NoItemData" )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "charsetcash",
	syntax = "[name] [amount]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success = catherine.cash.Set( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Cash_Notify_Set", pl:Name( ), catherine.cash.GetName( args[ 2 ] ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "chargivecash",
	syntax = "[name] [amount]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success = catherine.cash.Give( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Cash_Notify_Give", pl:Name( ), catherine.cash.GetName( args[ 2 ] ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "chartakecash",
	syntax = "[name] [amount]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success = catherine.cash.Take( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Cash_Notify_Take", pl:Name( ), catherine.cash.GetName( args[ 2 ] ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "doorbuy",
	runFunc = function( pl, args )
		local success, langKey, par = catherine.door.Buy( pl, pl:GetEyeTrace( 70 ).Entity )
		
		if ( success ) then
			catherine.util.NotifyLang( pl, "Door_Notify_Buy" )
		else
			catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
		end
	end
} )

catherine.command.Register( {
	command = "doorsell",
	runFunc = function( pl, args )
		local success, langKey, par = catherine.door.Sell( pl, pl:GetEyeTrace( 70 ).Entity )
		
		if ( success ) then
			catherine.util.NotifyLang( pl, "Door_Notify_Sell" )
		else
			catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
		end
	end
} )

catherine.command.Register( {
	command = "doorsettitle",
	syntax = "[Text]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local success, langKey, par = catherine.door.SetDoorTitle( pl, pl:GetEyeTrace( 70 ).Entity, args[ 1 ], true )
			
			if ( success ) then
				catherine.util.NotifyLang( pl, "Door_Notify_SetTitle" )
			else
				catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "doorsetstatus",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local success, langKey, par = catherine.door.SetDoorStatus( pl, pl.GetEyeTrace( pl, 70 ).Entity )
		
		catherine.util.NotifyLang( pl, langKey )
	end
} )

catherine.command.Register( {
	command = "doorsetactive",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local success, langKey, par = catherine.door.SetDoorActive( pl, pl.GetEyeTrace( pl, 70 ).Entity )
		
		catherine.util.NotifyLang( pl, langKey )
	end
} )

catherine.command.Register( {
	command = "plygivewhitelist",
	syntax = "[Name] [Faction Name]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target.IsPlayer( target ) ) then
					local success, langKey, par = catherine.faction.AddWhiteList( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Faction_Notify_Give", pl:Name( ), args[ 2 ], target:Name( ) )
					else
						catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "plytakewhitelist",
	syntax = "[Name] [Faction Name]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target.IsPlayer( target ) ) then
					local success, langKey, par = catherine.faction.RemoveWhiteList( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Faction_Notify_Take", pl:Name( ), args[ 2 ], target:Name( ) )
					else
						catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "pm",
	syntax = "[name] [text]",
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target.IsPlayer( target ) ) then
					catherine.chat.Send( pl, "pm", args[ 2 ], { pl, target }, target )
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "roll",
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			args[ 1 ] = tonumber( args[ 1 ] )
		end
		
		catherine.chat.Send( pl, "roll", math.random( 1, args[ 1 ] or 100 ) )
	end
} )

catherine.command.Register( {
	command = "cleardecals",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		for k, v in pairs( player.GetAll( ) ) do
			v:ConCommand( "r_cleardecals" )
		end
		
		catherine.util.NotifyLang( pl, "Command_ClearDecals_Fin" )
	end
} )

catherine.command.Register( {
	command = "settimehour",
	canRun = function( pl ) return pl.IsSuperAdmin( pl ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			args[ 1 ] = tonumber( args[ 1 ] )
			
			catherine.environment.buffer.hour = args[ 1 ] and math.Clamp( args[ 1 ], 1, 24 ) or catherine.environment.buffer.hour
			catherine.environment.SyncToAll( )
			catherine.environment.AutomaticDayNight( )
			
			catherine.util.NotifyLang( pl, "Command_SetTimeHour_Fin", args[ 1 ] )
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )