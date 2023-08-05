class RideablePokemon_Script extends GameMod
	config(Mods);

enum NotifyType
{
	Type_None,
	Type_Select
};

var transient private Array<Hat_GhostPartyPlayerStateBase> RideablePokemonGppStates;
var transient private Hat_MusicNodeBlend_Dynamic FurretMusicTrack;
var transient private Array<Hat_Player> CurrentPlayers;
var config int FurretMusic, OnlineFurretMusic, AllowPokemonScaring, DebugMessages, PokemonSelect, EnableCollision;

static function bool UpdatePokemonSelectNotifyLevelBit() //Returns true if level bit was less than 1 and subtitle message should be displayed.
{
	local int i;
	local Hat_SaveGame_Base sg;
	sg = class'Hat_SaveBitHelper'.static.GetSaveGame();
	if (sg == None)
		return false;
	i = class'Hat_SaveBitHelper_Base'.static.GetLevelBits("pokemonselectnotify", "rideablepokemon", sg);
	if (i < 1)
	{
		class'Hat_SaveBitHelper_Base'.static.SetLevelBits("pokemonselectnotify", 1, "rideablepokemon", sg);
		return true;
	}
	if (i != 1)
		class'Hat_SaveBitHelper_Base'.static.SetLevelBits("pokemonselectnotify", 1, "rideablepokemon", sg);
	return false;
}

static function RemoveModLevelBits()
{
	RemovePokemonSelectNotifyLevelBit();
}

static function bool RemovePokemonSelectNotifyLevelBit() //Returns true if level bit was not equal to 0.
{
	local Hat_SaveGame_Base sg;
	sg = class'Hat_SaveBitHelper'.static.GetSaveGame();
	if (sg == None)
		return false;
	if (class'Hat_SaveBitHelper_Base'.static.GetLevelBits("pokemonselectnotify", "rideablepokemon", sg) != 0)
	{
		class'Hat_SaveBitHelper_Base'.static.SetLevelBits("pokemonselectnotify", 0, "rideablepokemon", sg);
		return true;
	}
	return false;
}

static function bool IsCollisionEnabled()
{
	return (GetConfigValue(default.Class, 'EnableCollision') == 0);
}

static function string GetClassPathName(class<Object> c)
{
	if (c == None)
		return "None";
	if (IsBaseGameClass(c))
		return string(c.Name);
	return PathName(c);
}

static function bool IsBaseGameClass(class<Object> c)
{
	if (c == None)
		return true;
	return IsBaseGameClassPackage(c.GetPackageName());
}

static function bool IsBaseGameClassPackage(Name PackageName)
{
	switch(locs(PackageName))
	{
		case "core":
		case "engine":
		case "gameframework":
		case "hatintimeeditor":
		case "hatintimegame":
		case "hatintimegamecontent":
		case "ipdrv":
		case "onlinesubsystemsteamworks":
		case "unrealed":
		case "windrv":
		default:
			return false;
	}
}

