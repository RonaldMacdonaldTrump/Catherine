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

local LANGUAGE = catherine.language.New( "english" )
LANGUAGE.name = "English"
LANGUAGE.data = {
	// Cash
	[ "Cash_UI_HasStr" ] = "You have a %s.",
	[ "Cash_Notify_Set" ] = "%s have set %s to %s",
	[ "Cash_Notify_Give" ] = "%s have given %s to %s",
	[ "Cash_Notify_Take" ] = "%s have taken %s from %s",
	[ "Cash_Notify_HasNot" ] = "You don't have a enough %s!",
	[ "Cash_Notify_NotValidAmount" ] = "Please enter right amount!",
	
	// Character
	[ "Character_UI_Title" ] = "Character",
	[ "Character_Notify_CantDeleteUsing" ] = "You can't delete using character!",
	[ "Character_Notify_CantSwitchRagdolled" ] = "You can't switch character on ragdolled!",
	[ "Character_Notify_IsNotValid" ] = "This character is not valid!",
	[ "Character_Notify_IsNotValidFaction" ] = "This character faction is not valid!",
	[ "Character_Notify_CantSwitchUsing" ] = "You can't use same character!",
	
	[ "Character_Notify_SetName" ] = "%s are set %s name for %s.",
	[ "Character_Notify_SetDesc" ] = "%s are set %s description for %s.",
	[ "Character_Notify_SetModel" ] = "%s are set %s model for %s.",
	[ "Character_Notify_SetDescLC" ] = "You are set character description to %s.",
	[ "Character_Notify_NameLimitHit" ] = "The character name must be at least " .. catherine.configs.characterNameMinLen .." characters long and up to " .. catherine.configs.characterNameMaxLen .. " characters!",
	[ "Character_Notify_DescLimitHit" ] = "The character description must be at least " .. catherine.configs.characterDescMinLen .." characters long and up to " .. catherine.configs.characterDescMaxLen .. " characters!",
	
	// Faction
	[ "Faction_Notify_Give" ] = "%s have given %s to %s",
	[ "Faction_Notify_Take" ] = "%s have taken %s from %s",
	[ "Faction_Notify_NotValid" ] = "%s is not valid faction!",
	[ "Faction_Notify_NotWhitelist" ] = "%s is not a whitelist!",
	[ "Faction_Notify_AlreadyHas" ] = "%s already has %s whitelist!",
	[ "Faction_Notify_HasNot" ] = "%s has not a %s whitelist!",
	
	// Flag
	[ "Flag_Notify_Give" ] = "%s have given %s to %s",
	[ "Flag_Notify_Take" ] = "%s have taken %s to %s",
	[ "Flag_Notify_AlreadyHas" ] = "%s already has %s flag!",
	[ "Flag_Notify_HasNot" ] = "%s hasen't %s flag!",
	[ "Flag_Notify_NotValid" ] = "%s is not valid flag!",
	
	[ "UnknownError" ] = "Unknown Error!",
	[ "Basic_Notify_UnknownPlayer" ] = "You are not giving a valid character name!",
	[ "Basic_Notify_NoArg" ] = "Please enter the %s argument!",

	// Version
	[ "Version_UI_Title" ] = "Version",
	[ "Version_UI_YourVer_AV" ] = "Ver '%s'",
	[ "Version_UI_YourVer_NO" ] = "Ver 'Error'",
	[ "Version_UI_Checking" ] = "Checking update ...",
	[ "Version_UI_CheckButtonStr" ] = "Update Check",
	[ "Version_Notify_FoundNew" ] = "This server should update to the latest version of Catherine!",
	[ "Version_Notify_AlreadyNew" ] = "This server are using the latest version of Catherine.",
	[ "Version_Notify_CheckError" ] = "Update check error! - %s",
	
	// Attribute
	[ "Attribute_UI_Title" ] = "Attribute",
	
	// Business
	[ "Business_UI_Title" ] = "Business",
	[ "Business_UI_NoBuyable" ] = "You can't buy anything!",
	[ "Business_UI_BuyButtonStr" ] = "Buy Item > %s",
	[ "Business_UI_ShoppingCartStr" ] = "Shopping Cart",
	[ "Business_UI_TotalStr" ] = "Total %s",
	[ "Business_UI_Take" ] = "Take",
	[ "Business_UI_Shipment_Title" ] = "Shipment",
	[ "Business_UI_Shipment_Desc" ] = "A Shipment",
	[ "Business_Notify_BuyQ" ] = "Are you sure you want to buy this item(s)?",
	[ "Business_Notify_CantOpenShipment" ] = "You can't open this shipment!",
	[ "Business_Notify_NeedCartAdd" ] = "Add item on your cart first!",
	
	// Inventory
	[ "Inventory_UI_Title" ] = "Inventory",
	[ "Inventory_Notify_HasNotSpace" ] = "You don't have inventory space!",
	[ "Inventory_Notify_CantDrop01" ] = "Is too far away for drop the item!",
	[ "Inventory_Notify_DontHave" ] = "You don't have this item!",
	[ "Inventory_Notify_IsPersistent" ] = "This item is persistent!",
	
	// Scoreboard
	[ "Scoreboard_UI_Title" ] = "Player List",
	[ "Scoreboard_UI_Author" ] = "Framework Author",
	[ "Scoreboard_UI_UnknownDesc" ] = "You don't know this guy.",
	[ "Scoreboard_UI_PlayerDetailStr" ] = "This player Steam Name is %s\nThis player Steam ID is %s\nThis player Ping is %s",
	
	// Help
	[ "Help_UI_Title" ] = "Help",
	
	// Storage
	[ "Storage_Notify_HasNotSpace" ] = "This storage don't have inventory space!",
	
	// Item SYSTEM
	[ "Item_Notify_NoItemData" ] = "Is not an available item!",
	
	// Item Base
	[ "Item_Category_Other" ] = "Other",
	[ "Item_Category_Weapon" ] = "Weapon",
	[ "Item_Category_Storage" ] = "Storage",
	
	[ "Item_Category_Wallet" ] = "Wallet",
	[ "Item_Name_Wallet" ] = "Wallet",
	[ "Item_Desc_Wallet" ] = catherine.configs.cashName .. " in a small stack.",
	[ "Item_FuncStr01_Wallet" ] = "Take " .. catherine.configs.cashName,
	[ "Item_FuncStr02_Wallet" ] = "Drop " .. catherine.configs.cashName,
	
	[ "Item_FuncStr01_Weapon" ] = "Equip",
	[ "Item_FuncStr02_Weapon" ] = "Unequip",
	[ "Item_FuncStr01_Basic" ] = "Take",
	[ "Item_FuncStr02_Basic" ] = "Drop",
	
	[ "Item_Free" ] = "Free",
	
	// Entity
	[ "Entity_Notify_NotValid" ] = "This isn't a valid entity!",
	[ "Entity_Notify_NotPlayer" ] = "This isn't a valid player!",
	[ "Entity_Notify_NotDoor" ] = "This isn't a valid door!",
	
	// Command
	[ "Command_Notify_NotFound" ] = "Command not found!",
	
	// Player
	[ "Player_Message_Ragdolled_01" ] = "You are regaining consciousness ...",
	[ "Player_Message_HasNotPermission" ] = "You don't have permission!",
	
	// Recognize
	[ "Recognize_UI_Option_LookingPlayer" ] = "Recognize for looking player.",
	[ "Recognize_UI_Option_TalkRange" ] = "All characters within talking range.",
	[ "Recognize_UI_Option_YellRange" ] = "All characters within yelling range.",
	[ "Recognize_UI_Option_WhisperRange" ] = "All characters within whispering range.",
	[ "Recognize_UI_Unknown" ] = "Unknown",
	
	// Door
	[ "Door_Notify_CMD_Locked" ] = "You are locked this door.",
	[ "Door_Notify_CMD_UnLocked" ] = "You are unlocked this door.",
	[ "Door_Notify_BuyQ" ] = "Are you sure you want to buy this door?",
	[ "Door_Message_Locking" ] = "Locking ...",
	[ "Door_Message_UnLocking" ] = "UnLocking ...",
	[ "Door_Message_Buyable" ] = "This door can purchase.",
	[ "Door_Message_CantBuy" ] = "This door can't purchase.",
	[ "Door_Message_AlreadySold" ] = "This door has already been purchased",
	[ "Door_Notify_AlreadySold" ] = "This door is already sold by someone!",
	[ "Door_Notify_NoOwner" ] = "You are not owner for this door!",
	[ "Door_Notify_CantBuyable" ] = "This door can't buy!",
	[ "Door_Notify_Buy" ] = "You are buy this door.",
	[ "Door_Notify_Sell" ] = "You are sold this door.",
	[ "Door_Notify_SetTitle" ] = "You are set title this door.",
	[ "Door_Notify_SetStatus_True" ] = "You are set status to unbuyable this door.",
	[ "Door_Notify_SetStatus_False" ] = "You are set status to buyable this door.",
	
	// Hint
	[ "Hint_Message_01" ] = "Type // before your message to talk out-of-character.",
	[ "Hint_Message_02" ] = "Type .// or [[ before your message to talk out-of-character locally.",
	[ "Hint_Message_03" ] = "Press 'F1 key' to view your character and roleplay information.",
	[ "Hint_Message_04" ] = "Press 'Tab key' to view the main menu.",
	
	// Option
	[ "Option_UI_Title" ] = "Option",
	[ "Option_Category_01" ] = "Framework Settings",

	[ "Option_Str_BAR_Name" ] = "Show Bar",
	[ "Option_Str_BAR_Desc" ] = "Displays the Bar.",
	
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
	[ "Chat_Str_Roll" ] = "%s roll %s",
	[ "Chat_Str_Connect" ] = "%s has joined to server.",
	[ "Chat_Str_Disconnect" ] = "%s has disconnected to server.",
	
	// Basic
	[ "Basic_UI_StringRequest" ] = "Request",
	[ "Basic_UI_Question" ] = "Question",
	[ "Basic_UI_Notify" ] = "Notify",
	[ "Basic_UI_OK" ] = "OK",
	[ "Basic_UI_YES" ] = "YES",
	[ "Basic_UI_NO" ] = "NO"
}

catherine.language.Register( LANGUAGE )