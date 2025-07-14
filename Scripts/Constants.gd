# Constants.gd
extends Node
class_name Constants


enum CharacterType {
	FIGHTER, 
	HEALER, 
	VALKYRIE, 
	MAGE
}

var character_type_names = {
	CharacterType.HEALER: "Healer",
	CharacterType.FIGHTER: "Fighter",
	CharacterType.VALKYRIE: "Valkyrie",
	CharacterType.MAGE: "Mage"
}


	

#func nameType():
	#if CharacterType == 0:
		#return 

# You can also define other global constants or enums here if needed