static function string GetPlayerString(Object o, optional bool FirstCapital)
{
	local Hat_Player ply;
	local Hat_GhostPartyPlayer gpp;
	local Hat_GhostPartyPlayerStateBase s;
	local PlayerController pc;
	local string SteamID;
	local int PlayerIndex;
	if (o == None)
		return "None";
	pc = class'Shara_SteamID_Tools_RPS'.static.GetPlayerController(o);
	if (pc != None)
	{
		PlayerIndex = class'Shara_SteamID_Tools_RPS'.static.GetPlayerIndex(pc);
		if (PlayerIndex < 0)
		{
			if (FirstCapital)
				return "Indexless Local Player"@(pc.Pawn == None ? "None" : GetClassPathName(pc.Pawn.Class));
			return "indexless Local Player"@(pc.Pawn == None ? "None" : GetClassPathName(pc.Pawn.Class));
		}
		return "Local Player"@PlayerIndex+1@(pc.Pawn == None ? "None" : GetClassPathName(pc.Pawn.Class));
	}
	ply = class'Shara_SteamID_Tools_RPS'.static.GetPlayerPawn(o);
	if (ply != None)
	{
		if (FirstCapital)
			return "Fake Local Player"@GetClassPathName(ply.Class);
		return "fake Local Player"@GetClassPathName(ply.Class);
	}
	gpp = Hat_GhostPartyPlayer(o);
	if (gpp != None)
	{
		s = gpp.PlayerState;
		if (s == None)
			return "Online Player"@GetClassPathName(gpp.PlayerVisualClass == None ? class'Hat_Player_HatKid' : gpp.PlayerVisualClass)@"without Player State";
		SteamID = s.GetNetworkingIDString();
		if (SteamID == "")
			return "Online Player"@s.SubID+1@GetClassPathName(gpp.PlayerVisualClass == None ? class'Hat_Player_HatKid' : gpp.PlayerVisualClass)@"with destroyed Player State";
		return "Online Player"@s.SubID+1@GetClassPathName(gpp.PlayerVisualClass == None ? class'Hat_Player_HatKid' : gpp.PlayerVisualClass)@"with Steam ID"@SteamID@"("$s.GetDisplayName()$")";
	}
	s = Hat_GhostPartyPlayerStateBase(o);
	if (s == None)
	{
		if (FirstCapital)
			return "Unknown"@GetClassPathName(o.Class);
		return "unknown"@GetClassPathName(o.Class);
	}
	if (SteamID == "")
	{
		if (s.IsLocalPlayer())
		{
			if (FirstCapital)
				return "Destroyed Player State of Local Player"@s.SubID+1;
			return "destroyed Player State of Local Player"@s.SubID+1;
		}
		if (FirstCapital)
			return "Destroyed Player State of Online Player"@s.SubID+1;
		return "destroyed Player State of Online Player"@s.SubID+1;
	}
	if (s.IsLocalPlayer())
	{
		if (FirstCapital)
			return "Player State of Local Player"@s.SubID+1;
		return "Player State of Local Player"@s.SubID+1;
	}
	return "Player State of Online Player"@s.SubID+1@"with Steam ID"@SteamID@"("$s.GetDisplayName()$")";
}

static function SendWarningMessage(string Message, optional Object Sender)
{
	local WorldInfo wi;
	local PlayerController pc;
	if (Message == "")
		return;
	if (GetConfigValue(default.Class, 'DebugMessages') == 0)
		return;
	if (!IsDev())
		return;
	LogMod(Message);
	pc = class'Shara_SteamID_Tools_RPS'.static.GetPlayerController(Sender);
	if (pc != None)
		pc.ClientMessage(Message);
	else
	{
		wi = class'WorldInfo'.static.GetWorldInfo();
		if (wi != None && wi.Game != None)
			wi.Game.Broadcast(wi, Message);
	}
}

static function SendMessageArray(Array<string> StringArray, optional Object Sender)
{
	local int i;
	local string s;
	for (i = 0; i < StringArray.Length; i++)
	{
		s $= StringArray[i];
		if (i != StringArray.Length-1)
			s $= "\n";
	}
	SendWarningMessage(s, Sender);
}

static function RideablePokemon_Script GetModInstance()
{
    local RideablePokemon_Script inst;
	local WorldInfo wi;
	wi = class'WorldInfo'.static.GetWorldInfo();
	if (wi == None)
		return None;
    foreach wi.AllActors(class'RideablePokemon_Script', inst)
	{
        if (inst != None)
			return inst;
	}
    return None;
}

static function bool IsDev()
{
	local string SteamID;
	SteamID = class'Shara_SteamID_Tools_RPS'.static.GetMySteamID();
	if (SteamID == "76561198063502902") //Shararamosh.
		return true;
	return false;
}

static function class<Hat_StatusEffect_RideablePokemon> GetPokemonFromConfig(optional out NotifyType nt)
{
	local int n;
	local Array<class<Hat_StatusEffect_RideablePokemon>> PokemonEffects;
	PokemonEffects = class'RideablePokemon_OnlinePartyHandler'.static.GetStandardPokemonStatusEffects();
	n = Clamp(GetConfigValue(default.Class, 'PokemonSelect'), 0, PokemonEffects.Length); //Gotta make sure we won't end up outside Pokemon list.
	if (UpdatePokemonSelectNotifyLevelBit())
		nt = Type_Select;
	else
		nt = Type_None;
	if (n == 0)
		return None; //Otherwise use Pokemon tied to flair.
	return PokemonEffects[n-1]; //Use Pokedex-sorted list of available Pokemon.
}

