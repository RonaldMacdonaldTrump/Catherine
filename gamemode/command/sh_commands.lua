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
	command = "charfallover",
	canRun = function( pl ) return pl:Alive( ) end,
	runFunc = function( pl, args )
		if ( pl:IsRagdolled( ) ) then
			catherine.util.NotifyLang( pl, "Player_Message_AlreadyFallovered" )
			return
		end
		
		if ( args[ 1 ] ) then
			args[ 1 ] = tonumber( args[ 1 ] )
		end
		
		catherine.player.RagdollWork( pl, !pl:IsRagdolled( ), args[ 1 ] )
	end
} )

catherine.command.Register( {
	command = "chargetup",
	canRun = function( pl ) return pl:Alive( ) end,
	runFunc = function( pl, args )
		if ( pl:GetNetVar( "isForceRagdolled" ) ) then
			return
		end
		
		if ( !pl:GetNetVar( "gettingup" ) ) then
			if ( pl:IsRagdolled( ) ) then
				pl:SetNetVar( "gettingup", true )
				
				catherine.util.TopNotify( pl, false )
				catherine.util.ProgressBar( pl, LANG( pl, "Player_Message_GettingUp" ), 3, function( )
					catherine.player.RagdollWork( pl, false )
					pl:SetNetVar( "gettingup", nil )
				end )
			else
				catherine.util.NotifyLang( pl, "Player_Message_NotFallovered" )
			end
		else
			catherine.util.NotifyLang( pl, "Player_Message_AlreayGettingUp" )
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
					local localBuffer = pl:Name( )
					local targetBuffer = target:Name( )
					
					catherine.character.SetVar( target, "_name", args[ 2 ] )
					catherine.util.NotifyAllLang( "Character_Notify_SetName", localBuffer, args[ 2 ], targetBuffer )
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
	command = "charban",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local target = catherine.util.FindPlayerByName( args[ 1 ] )
			
			if ( IsValid( target ) and target:IsPlayer( ) ) then
				local status = catherine.player.IsCharacterBanned( target )
				
				if ( status ) then
					catherine.player.SetCharacterBan( target, false, function( )
						target:Freeze( false )
						
						if ( target.CAT_charBanLatestPos ) then
							target:SetPos( target.CAT_charBanLatestPos )
						else
							target:KillSilent( )
						end
					end )
					
					catherine.util.NotifyAllLang( "Character_Notify_CharUnBan", pl:Name( ), target:Name( ) )
				else
					catherine.player.SetCharacterBan( target, true, function( )
						target.CAT_charBanLatestPos = target:GetPos( )
						
						target:SetPos( Vector( 0, 0, 10000 ) )
						target:Freeze( true )
					end )
					
					catherine.util.NotifyAllLang( "Character_Notify_CharBan", pl:Name( ), target:Name( ) )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
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
					catherine.util.NotifyLang( "Character_Notify_SetDesc", pl:Name( ), args[ 2 ], target:Name( ) )
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
			
			if ( newDesc:utf8len( ) >= catherine.configs.characterDescMinLen and newDesc:utf8len( ) < catherine.configs.characterDescMaxLen ) then
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
			ent:Fire( "UnLock" )
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
			args[ 1 ] = table.concat( args, " " )
			
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
	command = "doorsetdesc",
	syntax = "[Text]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			args[ 1 ] = table.concat( args, " " )
			
			local success, langKey, par = catherine.door.SetDoorDescription( pl, pl:GetEyeTrace( 70 ).Entity, args[ 1 ] )
			
			if ( success ) then
				catherine.util.NotifyLang( pl, "Door_Notify_SetDesc" )
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
		local success, langKey, par = catherine.door.SetDoorStatus( pl, pl:GetEyeTrace( 70 ).Entity )
		
		catherine.util.NotifyLang( pl, langKey )
	end
} )

catherine.command.Register( {
	command = "doorsetactive",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local success, langKey, par = catherine.door.SetDoorActive( pl, pl:GetEyeTrace( 70 ).Entity )
		
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
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
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
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
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
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
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
	command = "restartlevel",
	syntax = "[Time]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		local time = args[ 1 ] or 5

		catherine.util.NotifyAllLang( "Command_RestartLevel_Fin", time )
		
		timer.Simple( time, function( )
			RunConsoleCommand( "changelevel", game.GetMap( ) )
		end )
	end
} )

catherine.command.Register( {
	command = "changelevel",
	syntax = "[Map] [Time]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		local map = args[ 1 ]
		local time = args[ 2 ] or 5
		
		if ( file.Exists( "maps/" .. map .. ".bsp", "GAME" ) ) then
			catherine.util.NotifyAllLang( "Command_ChangeLevel_Fin", time, map )
			
			timer.Simple( time, function( )
				RunConsoleCommand( "changelevel", map )
			end )
		else
			catherine.util.NotifyLang( pl, "Command_ChangeLevel_Error01" )
		end
	end
} )

catherine.command.Register( {
	command = "settimehour",
	syntax = "[0 ~ 24]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			args[ 1 ] = tonumber( args[ 1 ] )
			
			catherine.environment.buffer.hour = args[ 1 ] and math.Clamp( args[ 1 ], 1, 24 ) or catherine.environment.buffer.hour
			catherine.environment.SendAllEnvironmentConfig( )
			catherine.environment.AutomaticDayNight( )
			
			catherine.util.NotifyLang( pl, "Command_SetTimeHour_Fin", args[ 1 ] )
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )