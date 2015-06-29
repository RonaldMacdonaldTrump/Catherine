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

--[[
	Syntax fixed by Dremek.
	( http://steamcommunity.com/profiles/76561198052257272/ )
]]--

local LANGUAGE = catherine.language.New( "english" )
LANGUAGE.name = "English"
LANGUAGE.data = {
	// Class
	[ "Class_UI_Title" ] = "Class",
	[ "Class_UI_LimitStr" ] = "%s / %s",
	[ "Class_UI_SalaryStr" ] = "%s per hour",
	[ "Class_UI_Unlimited" ] = "Unlimited",
	[ "Class_UI_NoJoinable" ] = "You can not join this!",
	
	// GlobalBan
	[ "GlobalBan_UI_Title" ] = "Global Ban",
	[ "GlobalBan_UI_Blank" ] = "Doesn't have user in Global Ban.",
	[ "GlobalBan_UI_NotUsing" ] = "This server doesn't using Global Ban service.",
	[ "GlobalBan_UI_Users" ] = "%s's users are blocked.",
	
	// Cash
	[ "Cash_UI_HasStr" ] = "You have %s " .. catherine.configs.cashName ..".",
	[ "Cash_UI_TargetHasStr" ] = "This player has %s " .. catherine.configs.cashName ..".",
	[ "Cash_Notify_Set" ] = "%s has set %s to %s",
	[ "Cash_Notify_Give" ] = "%s has given %s to %s",
	[ "Cash_Notify_Take" ] = "%s has taken %s from %s",
	[ "Cash_Notify_HasNot" ] = "You do not have a enough " .. catherine.configs.cashName .. "!",
	[ "Cash_Notify_NotValidAmount" ] = "Please enter a valid amount!",
	[ "Cash_Notify_Salary" ] = "You have received %s " .. catherine.configs.cashName .. " from your salary.",
	[ "Cash_Notify_Get" ] = "You are found %s " .. catherine.configs.cashName .. ".",
	
	// Character
	[ "Character_UI_Title" ] = "Character",
	[ "Character_UI_CreateCharStr" ] = "Create Character",
	[ "Character_UI_LoadCharStr" ] = "Load Character",
	[ "Character_UI_Close" ] = "Close",
	[ "Character_UI_ChangeLogStr" ] = "Update Log",
	[ "Character_UI_ExitServerStr" ] = "Disconnect",
	[ "Character_UI_BackStr" ] = "Back to Main Menu",
	[ "Character_UI_DontHaveAny" ] = "You do not have any characters.",
	[ "Character_UI_UseCharacter" ] = "Use this character.",
	[ "Character_UI_DeleteCharacter" ] = "Delete this character.",
	[ "Character_UI_CharInfo" ] = "Character Information",
	[ "Character_UI_CharName" ] = "Character Name",
	[ "Character_UI_CharDesc" ] = "Character Description",
	[ "Character_UI_SelectFaction" ] = "> Select faction.",
	[ "Character_Notify_DeleteQ" ] = "Are you sure you want to delete this character?",
	[ "Character_Notify_ExitQ" ] = "Are you sure you want to disconnect from the server?",
	[ "Character_Notify_CantDeleteUsing" ] = "You can not delete the character you are currently using!",
	[ "Character_Notify_CantSwitchRagdolled" ] = "You can not switch characters while you are unconscious!",
	[ "Character_Notify_IsNotValid" ] = "This character is not valid!",
	[ "Character_Notify_CantUseThisFaction" ] = "You can't use this faction!",
	[ "Character_Notify_IsNotValidFaction" ] = "This character's faction is not valid!",
	[ "Character_Notify_CharBanned" ] = "This character is banned!",
	[ "Character_Notify_CantSwitchUsing" ] = "You are already using this character!",
	[ "Character_Notify_CantSwitchDeath" ] = "You can not switch character while dead!",
	[ "Character_Notify_CantSwitchTied" ] = "You can not switch characters while tied!",
	[ "Character_Notify_MaxLimitHit" ] = "You can not create any more characters!",
	[ "Character_Notify_CharBan" ] = "%s has banned the character %s.",
	[ "Character_Notify_CharUnBan" ] = "%s has unbanned the character %s.",
	[ "Character_Notify_SetName" ] = "%s has set the name of %s to %s.",
	[ "Character_Notify_SetDesc" ] = "%s has set the description of %s to %s.",
	[ "Character_Notify_SetModel" ] = "%s are set %s model for %s.",
	[ "Character_Notify_SetDescLC" ] = "You have set your character description to %s.",
	[ "Character_Notify_SelectModel" ] = "Please select a character model!",
	[ "Character_Notify_NameLimitHit" ] = "The character name must be at least " .. catherine.configs.characterNameMinLen .." characters long with a maximum of " .. catherine.configs.characterNameMaxLen .. " characters!",
	[ "Character_Notify_DescLimitHit" ] = "The character description must be at least " .. catherine.configs.characterDescMinLen .." characters long with a maximum of " .. catherine.configs.characterDescMaxLen .. " characters!",
	
	// Faction
	[ "Faction_UI_Title" ] = "Faction",
	[ "Faction_Notify_Give" ] = "%s has given %s to %s",
	[ "Faction_Notify_Take" ] = "%s has taken %s from %s",
	[ "Faction_Notify_NotValid" ] = "%s is not a valid faction!",
	[ "Faction_Notify_NotWhitelist" ] = "%s is not a valid whitelist!",
	[ "Faction_Notify_AlreadyHas" ] = "%s already has the %s whitelist!",
	[ "Faction_Notify_HasNot" ] = "%s does not have the %s whitelist!",
	[ "Faction_Notify_SelectPlease" ] = "Please select a faction!",
	
	// Accessory
	[ "Accessory_Wear_ModelError" ] = "Model error.",
	[ "Accessory_Wear_BoneExists" ] = "This bone already has accessory.",
	[ "Accessory_Wear_BoneNotExists" ] = "This bone not has accessory.",
	[ "Accessory_Wear_BoneIndexError" ] = "Bone data is not a valid.",
	
	// Flag
	[ "Flag_Notify_Give" ] = "%s has given %s to %s",
	[ "Flag_Notify_Take" ] = "%s has taken %s from %s",
	[ "Flag_Notify_AlreadyHas" ] = "%s already has the %s flag!",
	[ "Flag_Notify_HasNot" ] = "%s does not have the %s flag!",
	[ "Flag_Notify_NotValid" ] = "%s is not a valid flag!",
	[ "Flag_p_Desc" ] = "Access to the physgun.",
	[ "Flag_t_Desc" ] = "Access to the toolgun.",
	[ "Flag_e_Desc" ] = "Access to prop spawning.",
	[ "Flag_x_Desc" ] = "Access to entity spawning.",
	[ "Flag_V_Desc" ] = "Access to vehicle spawning.",
	[ "Flag_n_Desc" ] = "Access to NPC spawning.",
	[ "Flag_R_Desc" ] = "Access to ragdoll spawning.",
	[ "Flag_s_Desc" ] = "Access to effect spawning.",
	
	[ "UnknownError" ] = "Unknown Error!",
	[ "Basic_Notify_UnknownPlayer" ] = "You have not given a valid character name!",
	[ "Basic_Notify_NoArg" ] = "Please enter the %s argument!",
	[ "Basic_Notify_InputText" ] = "Please enter the text!",

	// Version
	[ "Version_UI_Title" ] = "Version",
	[ "Version_UI_YourVer_AV" ] = "Ver '%s'",
	[ "Version_UI_YourVer_NO" ] = "Ver 'Error'",
	[ "Version_UI_Checking" ] = "Checking update ...",
	[ "Version_UI_CheckButtonStr" ] = "Update Check",
	[ "Version_Notify_FoundNew" ] = "This server should update to the latest version of Catherine!",
	[ "Version_Notify_AlreadyNew" ] = "This server is using the latest version of Catherine.",
	[ "Version_Notify_CheckError" ] = "Update check error! - %s",
	
	// Attribute
	[ "Attribute_UI_Title" ] = "Attribute",
	
	// Business
	[ "Business_UI_Title" ] = "Business",
	[ "Business_UI_NoBuyable" ] = "You can not buy this!",
	[ "Business_UI_BuyButtonStr" ] = "Buy Item > %s",
	[ "Business_UI_ShoppingCartStr" ] = "Shopping Cart",
	[ "Business_UI_TotalStr" ] = "Total %s",
	[ "Business_UI_Take" ] = "Take",
	[ "Business_UI_Shipment_Title" ] = "Shipment",
	[ "Business_UI_Shipment_Desc" ] = "A Shipment",
	[ "Business_Notify_BuyQ" ] = "Are you sure you want to buy these item(s)?",
	[ "Business_Notify_CantOpenShipment" ] = "You can not open this shipment!",
	[ "Business_Notify_NeedCartAdd" ] = "Add an item onto your cart first!",
	
	// Inventory
	[ "Inventory_UI_Title" ] = "Inventory",
	[ "Inventory_Notify_HasNotSpace" ] = "You do not have enough inventory space!",
	[ "Inventory_Notify_HasNotSpaceTarget" ] = "Target does not have enough inventory space!",
	[ "Inventory_Notify_CantDrop01" ] = "You are looking too far away to drop this item!",
	[ "Inventory_Notify_DontHave" ] = "You do not have this item!",
	[ "Inventory_Notify_IsPersistent" ] = "This item is persistent!",
	
	// Scoreboard
	[ "Scoreboard_UI_Title" ] = "Player List",
	[ "Scoreboard_UI_Author" ] = "Gamemode Author",
	[ "Scoreboard_UI_UnknownDesc" ] = "You do not recognize this person.",
	[ "Scoreboard_UI_PlayerDetailStr" ] = "Steam Name : %s\nSteam ID : %s\nPing : %s",
	[ "Scoreboard_UI_can notLook_Str" ] = "You can not look at this.",
	[ "Scoreboard_PlayerOption01_Str" ] = "Open Steam Profile",
	[ "Scoreboard_PlayerOption02_Str" ] = "Change Character Name",
	[ "Scoreboard_PlayerOption02_Q" ] = "What would you like to be the character's name?",
	[ "Scoreboard_PlayerOption03_Str" ] = "Give Whitelist",
	[ "Scoreboard_PlayerOption04_Str" ] = "Character Ban / Unban",
	[ "Scoreboard_PlayerOption04_Q" ] = "Are you sure you would like to ban / unban this character?",
	[ "Scoreboard_PlayerOption05_Str" ] = "Flag Give",
	[ "Scoreboard_PlayerOption05_Q" ] = "What are you want to give flags?",
	[ "Scoreboard_PlayerOption06_Str" ] = "Flag Take",
	[ "Scoreboard_PlayerOption06_Q" ] = "What are you want to take flags?",
	
	// Help
	[ "Help_UI_Title" ] = "Help",
	[ "Help_UI_DefPageTitle" ] = "Welcome.",
	[ "Help_UI_DefPageDesc" ] = "Press and look at page if you want.",
	[ "Help_Category_Flag" ] = "Flag",
	[ "Help_Category_Credit" ] = "Credit",
	[ "Help_Category_Changelog" ] = "Change log",
	[ "Help_Category_Command" ] = "Command",
	[ "Help_Category_Plugin" ] = "Plugin",
	
	// Plugin
	[ "Plugin_Value_Author" ] = "Development by %s",
	
	// Storage
	[ "Storage_UI_YourInv" ] = "Your Inventory",
	[ "Storage_UI_StorageNoHaveItem" ] = "This storage is empty.",
	[ "Storage_UI_PlayerNoHaveItem" ] = "You do not have any items.",
	[ "Storage_Notify_HasNotSpace" ] = "This storage does not have enough inventory space!",
	[ "Storage_OpenStr" ] = "Open",
	
	// Item SYSTEM
	[ "Item_Notify_NoItemData" ] = "This is not an available item!",
	
	// Item Base
	[ "Item_Category_Other" ] = "Other",
	[ "Item_Category_Weapon" ] = "Weapon",
	[ "Item_Category_Storage" ] = "Storage",
	[ "Item_Category_Clothing" ] = "Clothing",
	[ "Item_Category_BodygroupClothing" ] = "Clothing",
	[ "Item_Func01Notify01_BodygroupClothing" ] = "You can't wear this clothing!",
	[ "Item_Func01Notify02_BodygroupClothing" ] = "You are already wearing this clothing on this bone!",
	[ "Item_Func02Notify01_BodygroupClothing" ] = "You can't take off this clothing!",
	[ "Item_Func02Notify02_BodygroupClothing" ] = "You are not wearing this clothing on this bone!",
	[ "Item_FuncStr01_Clothing" ] = "Wear",
	[ "Item_FuncStr02_Clothing" ] = "Take off",
	[ "Item_Category_Accessory" ] = "Accessory",
	[ "Item_FuncStr01_Accessory" ] = "Wear",
	[ "Item_FuncStr02_Accessory" ] = "Take off",
	[ "Item_Category_Ammo" ] = "Ammunition",
	[ "Item_FuncStr01_Ammo" ] = "Use",
	
	[ "Item_Category_Wallet" ] = "Wallet",
	[ "Item_Name_Wallet" ] = "Wallet",
	[ "Item_Desc_Wallet" ] = catherine.configs.cashName .. " in a small stack.",
	[ "Item_Desc_World_Wallet" ] = "%s in a small stack.",
	[ "Item_FuncStr01_Wallet" ] = "Take " .. catherine.configs.cashName,
	[ "Item_FuncStr02_Wallet" ] = "Drop " .. catherine.configs.cashName,
	[ "Item_DropQ_Wallet" ] = "How much money would you like to drop?",
	
	[ "Item_Notify01_ZT" ] = "This player is already tied!",
	[ "Item_Notify02_ZT" ] = "You do not have Zip Tie!",
	[ "Item_Notify03_ZT" ] = "You are tied!",
	[ "Item_Notify04_ZT" ] = "This player is not tied!",
	[ "Item_Message01_ZT" ] = "Tieing ...",
	[ "Item_Message02_ZT" ] = "Untieing ...",
	[ "Item_Message03_ZT" ] = "You are tied.",
	
	[ "Item_FuncStr01_Weapon" ] = "Equip",
	[ "Item_FuncStr02_Weapon" ] = "Unequip",
	[ "Item_Notify01_Weapon" ] = "You can not equip this weapon!",
	[ "Item_FuncStr01_Basic" ] = "Take",
	[ "Item_FuncStr02_Basic" ] = "Drop",
	
	[ "Item_Free" ] = "Free",
	
	// Entity
	[ "Entity_Notify_NotValid" ] = "This isn't a valid entity!",
	[ "Entity_Notify_NotPlayer" ] = "This isn't a valid player!",
	[ "Entity_Notify_NotDoor" ] = "This isn't a valid door!",
	[ "Entity_Notify_TooFar" ] = "You are too far by entity!",
	
	// Command
	[ "Command_Notify_NotFound" ] = "Command not found!",
	[ "Command_DefDesc" ] = "A Command.",
	[ "Command_OOC_Error" ] = "You must wait %s more second(s) before being able to use OOC.",
	[ "Command_LOOC_Error" ] = "You must wait %s more second(s) before being able to use LOOC.",
	
	// Player
	[ "Player_Message_Dead_HUD" ] = "The person is dead.",
	[ "Player_Message_Ragdolled_HUD" ] = "The person is unconscious.",
	[ "Player_Message_Ragdolled_01" ] = "You are unconscious.",
	[ "Player_Message_Dead_01" ] = "You are dead ...",
	[ "Player_Message_GettingUp" ] = "You are regaining consciousness ...",
	[ "Player_Message_AlreayGettingUp" ] = "You are already getting up!",
	[ "Player_Message_AlreadyFallovered" ] = "You are already fallen over!",
	[ "Player_Message_NotFallovered" ] = "You are not fallen over!",
	[ "Player_Message_HasNotPermission" ] = "You do not have permission!",
	[ "Player_Message_UnTie" ] = "Press 'Use' to untie.",
	[ "Player_Message_TiedBlock" ] = "You can not do this when tied.",
	
	// Recognize
	[ "Recognize_UI_Option_LookingPlayer" ] = "Recognize for looking player.",
	[ "Recognize_UI_Option_TalkRange" ] = "All characters within talking range.",
	[ "Recognize_UI_Option_YellRange" ] = "All characters within yelling range.",
	[ "Recognize_UI_Option_WhisperRange" ] = "All characters within whispering range.",
	[ "Recognize_UI_Unknown" ] = "Unknown",
	
	// Door
	[ "Door_Notify_CMD_Locked" ] = "You have locked this door.",
	[ "Door_Notify_CMD_UnLocked" ] = "You have unlocked this door.",
	[ "Door_Notify_BuyQ" ] = "Are you sure you want to buy this door?",
	[ "Door_Notify_SellQ" ] = "Are you sure you want to sell this door?",
	[ "Door_Message_Locking" ] = "Locking ...",
	[ "Door_Message_UnLocking" ] = "Unlocking ...",
	[ "Door_Message_Buyable" ] = "This door can be purchased.",
	[ "Door_Message_CantBuy" ] = "This door can not be purchased.",
	[ "Door_Message_AlreadySold" ] = "This door has already been purchased!",
	[ "Door_Notify_AlreadySold" ] = "This door has already been purchased!",
	[ "Door_Notify_NoOwner" ] = "You are not the owner of this door!",
	[ "Door_Notify_CantBuyable" ] = "You can not buy this door!",
	[ "Door_Notify_Buy" ] = "You have bought this door.",
	[ "Door_Notify_Sell" ] = "You have sold this door.",
	[ "Door_Notify_SetTitle" ] = "You have set a title for this door.",
	[ "Door_Notify_SetDesc" ] = "You have set a description for this door.",
	[ "Door_Notify_SetDescHitLimit" ] = "You are over the description limit!",
	[ "Door_Notify_SetStatus_True" ] = "You have set this door to unownable.",
	[ "Door_Notify_SetStatus_False" ] = "You have set this to ownable.",
	[ "Door_Notify_Disabled_True" ] = "You have enabled this door.",
	[ "Door_Notify_Disabled_False" ] = "You have disabled this door.",
	[ "Door_Notify_DoorSpam" ] = "Do not door-spam!",
	
	[ "Door_Notify_ChangePer" ] = "You have changed permissions for this door.",
	[ "Door_Notify_RemPer" ] = "You have been removed from the permissions for this door.",
	[ "Door_Notify_AlreadyHasPer" ] = "This door already has permissions!",
	[ "Door_Notify_CantChangeOwner" ] = "You can not change the door owner!",
	
	[ "Door_UI_Default" ] = "Door",
	[ "Door_UI_DoorDescStr" ] = "Door Description",
	[ "Door_UI_DoorSellStr" ] = "Sell Door",
	[ "Door_UI_AllPerStr" ] = "All Permission",
	[ "Door_UI_BasicPerStr" ] = "Basic Permission",
	[ "Door_UI_RemPerStr" ] = "Permission Remove",
	[ "Door_UI_OwnerStr" ] = "Owner",
	[ "Door_UI_AllStr" ] = "All",
	[ "Door_UI_BasicStr" ] = "Basic",
	
	// Hint
	[ "Hint_Message_01" ] = "Type // before your message to talk out-of-character.",
	[ "Hint_Message_02" ] = "Type .// or [[ before your message to talk out-of-character locally.",
	[ "Hint_Message_03" ] = "Press 'F1 key' to view your character and roleplay information.",
	[ "Hint_Message_04" ] = "Press 'Tab key' to view the main menu.",
	
	// Option
	[ "Option_UI_Title" ] = "Option",
	[ "Option_Category_01" ] = "Framework",
	[ "Option_Category_02" ] = "Development",
	[ "Option_Category_03" ] = "Administrator",

	[ "Option_Str_BAR_Name" ] = "Show Bar",
	[ "Option_Str_BAR_Desc" ] = "Displays the Bar.",
	
	[ "Option_Str_CHAT_TIMESTAMP_Name" ] = "Show Chat Timestamp",
	[ "Option_Str_CHAT_TIMESTAMP_Desc" ] = "Displays chat timestamp in the chat message.",
	
	[ "Option_Str_ADMIN_ESP_Name" ] = "Show Admin ESP",
	[ "Option_Str_ADMIN_ESP_Desc" ] = "Only show the administrative ESP if in noclipping.",
	
	[ "Option_Str_Always_ADMIN_ESP_Name" ] = "Always Show Admin ESP",
	[ "Option_Str_Always_ADMIN_ESP_Desc" ] = "Always show the administrative ESP, even when not in noclip.",
	
	[ "Option_Str_MAINHUD_Name" ] = "Show Main HUD",
	[ "Option_Str_MAINHUD_Desc" ] = "Displays Main HUD.",
	
	[ "Option_Str_MAINLANG_Name" ] = "Main Language",
	[ "Option_Str_MAINLANG_Desc" ] = "Change the Main Language.",
	
	[ "Option_Str_HINT_Name" ] = "Show Hint",
	[ "Option_Str_HINT_Desc" ] = "Displays the hint.",
	
	// Chat
	[ "Chat_Str_IC" ] = "%s says %s",
	[ "Chat_Str_Yell" ] = "%s yells %s",
	[ "Chat_Str_Whisper" ] = "%s whispers %s",
	[ "Chat_Str_Console" ] = "Console",
	[ "Chat_Str_Roll" ] = "%s roll %s",
	[ "Chat_Str_Connect" ] = "%s has joined to server.",
	[ "Chat_Str_Disconnect" ] = "%s has disconnected to server.",
	
	// Question
	[ "Question_UIStr" ] = "Question",
	[ "Question_KickMessage" ] = "Answer has a wrong!",
	
	[ "Question_UI_Continue" ] = "Continue",
	[ "Question_UI_Disconnect" ] = "Disconnect",
	[ "Question_Notify_DisconnectQ" ] = "Are you sure you want to disconnect from the server?",
	
	// Basic
	[ "Basic_UI_StringRequest" ] = "Request",
	[ "Basic_UI_Question" ] = "Question",
	[ "Basic_UI_Notify" ] = "Notify",
	[ "Basic_UI_Continue" ] = "Continue",
	[ "Basic_UI_OK" ] = "OK",
	[ "Basic_UI_YES" ] = "YES",
	[ "Basic_UI_NO" ] = "NO",
	[ "Basic_UI_Count" ] = "%s's",
	[ "Basic_Framework_Author" ] = "Development and design by %s.",
	[ "Basic_Notify_BunnyHop" ] = "Do not Bunny-hop!",
	
	[ "Command_ChangeLevel_Fin" ] = "%s(sec) after change map to %s.",
	[ "Command_ChangeLevel_Error01" ] = "Map is not a valid!",
	[ "Command_RestartLevel_Fin" ] = "%s(sc) after restart a server.",
	[ "Command_ClearDecals_Fin" ] = "You have cleared all decals on the map.",
	[ "Command_SetTimeHour_Fin" ] = "You have set the roleplay time to %s(hour).",
	[ "Command_PrintBodyGroup_Fin" ] = "Printed target player Body groups on the Console.",
	
	[ "AntiHaX_KickMessage" ] = "Sorry, you have been kicked for using cheats.",
	[ "AntiHaX_KickMessage_TimeOut" ] = "Sorry, you have been kicked because the anti-cheat timed out.",
	
	// Weapon
	[ "Weapon_Instructions_Title" ] = "- Instructions -",
	[ "Weapon_Purpose_Title" ] = "- Purpose -",
	[ "Weapon_Author_Title" ] = "- Author -",
	
	[ "Weapon_Fists_Name" ] = "Fists",
	[ "Weapon_Fists_Instructions" ] = "Primary Fire : Punch.\nSecondary Fire : Knock.",
	[ "Weapon_Fists_Purpose" ] = "Punching characters and knocking on doors.",
	
	[ "Weapon_Key_Name" ] = "Keys",
	[ "Weapon_Key_Instructions" ] = "Primary Fire : Lock.\nSecondary Fire : Unlock.",
	[ "Weapon_Key_Purpose" ] = "Locking and unlocking entities that you have access to."
}

catherine.language.Register( LANGUAGE )