function OnPreStatusEffectAdded(Pawn PawnCombat, out class<Object> StatusEffect, optional out float OverrideDuration)
{
	local class<Hat_StatusEffect_RideablePokemon> PokemonStatus, NewPokemonStatus;
	local Hat_PawnCombat p;
	local Hat_Player ply;
	local NotifyType nt;
	local bool IsPredefined;
	PokemonStatus = class<Hat_StatusEffect_RideablePokemon>(StatusEffect);
	if (PokemonStatus == None)
		return;
	p = Hat_PawnCombat(PawnCombat);
	if (p != None)
	{
		p.RemoveStatusEffect(class'Hat_StatusEffect_BadgeScooter', true);
		ply = Hat_Player(p);
	}
	if (ply == None)
	{
		StatusEffect = None;
		return;
	}
	if (!PokemonStatus.static.IsTiedToFlair() && !PokemonStatus.static.IsDebugOnly())
	{
		NewPokemonStatus = GetPokemonFromConfig(nt);
		if (nt == Type_Select)
			ShowSubtitleForPlayer(class'Shara_SteamID_Tools_RPS'.static.GetPawnPlayerController(ply), "RideablePokemon|ConfigNotify|system");
		if (NewPokemonStatus != None && NewPokemonStatus.static.CanRidePokemon(ply, true, false))
		{
			PokemonStatus = NewPokemonStatus;
			IsPredefined = true;
		}
	}
	NewPokemonStatus = PokemonStatus.static.GetRandomAppearance(true, !IsPredefined);
	if (NewPokemonStatus.static.CanRidePokemon(ply, true, false))
		StatusEffect = NewPokemonStatus;
	else
	{
		if (IsPredefined || PokemonStatus.static.CanRidePokemon(ply, true, true))
			StatusEffect = PokemonStatus;
		else
		{
			if (HasNonVanillaScooterBadge(ply))
				StatusEffect = class'Hat_StatusEffect_BadgeScooter';
			else
			{
				StatusEffect = class<Hat_StatusEffect_BadgeScooter>(class'Hat_ClassHelper'.static.GetScriptClass("DyeableScooter.Hat_StatusEffect_DyeableScooter"));
				if (StatusEffect == None)
					StatusEffect = class'Hat_StatusEffect_BadgeScooter';
			}
		}
	}
}

static function bool HasNonVanillaScooterBadge(Hat_Player ply)
{
	local int i;
	local Hat_InventoryManager im;
	local Hat_Badge_Scooter ScooterBadge;
	if (ply == None)
		return false;
	im = Hat_InventoryManager(ply.InvManager);
	if (im == None)
		return false;
	for (i = 0; i < im.Badges.Length; i++)
	{
		ScooterBadge = Hat_Badge_Scooter(im.Badges[i]);
		if (ScooterBadge == None)
			continue;
		if (ScooterBadge.Class == class'Hat_Badge_Scooter' || ScooterBadge.Class == class'Hat_Badge_Scooter_Subcon')
			continue;
		return true;
	}
	return false;
}

static function RemoveModStatusEffects()
{
	local WorldInfo wi;
	local Hat_Player ply;
	wi = class'WorldInfo'.static.GetWorldInfo();
	if (wi == None)
		return;
	foreach wi.AllPawns(class'Hat_Player', ply)
	{
		if (ply != None)
			ply.RemoveStatusEffect(class'Hat_StatusEffect_RideablePokemon', true);
	}
}

static function RemoveModActors()
{
	local int i;
	local WorldInfo wi;
	local Hat_RideablePokemon_Collision CollisionActor;
	local Array<Hat_RideablePokemon_Collision> RemoveList;
	wi = class'WorldInfo'.static.GetWorldInfo();
	if (wi == None)
		return;
	foreach wi.AllActors(class'Hat_RideablePokemon_Collision', CollisionActor)
	{
		if (CollisionActor != None)
			RemoveList.AddItem(CollisionActor);
	}
	for (i = 0; i < RemoveList.Length; i++)
	{
		if (RemoveList[i] == None)
			continue;
		if (!RemoveList[i].Destroy())
			RemoveList[i].ShutDown();
	}
	RemoveList.Length = 0;
}

