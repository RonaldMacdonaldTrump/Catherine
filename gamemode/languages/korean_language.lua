local LANGUAGE = catherine.language.New( "korean" )
LANGUAGE.name = "Korean(한국어)"
LANGUAGE.data = {
	// Cash ^-^;
	[ "Cash_GiveMessage01" ] = "당신은 %s 님에게 %s 를 주셨습니다.",
	
	// Faction ^-^;
	[ "Faction_AddMessage01" ] = "Give faction",
	[ "Faction_RemoveMessage01" ] = "Take faction",	
	
	// Flag ^-^;
	[ "Flag_GiveMessage01" ] = "Give flag",
	[ "Flag_TakeMessage01" ] = "Take flag",
	
	[ "UnknownError" ] = "알 수 없는 오류 입니다.",
	[ "UnknownPlayerError" ] = "올바르지 않은 캐릭터 이름을 입력했습니다!",
	[ "ArgError" ] = "%s 번째 값을 입력하세요!"
}

catherine.language.Register( LANGUAGE )