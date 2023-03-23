# Rideable Pokémon - mod for A Hat in Time
This repository contains UnrealScript source code for my Rideable Pokémon mod.
## General information
First published to [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1982278287) on January 29th 2020.
Only contents of Classes folder is available - no CompiledScripts/Content/CookedPC files.
## Mod features
- A dozen of Status Effect scripts extending default Scooter (Hat_StatusEffect_BadgeScooter) and turning it into a certain Pokémon. Each one of them has their own functions handling animation and sound playback as well as modifying Texture Parameters inside Pokémon's Mesh Materials and Materials themselves for certain events ("honking", Player lowering or increasing health, equipping or unequipping Wireframe Dye).
- A dozen of Hat Flair scripts extending default Flair (Hat_CosmeticItemQualityInfo) and turning it into a certain hatwear related to Pokémon video game series.
- A dozen of Backpack Collectible script extending default Backpack Collectible (Hat_Collectible_Backpack) that make these Flairs sellable by Badge Seller NPC.
- A GameMod-extending script containing code for executing mechanism preventing Player from being able to use Status Effect in some cases (inside OnPreStatusEffectGiven function), handling playback for Accumula Town music for Player using Furret Status Effect, handling Status Effects used by Online Party Players, showing subtitles to Player and removing all Hat Flairs when mod is disabled.
- An abstract class for sending Online Party Commands and handling ones from other Players.
- An abstract "Tools" class containing functions for handling Materials and MeshComponents.
- An abstract "Tools" class containing functions for handling Player Pawns, their Controllers and Steamworks SteamID.
## Support and warranty
I can't guarantee anything other than that the included scripts were compiled successfully on my side in A Hat in Time Modding Tools. I also can't guarantee that I will be able to help you with your problems, but I may be able to provide support regarding these and these scripts only.
## Additional contributors
- [Gears for Breakfast](https://www.gearsforbreakfast.com) - A Hat in Time video game and all parent scripts used by this mod and not included in this repository.
- [m_cu8](https://github.com/mcu8) - the first version of Subtitles HUD Element.
## Legal information
Pokémon and Pokémon character names are trademark of Nintendo.