static function RemoveModItems()
{
	local Array<class<Object>> ModItems;
	local Array<bool> BoolArray;
	ModItems.AddItem(class'Hat_CosmeticItemQualityInfo_Sprint_SafariHat');
	ModItems.AddItem(class'Hat_CosmeticItemQualityInfo_Sprint_Substitute');
	ModItems.AddItem(class'Hat_CosmeticItemQualityInfo_Sprint_TrapperHat');
	ModItems.AddItem(class'Hat_CosmeticItemQualityInfo_Sprint_DawnHat');
	ModItems.AddItem(class'Hat_CosmeticItemQualityInfo_Sprint_WoolKnit');
	ModItems.AddItem(class'Hat_CosmeticItemQualityInfo_Sprint_GlaceonCap');
	ModItems.AddItem(class'Hat_CosmeticItemQualityInfo_Sprint_OverallsCap');
	ModItems.AddItem(class'Hat_CosmeticItemQualityInfo_Sprint_SummerHat');
	ModItems.AddItem(class'Hat_CosmeticItemQualityInfo_Sprint_LeafeonCap');
	BoolArray.Length = ModItems.Length;
	HandleAllLoadoutItemClasses(ModItems, BoolArray);
}

static function HandleAllLoadoutItemClasses(Array<class<Object>> ItemClasses, Array<bool> DoGive, optional Array<bool> DoEquip)
{
	local WorldInfo wi;
	local Hat_PlayerController hpc;
	if (ItemClasses.Length < 1)
		return;
	wi = class'WorldInfo'.static.GetWorldInfo();
	if (wi == None)
		return;
	foreach wi.AllControllers(class'Hat_PlayerController', hpc)
	{
		if (hpc == None)
			continue;
		HandleLoadoutItemClasses(hpc.GetLoadout(), ItemClasses, DoGive, DoEquip);
	}
}

static function HandleLoadoutItemClasses(Hat_Loadout l, Array<class<Object>> ItemClasses, Array<bool> DoGive, optional Array<bool> DoEquip)
{
	local int i;
	local class<Actor> MainItem;
	local class<Hat_CosmeticItemQualityInfo> FlairClass;
	if (ItemClasses.Length < 1)
		return;
	if (l == None)
		return;
	DoGive.Length = ItemClasses.Length;
	DoEquip.Length = ItemClasses.Length;
	for (i = 0; i < ItemClasses.Length; i++)
	{
		if (ItemClasses[i] == None)
			continue;
		FlairClass = class<Hat_CosmeticItemQualityInfo>(ItemClasses[i]);
		if (FlairClass != None)
			MainItem = FlairClass.static.GetBaseCosmeticItemWeApplyTo();
		else
			MainItem = class<Actor>(ItemClasses[i]);
		if (MainItem == None)
			continue;
		HandleLoadoutActorItem(l, MainItem, FlairClass, DoGive[i], DoEquip[i]);
	}
}

static function bool HandleLoadoutActorItem(Hat_Loadout l, class<Actor> ActorClass, class<Hat_CosmeticItemQualityInfo> FlairClass, bool DoGive, optional bool DoEquip)
{
	local Hat_LoadoutBackpackItem LoadoutItem;
	if (l == None)
		return false;
	if (ActorClass == None || ClassIsDeprecated(ActorClass)) //No item?
		return false;
	if (FlairClass != None && ClassIsDeprecated(FlairClass)) //Abstract or deprecated Flair? Uh, that's definitely an error.
		return false;
	LoadoutItem = l.MakeLoadoutItem(ActorClass, FlairClass, l.SaveGame);
	if (LoadoutItem == None)
		return false;
	if (!DoGive)
		return l.RemoveBackpack(LoadoutItem);
	if (LoadoutItem.ItemQualityInfo == None) //Item has no Flair at all, so we just give it to Player.
		return l.AddBackpack(LoadoutItem, DoEquip);
	if (l.BackpackHasInventory(class<Actor>(LoadoutItem.BackpackClass), false, LoadoutItem.ItemQualityInfo != None ? class<Hat_CosmeticItemQualityInfo>(LoadoutItem.ItemQualityInfo.default.CosmeticItemWeApplyTo) : None)) //Player has a base Class for an Item (e.g. Hat_Ability_Help with no Flair, Hat_Ability_StatueFall with no Flair, etc.) or CosmeticItemWeApplyTo Flair.
		return l.AddBackpack(LoadoutItem, DoEquip);
	return l.RemoveBackpack(LoadoutItem);
}

event OnModLoaded()
{
	HookActorSpawn(class'Hat_GhostPartyPlayerStateBase', 'Hat_GhostPartyPlayerStateBase');
	HookActorSpawn(class'Hat_Player', 'Hat_Player');
}

