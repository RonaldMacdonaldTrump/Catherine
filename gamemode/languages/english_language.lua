local LANGUAGE = catherine.language.New( "english" )
LANGUAGE.name = "English"
LANGUAGE.data = {
	// Cash ^-^;
	[ "Cash_GiveMessage01" ] = "You have given %s to %s",
	
	// Faction ^-^;
	[ "Faction_AddMessage01" ] = "Set faction",
	[ "Faction_RemoveMessage01" ] = "Take faction",
	
	// Flag ^-^;
	[ "Flag_GiveMessage01" ] = "Give flag",
	[ "Flag_TakeMessage01" ] = "Take flag",
	
	[ "UnknownError" ] = "Unknown Error!",
	[ "UnknownPlayerError" ] = "You are not giving a valid character name!",
	[ "ArgError" ] = "Please enter the %s argument!"
}

catherine.language.Register( LANGUAGE )