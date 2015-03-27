local LANGUAGE = catherine.language.New( "russian" )
LANGUAGE.name = "Russian"
LANGUAGE.data = {
	[ "LanguageError01" ] = "Error Language",
	
	// Cash ^-^;
	[ "Cash_GiveMessage01" ] = "Вы дали %s для %s",
	
	// Faction ^-^;
	[ "Faction_AddMessage01" ] = "Набор фракции",
	[ "Faction_RemoveMessage01" ] = "Возьмите фракцию",
	
	// Flag ^-^;
	[ "Flag_GiveMessage01" ] = "Дайте флаг",
	[ "Flag_TakeMessage01" ] = "Возьмите флаг",
	
	[ "UnknownError" ] = "Неизвестная ошибка!",
	[ "UnknownPlayerError" ] = "Вы не даете правильный имя персонажа!",
	[ "ArgError" ] = "Пожалуйста, введите %s аргумент!"
}

catherine.language.Register( LANGUAGE )