event OnModUnloaded()
{
	RemoveModStatusEffects();
	RemoveFurretMusic();
	RemoveModItems();
	RemoveModActors();
	RemoveModLevelBits();
}

event OnHookedActorSpawn(Object NewActor, Name Identifier)
{
	local Hat_Player ply;
	switch(Identifier)
	{
		case 'Hat_GhostPartyPlayerStateBase':
			class'RideablePokemon_OnlinePartyHandler'.static.HandleHookedOnlinePlayerState(Hat_GhostPartyPlayerStateBase(NewActor), self);
			break;
		case 'Hat_Player':
			ply = Hat_Player(NewActor);
			if (ply != None && CurrentPlayers.Find(ply) == INDEX_NONE)
				CurrentPlayers.AddItem(ply);
			break;
		default:
			break;
	}
}

event OnOnlinePartyCommand(string Command, Name CommandChannel, Hat_GhostPartyPlayerStateBase Sender)
{
	class'RideablePokemon_OnlinePartyHandler'.static.HandleOnlinePartyCommand(Command, CommandChannel, Sender, self);
}

simulated function float GetFurretMusicListeningRadius()
{
	switch(OnlineFurretMusic)
	{
		case 0:
			return 400.0;
		case 1:
			return 600.0;
		case 2:
			return 800.0;
		default:
			return 0.0;
	}
}

simulated event Tick(float DeltaTime)
{
	local bool ShouldLocalMusicBeDisabled, ShouldOnlineMusicBeDisabled;
	if (WorldInfo != None && WorldInfo.Pauser != None) //Game is paused.
	{
		CleanUpLocalPlayers(true);
		CleanUpOnlinePlayers(true);
		return;
	}
	ShouldLocalMusicBeDisabled = CleanUpLocalPlayers(false);
	ShouldOnlineMusicBeDisabled = CleanUpOnlinePlayers(false);
	if (ShouldLocalMusicBeDisabled && ShouldOnlineMusicBeDisabled)
		StopFurretMusic();
	else
		StartFurretMusic();
}

simulated function bool CleanUpLocalPlayers(bool IsGamePaused)
{
	local int i;
	local bool ShouldLocalMusicBeDisabled;
	ShouldLocalMusicBeDisabled = true;
	for (i = CurrentPlayers.Length-1; i > -1; i--)
	{
		if (CurrentPlayers[i] == None)
		{
			CurrentPlayers.Remove(i, 1);
			continue;
		}
		if (IsGamePaused)
			continue;
		if (!ShouldLocalMusicBeDisabled)
			continue;
		if (class'Shara_SteamID_Tools_RPS'.static.GetPawnPlayerController(CurrentPlayers[i]) == None)
			continue;
		if (Hat_StatusEffect_RideableFurret(CurrentPlayers[i].GetStatusEffect(class'Hat_StatusEffect_RideableFurret', false)) == None)
			continue;
		if (class'Hat_StatusEffect_RideablePokemon'.static.AllowLocalPlayerSpeedDustParticle(CurrentPlayers[i]))
			ShouldLocalMusicBeDisabled = false;
	}
	if (FurretMusic == 1)
		return true;
	return ShouldLocalMusicBeDisabled;
}

simulated function bool CleanUpOnlinePlayers(bool IsGamePaused)
{
	local int i, j;
	local float f;
	local bool ShouldOnlineMusicBeDisabled;
	local Hat_GhostPartyPlayer gpp;
	ShouldOnlineMusicBeDisabled = true;
	f = GetFurretMusicListeningRadius();
	for (i = RideablePokemonGppStates.Length-1; i > -1; i--)
	{
		if (RideablePokemonGppStates[i] == None)
		{
			RideablePokemonGppStates.Remove(i, 1);
			continue;
		}
		if (IsGamePaused)
			continue;
		if (!ShouldOnlineMusicBeDisabled || f <= 0.0)
			continue;
		if (!RideablePokemonGppStates[i].UnreliableState.IsOnScooter)
			continue;
		gpp = Hat_GhostPartyPlayer(RideablePokemonGppStates[i].GhostActor);
		if (gpp == None)
			continue;
		if (gpp.ScooterMesh == None)
			continue;
		if (gpp.ScooterMesh.SkeletalMesh != class'Hat_StatusEffect_RideableFurret'.default.ScooterMesh)
			continue;
		if (!class'Hat_StatusEffect_RideablePokemon'.static.AllowOnlinePlayerSpeedDustParticle(gpp))
			continue;
		for (j = 0; j < CurrentPlayers.Length; j++)
		{
			if (CurrentPlayers[j] == None)
				continue;
			if (VSizeSq(CurrentPlayers[j].Location-gpp.Location) > f*f)
				continue;
			if (class'Shara_SteamID_Tools_RPS'.static.GetPawnPlayerController(CurrentPlayers[j]) == None)
				continue;
			ShouldOnlineMusicBeDisabled = false;
		}
	}
	if (f <= 0.0)
		return true;
	return ShouldOnlineMusicBeDisabled;
}

