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
	[ "LanguageError01" ] = "Error Language",
	
	// Cash ^-^;
	[ "Cash_UI_HasStr" ] = "You have a %s.",
	[ "Cash_Notify_Set" ] = "%s have set %s to %s",
	[ "Cash_Notify_Give" ] = "%s have given %s to %s",
	[ "Cash_Notify_Take" ] = "%s have taken %s from %s",
	[ "Cash_Notify_HasNot" ] = "You don't have a enough %s!",
	[ "Cash_Notify_NotValidAmount" ] = "Please enter right amount!",
	
	
	// Faction ^-^;
	[ "Faction_Notify_Give" ] = "%s have given %s to %s",
	[ "Faction_Notify_Take" ] = "%s have taken %s from %s",
	[ "Faction_Notify_NotValid" ] = "%s is not valid faction!",
	[ "Faction_Notify_AlreadyHasOrNotWhitelist" ] = "Faction is not valid or not whitelist",
	
	// Flag ^-^;
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
	[ "Business_Notify_BuyQ" ] = "Are you sure you want to buy this item(s) ?",
	[ "Business_Notify_CantOpenShipment" ] = "You can't open this shipment!",
	[ "Business_Notify_NeedCartAdd" ] = "Add item on your cart first!",
	
	// Inventory
	[ "Inventory_UI_Title" ] = "Inventory",
	[ "Inventory_Notify_HasNotSpace" ] = "You don't have inventory space!",
	[ "Inventory_Notify_CantDrop01" ] = "Is too far away for drop the item!",
	[ "Inventory_Notify_DontHave" ] = "You don't have this item!",
	
	// Scoreboard
	[ "Scoreboard_UI_Title" ] = "Player List",
	[ "Scoreboard_UI_Author" ] = "Framework Author",
	[ "Scoreboard_UI_UnknownDesc" ] = "You don't know this guy.",
	[ "Scoreboard_UI_PlayerDetailStr" ] = "This player Steam Name is %s\nThis player Steam ID is %s\nThis player Ping is %s",
	
	// Help
	[ "Help_UI_Title" ] = "Help",
	
	// Storage
	[ "Storage_Notify_HasNotSpace" ] = "This storage don't have inventory space!",
	
	// Item
	[ "Item_Notify_NoItemData" ] = "Is not an available item!",
	
	// Entity
	[ "Entity_Notify_NotValid" ] = "This isn't a valid entity!",
	[ "Entity_Notify_NotPlayer" ] = "This isn't a valid player!",
	[ "Entity_Notify_NotDoor" ] = "This isn't a valid door!",
	
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
	
	// Basic
	[ "Basic_UI_CATLoaded" ] = "Welcome.",
	[ "Basic_UI_StringRequest" ] = "Request",
	[ "Basic_UI_Question" ] = "Question",
	[ "Basic_UI_Notify" ] = "Notify",
	[ "Basic_UI_OK" ] = "OK",
	[ "Basic_UI_YES" ] = "YES",
	[ "Basic_UI_NO" ] = "NO"
}

catherine.language.Register( LANGUAGE )