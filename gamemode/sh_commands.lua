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
					catherine.character.SetGlobalVar( target, "_name", args[ 2 ] )
					catherine.util.Notify( pl, "Set name" )
				else
					catherine.util.Notify( pl, catherine.language.GetValue( pl, "UnknownPlayerError" ) )
				end
			else
				catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 2 ) )
			end
		else
			catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 1 ) )
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
					catherine.character.SetGlobalVar( target, "_desc", args[ 2 ] )
					catherine.util.Notify( pl, "Set desc" )
				else
					catherine.util.Notify( pl, catherine.language.GetValue( pl, "UnknownPlayerError" ) )
				end
			else
				catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 2 ) )
			end
		else
			catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 1 ) )
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
					catherine.character.SetGlobalVar( target, "_model", args[ 2 ] )
					catherine.util.Notify( pl, "Set model" )
				else
					catherine.util.Notify( pl, catherine.language.GetValue( pl, "UnknownPlayerError" ) )
				end
			else
				catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 2 ) )
			end
		else
			catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 1 ) )
		end
	end
} )

catherine.command.Register( {
	command = "charphysdesc",
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 1 ]:len( ) >= catherine.configs.characterDescMinLen and args[ 1 ]:len( ) < catherine.configs.characterDescMaxLen ) then
				catherine.character.SetGlobalVar( pl, "_desc", args[ 1 ] )
				catherine.util.Notify( pl, "Set your desc" )
			else
				catherine.util.Notify( pl, "The character description must be at least " .. catherine.configs.characterDescMinLen .." characters long and up to " .. catherine.configs.characterDescMaxLen .. " characters!" )
			end
		else
			catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 1 ) )
		end
	end
} )

catherine.command.Register( {
	command = "doorlock",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local ent = pl:GetEyeTraceNoCursor( ).Entity
		
		if ( IsValid( ent ) and catherine.entity.IsDoor( ent ) ) then
			ent:Fire( "Lock", "", 0 ) 
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
			ent:Fire( "Unlock", "", 0 ) 
			ent:EmitSound( "doors/door_latch3.wav" )
			catherine.util.NotifyLang( pl, "Door_Notify_CMD_UnLocked" )
		else
			catherine.util.NotifyLang( pl, "Entity_Notify_NotDoor" )
		end
	end
} )