static function Hat_MusicNodeBlend_Dynamic CreateAndPushDynamicMusicNode(SoundCue c, int BPM, int Priority, float BlendInTime, float BlendOutTime)
{
	local Hat_MusicNodeBlend_Dynamic DynamicMusicNode;
	if (c == None)
		return None;
	DynamicMusicNode = new class'Hat_MusicNodeBlend_Dynamic';
	if (DynamicMusicNode == None)
		return None;
	DynamicMusicNode.BlendTimes[0] = Abs(BlendInTime);
	DynamicMusicNode.BlendTimes[1] = Abs(BlendOutTime);
	DynamicMusicNode.Music = c;
	DynamicMusicNode.BPM = Abs(BPM);
	DynamicMusicNode.Priority = Priority;
	`PushMusicNode(DynamicMusicNode);
	return DynamicMusicNode;
}

simulated function StartFurretMusic()
{
	if (FurretMusicTrack == None)
		FurretMusicTrack = CreateAndPushDynamicMusicNode(SoundCue'RideableFurret_Package.Music.Accumula_Town', 123, 800, RandRange(0.5, 1.2), RandRange(0.5, 2.4));
	else if (FurretMusicTrack.GetActiveChildIndex() != 1)
		FurretMusicTrack.SetActiveChildIndex(1);
}

simulated function StopFurretMusic()
{
	if (FurretMusicTrack != None && FurretMusicTrack.GetActiveChildIndex() != 0)
		FurretMusicTrack.SetActiveChildIndex(0);
}

simulated function RemoveFurretMusic()
{
	if (FurretMusicTrack != None)
	{
		FurretMusicTrack.Stop();
		FurretMusicTrack = None;
	}
}

simulated function AddGppState(Hat_GhostPartyPlayerStateBase PlayerState)
{
	if (PlayerState == None)
		return;
	if (RideablePokemonGppStates.Find(PlayerState) == INDEX_NONE)
		RideablePokemonGppStates.AddItem(PlayerState);
}

simulated function RemoveGppState(Hat_GhostPartyPlayerStateBase PlayerState)
{
	if (PlayerState == None)
		return;
	RideablePokemonGppStates.RemoveItem(PlayerState);
}

static function ShowSubtitleForPlayer(PlayerController pc, optional string msg, optional byte r = 255, optional byte g = 255, optional byte b = 255, optional float closeAfter = 5.0, optional Array<string> Keywords, optional Array<string> LocalizationPaths)
{
	local Hat_HUD H;
	local mcu8_HUDElementSubtitles_RPS SubtitlesHUD;
	if (pc == None)
		return;
	H = Hat_HUD(pc.myHUD);
	if (H == None)
		return;
	SubtitlesHUD = mcu8_HUDElementSubtitles_RPS(H.OpenHUD(class'mcu8_HUDElementSubtitles_RPS', ""$r$"|"$g$"|"$b$"|"$msg));
	if (SubtitlesHUD != None)
		SubtitlesHUD.SetKeywordReplacements(Keywords, LocalizationPaths);
	if (closeAfter <= 0.0)
		closeAfter = 5.0;
	H.SetTimer(closeAfter, false, NameOf(CloseSubtitlesForHUD), GetModInstance(), H);
}

static function CloseSubtitlesForHUD(Hat_HUD H)
{
	if (H == None)
		return;
	H.ClearTimer(NameOf(CloseSubtitlesForHUD));
	H.CloseHUD(class'mcu8_HUDElementSubtitles_RPS');
}

defaultproperties
{
	bAlwaysTick = true
}