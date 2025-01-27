class RideablePokemon_Script extends GameMod
	config(Mods);

enum LoadoutItem_State
{
	State_Remove,
	State_Add,
	State_Equip
};

struct LoadoutItem
{
	var class<Object> ItemClass;
	var LoadoutItem_State ItemState;
};

var transient private Array<Hat_GhostPartyPlayerStateBase> RideablePokemonGppStates;
var transient private Hat_MusicNodeBlend_Dynamic FurretMusicTrack;
var transient private Array<Hat_Player> CurrentPlayers;
var config int FurretMusic, OnlineFurretMusic, AllowPokemonScaring, PokemonSelect, EnableCollision, AllowTimedEventSkins;

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
	return (GetConfigValue(default.Class, NameOf(default.EnableCollision)) < 1);
}

static function bool IsPokemonScaringAllowed()
{
	return (GetConfigValue(default.Class, NameOf(default.AllowPokemonScaring)) < 1);
}

static function bool AreTimedEventSkinsAllowed()
{
	return (GetConfigValue(default.Class, NameOf(default.AllowTimedEventSkins)) < 1);
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

static function RideablePokemon_Script GetModInstance()
{
	local WorldInfo wi;
	local RideablePokemon_Script inst;
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

static function class<Hat_StatusEffect_RideablePokemon> GetPokemonFromConfig()
{
	local int n;
	local Array<class<Hat_StatusEffect_RideablePokemon>> PokemonEffects;
	PokemonEffects = class'RideablePokemon_OnlinePartyHandler'.static.GetStandardPokemonStatusEffects();
	n = Clamp(GetConfigValue(default.Class, NameOf(default.PokemonSelect)), 0, PokemonEffects.Length); //Gotta make sure we won't end up outside Pokemon list.
	if (n == 0)
		return None; //Otherwise use Pokemon tied to flair.
	return PokemonEffects[n-1]; //Use Pokedex-sorted list of available Pokemon.
}

function OnPreStatusEffectAdded(Pawn PawnCombat, out class<Object> StatusEffect, optional out float OverrideDuration)
{
	local Hat_Player ply;
	local Hat_PawnCombat p;
	local bool IsPredefined;
	local class<Hat_StatusEffect_RideablePokemon> PokemonStatus, NewPokemonStatus;
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
		NewPokemonStatus = GetPokemonFromConfig();
		if (UpdatePokemonSelectNotifyLevelBit() && NewPokemonStatus == None)
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
	local Array<LoadoutItem> ModItems;
	ModItems.AddItem(MakeLoadoutItem(class'Hat_CosmeticItemQualityInfo_Sprint_SafariHat', State_Remove));
	ModItems.AddItem(MakeLoadoutItem(class'Hat_CosmeticItemQualityInfo_Sprint_Substitute', State_Remove));
	ModItems.AddItem(MakeLoadoutItem(class'Hat_CosmeticItemQualityInfo_Sprint_TrapperHat', State_Remove));
	ModItems.AddItem(MakeLoadoutItem(class'Hat_CosmeticItemQualityInfo_Sprint_DawnHat', State_Remove));
	ModItems.AddItem(MakeLoadoutItem(class'Hat_CosmeticItemQualityInfo_Sprint_WoolKnit', State_Remove));
	ModItems.AddItem(MakeLoadoutItem(class'Hat_CosmeticItemQualityInfo_Sprint_GlaceonCap', State_Remove));
	ModItems.AddItem(MakeLoadoutItem(class'Hat_CosmeticItemQualityInfo_Sprint_OverallsCap', State_Remove));
	ModItems.AddItem(MakeLoadoutItem(class'Hat_CosmeticItemQualityInfo_Sprint_SummerHat', State_Remove));
	ModItems.AddItem(MakeLoadoutItem(class'Hat_CosmeticItemQualityInfo_Sprint_LeafeonCap', State_Remove));
	ModItems.AddItem(MakeLoadoutItem(class'Hat_CosmeticItemQualityInfo_Sprint_RibbonBoater', State_Remove));
	ModItems.AddItem(MakeLoadoutItem(class'Hat_CosmeticItemQualityInfo_Sprint_SpringHat', State_Remove));
	ModItems.AddItem(MakeLoadoutItem(class'Hat_CosmeticItemQualityInfo_Sprint_SylveonCap', State_Remove));
	HandleAllLoadoutItems(ModItems);
}

static function LoadoutItem MakeLoadoutItem(class<Object> ObjectClass, LoadoutItem_State lis)
{
	local LoadoutItem li;
	li.ItemClass = ObjectClass;
	li.ItemState = lis;
	return li;
}

static function HandleAllLoadoutItems(Array<LoadoutItem> LoadoutItems)
{
	local WorldInfo wi;
	local Hat_PlayerController hpc;
	if (LoadoutItems.Length < 1)
		return;
	wi = class'WorldInfo'.static.GetWorldInfo();
	if (wi == None)
		return;
	foreach wi.AllControllers(class'Hat_PlayerController', hpc)
	{
		if (hpc == None)
			continue;
		HandleLoadoutItems(hpc.GetLoadout(), LoadoutItems);
	}
}

static function HandleLoadoutItems(Hat_Loadout l, Array<LoadoutItem> LoadoutItems)
{
	local int i;
	local class<Actor> MainItem;
	local class<Hat_CosmeticItemQualityInfo> FlairClass;
	if (LoadoutItems.Length < 1)
		return;
	if (l == None)
		return;
	for (i = 0; i < LoadoutItems.Length; i++)
	{
		if (LoadoutItems[i].ItemClass == None)
			continue;
		FlairClass = class<Hat_CosmeticItemQualityInfo>(LoadoutItems[i].ItemClass);
		if (FlairClass != None)
			MainItem = FlairClass.static.GetBaseCosmeticItemWeApplyTo();
		else
			MainItem = class<Actor>(LoadoutItems[i].ItemClass);
		HandleLoadoutActorItem(l, MainItem, FlairClass, LoadoutItems[i].ItemState);
	}
}

static function bool HandleLoadoutActorItem(Hat_Loadout l, class<Actor> ActorClass, class<Hat_CosmeticItemQualityInfo> FlairClass, LoadoutItem_State lis)
{
	local Hat_LoadoutBackpackItem lbi;
	if (l == None)
		return false;
	if (ActorClass == None || ClassIsDeprecated(ActorClass)) //No item?
		return false;
	if (FlairClass != None && ClassIsDeprecated(FlairClass)) //Abstract or deprecated Flair? Uh, that's definitely an error.
		return false;
	lbi = l.MakeLoadoutItem(ActorClass, FlairClass, l.SaveGame);
	if (lbi == None)
		return false;
	if (lis < State_Add)
		return l.RemoveBackpack(lbi);
	if (lbi.ItemQualityInfo == None) //Item has no Flair at all, so we just give it to Player.
		return l.AddBackpack(lbi, lis > State_Add);
	if (l.BackpackHasInventory(class<Actor>(lbi.BackpackClass), false, lbi.ItemQualityInfo != None ? class<Hat_CosmeticItemQualityInfo>(lbi.ItemQualityInfo.default.CosmeticItemWeApplyTo) : None)) //Player has a base Class for an Item (e.g. Hat_Ability_Help with no Flair, Hat_Ability_StatueFall with no Flair, etc.) or CosmeticItemWeApplyTo Flair.
		return l.AddBackpack(lbi, lis > State_Add);
	return l.RemoveBackpack(lbi);
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
	ClearGppStates();
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
			if (ply != None && CurrentPlayers.Find(ply) < 0)
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

simulated function bool CleanUpLocalPlayers(bool IsGamePaused) //Returns true if Furret Music should be disabled.
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
		if (!CurrentPlayers[i].HasStatusEffect(class'Hat_StatusEffect_RideableFurret', false))
			continue;
		if (class'Hat_StatusEffect_RideablePokemon'.static.AllowSpeedDustParticle(CurrentPlayers[i].Velocity, CurrentPlayers[i].GroundSpeed, true, CurrentPlayers[i].VehicleProperties.Throttle))
			ShouldLocalMusicBeDisabled = false;
	}
	if (FurretMusic > 0)
		return true;
	return ShouldLocalMusicBeDisabled;
}

simulated function bool CleanUpOnlinePlayers(bool IsGamePaused) //Returns true if Furret Music should be disabled.
{
	local float f;
	local int i, j;
	local Hat_GhostPartyPlayer gpp;
	local bool ShouldOnlineMusicBeDisabled;
	local class<Hat_StatusEffect_RideablePokemon> PokemonEffect;
	ShouldOnlineMusicBeDisabled = true;
	f = GetFurretMusicListeningRadius();
	for (i = RideablePokemonGppStates.Length-1; i > -1; i--)
	{
		if (RideablePokemonGppStates[i] == None)
		{
			RideablePokemonGppStates.Remove(i, 1);
			continue;
		}
		gpp = Hat_GhostPartyPlayer(RideablePokemonGppStates[i].GhostActor);
		if (gpp == None)
			continue;
		PokemonEffect = class'RideablePokemon_OnlinePartyHandler'.static.GetPokemonStatusEffectByMesh(gpp.ScooterMesh);
		if (PokemonEffect == None)
			continue;
		ApplyOnlinePlayerScooterParticles(gpp, PokemonEffect);
		ApplyOnlinePlayerScooterSounds(gpp, PokemonEffect);
		if (IsGamePaused)
			continue;
		if (!ShouldOnlineMusicBeDisabled || f <= 0.0)
			continue;
		if (PokemonEffect != class'Hat_StatusEffect_RideableFurret')
			continue;
		if (!class'Hat_StatusEffect_RideablePokemon'.static.AllowSpeedDustParticle(gpp.Velocity, gpp.PlayerVisualClass != None ? gpp.PlayerVisualClass.default.GroundSpeed : class'Hat_Player_HatKid'.default.GroundSpeed))
			continue;
		for (j = 0; j < CurrentPlayers.Length; j++)
		{
			if (CurrentPlayers[j] == None)
				continue;
			if (VSizeSq(CurrentPlayers[j].Location-gpp.Location) > Square(f))
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
	if (RideablePokemonGppStates.Find(PlayerState) < 0)
		RideablePokemonGppStates.AddItem(PlayerState);
}

simulated function RemoveGppState(Hat_GhostPartyPlayerStateBase PlayerState)
{
	local Hat_GhostPartyPlayer gpp;
	local class<Hat_StatusEffect_RideablePokemon> PokemonEffect;
	if (PlayerState == None)
		return;
	RideablePokemonGppStates.RemoveItem(PlayerState);
	gpp = Hat_GhostPartyPlayer(PlayerState.GhostActor);
	if (gpp == None)
		return;
	PokemonEffect = class'RideablePokemon_OnlinePartyHandler'.static.GetPokemonStatusEffectByMesh(gpp.ScooterMesh);
	RestoreScooterMesh(gpp.ScooterMesh, PlayerState.UnreliableState.ScooterIsSubcon);
	RestoreOnlinePlayerScooterParticles(gpp, PokemonEffect, PlayerState.UnreliableState.IsOnScooter, PlayerState.UnreliableState.ScooterIsSubcon);
	RestoreOnlinePlayerScooterSounds(gpp, PokemonEffect, PlayerState.UnreliableState.IsOnScooter, PlayerState.UnreliableState.ScooterIsSubcon);
}

simulated function ClearGppStates()
{
	local int i;
	local Hat_GhostPartyPlayer gpp;
	local class<Hat_StatusEffect_RideablePokemon> PokemonEffect;
	for (i = 0; i < RideablePokemonGppStates.Length; i++)
	{
		if (RideablePokemonGppStates[i] == None)
			continue;
		gpp = Hat_GhostPartyPlayer(RideablePokemonGppStates[i].GhostActor);
		if (gpp == None)
			continue;
		PokemonEffect = class'RideablePokemon_OnlinePartyHandler'.static.GetPokemonStatusEffectByMesh(gpp.ScooterMesh);
		RestoreScooterMesh(gpp.ScooterMesh, RideablePokemonGppStates[i].UnreliableState.ScooterIsSubcon);
		RestoreOnlinePlayerScooterParticles(gpp, PokemonEffect, RideablePokemonGppStates[i].UnreliableState.IsOnScooter, RideablePokemonGppStates[i].UnreliableState.ScooterIsSubcon);
		RestoreOnlinePlayerScooterSounds(gpp, PokemonEffect, RideablePokemonGppStates[i].UnreliableState.IsOnScooter, RideablePokemonGppStates[i].UnreliableState.ScooterIsSubcon);
	}
	RideablePokemonGppStates.Length = 0;
}

static function RestoreScooterMesh(SkeletalMeshComponent comp, bool ScooterIsSubcon)
{
	local class<Hat_StatusEffect_BadgeScooter> ScooterClass;
	if (!class'RideablePokemon_OnlinePartyHandler'.static.IsPokemonMesh(comp))
		return;
	ScooterClass = (ScooterIsSubcon ? class'Hat_StatusEffect_BadgeScooter_Subcon' : class'Hat_StatusEffect_BadgeScooter');
	comp.SetSkeletalMesh(ScooterClass.default.ScooterMesh);
	comp.SetSectionGroup('');
	comp.SetPhysicsAsset(ScooterClass.default.ScooterPhysics);
	comp.SetHasPhysicsAssetInstance(ScooterClass.default.ScooterPhysicsAssetInstance);
	if (comp.AnimSets.Length != 0)
	{
		comp.AnimSets.Length = 0;
		comp.UpdateAnimations();
	}
	if (comp.MorphSets.Length != 0)
	{
		comp.MorphSets.Length = 0;
		comp.InitMorphTargets();
	}
	if (comp.AnimTreeTemplate != ScooterClass.default.ScooterAnimTree)
		comp.SetAnimTreeTemplate(ScooterClass.default.ScooterAnimTree);
	class'Shara_SkinColors_Tools_Short_RPS'.static.ResetMaterials(comp, true);
}

static function ApplyOnlinePlayerScooterSounds(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_BadgeScooter> ScooterClass)
{
	if (gpp == None)
		return;
	if (ScooterClass == None || ScooterClass.default.EngineSound == None)
	{
		if (gpp.ScooterEngineSound != None)
		{
			gpp.ScooterEngineSound.Stop();
			gpp.ScooterEngineSound.DetachFromAny();
			gpp.ScooterEngineSound = None;
		}
	}
	else
	{
		if (gpp.ScooterEngineSound.ObjectArchetype != ScooterClass.default.EngineSound)
		{
			gpp.ScooterEngineSound.Stop();
			gpp.ScooterEngineSound.DetachFromAny();
			gpp.ScooterEngineSound = None;
		}
		if (gpp.ScooterEngineSound == None)
		{
			gpp.ScooterEngineSound = new(gpp) ScooterClass.default.EngineSound.Class(ScooterClass.default.EngineSound);
			if (gpp.ScooterEngineSound != None)
				gpp.AttachComponent(gpp.ScooterEngineSound);
		}
	}
	if (ScooterClass == None || ScooterClass.default.EngineDrivingSound == None)
	{
		if (gpp.ScooterDrivingSound != None)
		{
			gpp.ScooterDrivingSound.Stop();
			gpp.ScooterDrivingSound.DetachFromAny();
			gpp.ScooterDrivingSound = None;
		}
	}
	else
	{
		if (gpp.ScooterDrivingSound.ObjectArchetype != ScooterClass.default.EngineDrivingSound)
		{
			gpp.ScooterDrivingSound.Stop();
			gpp.ScooterDrivingSound.DetachFromAny();
			gpp.ScooterDrivingSound = None;
		}
		if (gpp.ScooterDrivingSound == None)
		{
			gpp.ScooterDrivingSound = new(gpp) ScooterClass.default.EngineDrivingSound.Class(ScooterClass.default.EngineDrivingSound);
			if (gpp.ScooterDrivingSound != None)
				gpp.AttachComponent(gpp.ScooterDrivingSound);
		}
	}
}

static function ApplyOnlinePlayerScooterParticles(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_BadgeScooter> ScooterClass)
{
	local class<Hat_Player> PlayerClass;
	if (gpp == None)
		return;
	PlayerClass = gpp.PlayerVisualClass;
	if (PlayerClass == None)
		PlayerClass = class'Hat_Player_HatKid';
	if (PlayerClass.default.SprintParticle == None)
	{
		if (gpp.SprintParticle != None)
			gpp.SprintParticle.SetActive(false);
		return;
	}
	if (gpp.SprintParticle == None || gpp.SprintParticle.ObjectArchetype != PlayerClass.default.SprintParticle)
	{
		if (gpp.SprintParticle != None)
		{
			gpp.SprintParticle.SetActive(false);
			gpp.SprintParticle.DetachFromAny();
		}
		gpp.SprintParticle = new(gpp) class'ParticleSystemComponent'(PlayerClass.default.SprintParticle);
		if (gpp.SprintParticle != None)
			gpp.AttachComponent(gpp.SprintParticle);
	}
	if (gpp.SprintParticle == None)
		return;
	if (ScooterClass == None)
	{
		if (gpp.SprintParticle.Template != PlayerClass.default.SprintParticle.Template)
			gpp.SprintParticle.SetTemplate(PlayerClass.default.SprintParticle.Template);
	}
	else if (gpp.SprintParticle.Template != ScooterClass.default.SpeedDustParticle)
		gpp.SprintParticle.SetTemplate(ScooterClass.default.SpeedDustParticle);
}

static function RestoreOnlinePlayerScooterSounds(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_BadgeScooter> CurrentScooterClass, bool IsOnScooter, bool ScooterIsSubcon)
{
	local class<Hat_StatusEffect_BadgeScooter> ScooterClass;
	if (gpp == None || CurrentScooterClass == None)
		return;
	ScooterClass = (ScooterIsSubcon ? class'Hat_StatusEffect_BadgeScooter_Subcon' : class'Hat_StatusEffect_BadgeScooter');
	if (CurrentScooterClass.default.EngineSound != None)
	{
		if (gpp.ScooterEngineSound != None && gpp.ScooterEngineSound.ObjectArchetype == CurrentScooterClass.default.EngineSound)
		{
			if (!IsOnScooter || ScooterClass.default.EngineSound == None)
			{
				gpp.ScooterEngineSound.Stop();
				gpp.ScooterEngineSound.DetachFromAny();
				gpp.ScooterEngineSound = None;
			}
			else if (CurrentScooterClass.default.EngineSound != ScooterClass.default.EngineSound)
			{
				gpp.ScooterEngineSound.Stop();
				gpp.ScooterEngineSound.DetachFromAny();
				gpp.ScooterEngineSound = new(gpp) ScooterClass.default.EngineSound.Class(ScooterClass.default.EngineSound);
				if (gpp.ScooterEngineSound != None)
					gpp.AttachComponent(gpp.ScooterEngineSound);
			}
		}
	}
	else if (gpp.ScooterEngineSound == None || gpp.ScooterEngineSound.ObjectArchetype == None)
	{
		if (gpp.ScooterEngineSound != None)
		{
			gpp.ScooterEngineSound.Stop();
			gpp.ScooterEngineSound.DetachFromAny();
		}
		if (!IsOnScooter || ScooterClass.default.EngineSound == None)
			gpp.ScooterEngineSound = None;
		else
		{
			gpp.ScooterEngineSound = new(gpp) ScooterClass.default.EngineSound.Class(ScooterClass.default.EngineSound);
			if (gpp.ScooterEngineSound != None)
				gpp.AttachComponent(gpp.ScooterEngineSound);
		}
	}
	if (CurrentScooterClass.default.EngineDrivingSound != None)
	{
		if (gpp.ScooterDrivingSound != None && gpp.ScooterDrivingSound.ObjectArchetype == CurrentScooterClass.default.EngineDrivingSound)
		{
			if (!IsOnScooter || ScooterClass.default.EngineDrivingSound == None)
			{
				gpp.ScooterDrivingSound.Stop();
				gpp.ScooterDrivingSound.DetachFromAny();
				gpp.ScooterDrivingSound = None;
			}
			else if (CurrentScooterClass.default.EngineDrivingSound != ScooterClass.default.EngineDrivingSound)
			{
				gpp.ScooterDrivingSound.Stop();
				gpp.ScooterDrivingSound.DetachFromAny();
				gpp.ScooterDrivingSound = new(gpp) ScooterClass.default.EngineDrivingSound.Class(ScooterClass.default.EngineDrivingSound);
				if (gpp.ScooterDrivingSound != None)
					gpp.AttachComponent(gpp.ScooterDrivingSound);
			}
		}
	}
	else if (gpp.ScooterDrivingSound == None || gpp.ScooterDrivingSound.ObjectArchetype == None)
	{
		if (gpp.ScooterDrivingSound != None)
		{
			gpp.ScooterDrivingSound.Stop();
			gpp.ScooterDrivingSound.DetachFromAny();
		}
		if (!IsOnScooter || ScooterClass.default.EngineDrivingSound == None)
			gpp.ScooterDrivingSound = None;
		else
		{
			gpp.ScooterDrivingSound = new(gpp) ScooterClass.default.EngineDrivingSound.Class(ScooterClass.default.EngineDrivingSound);
			if (gpp.ScooterDrivingSound != None)
				gpp.AttachComponent(gpp.ScooterDrivingSound);
		}
	}
}

static function RestoreOnlinePlayerScooterParticles(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_BadgeScooter> CurrentScooterClass, bool IsOnScooter, bool ScooterIsSubcon)
{
	local class<Hat_Player> PlayerClass;
	local class<Hat_StatusEffect_BadgeScooter> ScooterClass;
	if (gpp == None || CurrentScooterClass == None)
		return;
	PlayerClass = gpp.PlayerVisualClass;
	if (PlayerClass == None)
		PlayerClass = class'Hat_Player_HatKid';
	if (PlayerClass.default.SprintParticle == None)
	{
		if (gpp.SprintParticle != None)
			gpp.SprintParticle.SetActive(false);
		return;
	}
	if (gpp.SprintParticle == None || gpp.SprintParticle.ObjectArchetype != PlayerClass.default.SprintParticle)
	{
		if (gpp.SprintParticle != None)
		{
			gpp.SprintParticle.SetActive(false);
			gpp.SprintParticle.DetachFromAny();
		}
		gpp.SprintParticle = new(gpp) class'ParticleSystemComponent'(PlayerClass.default.SprintParticle);
		if (gpp.SprintParticle != None)
			gpp.AttachComponent(gpp.SprintParticle);
	}
	if (gpp.SprintParticle == None || gpp.SprintParticle.Template != CurrentScooterClass.default.SpeedDustParticle)
		return;
	if (IsOnScooter)
	{
		ScooterClass = (ScooterIsSubcon ? class'Hat_StatusEffect_BadgeScooter_Subcon' : class'Hat_StatusEffect_BadgeScooter');
		if (gpp.SprintParticle.Template != ScooterClass.default.SpeedDustParticle)
			gpp.SprintParticle.SetTemplate(ScooterClass.default.SpeedDustParticle);
	}
	else if (gpp.SprintParticle.Template != PlayerClass.default.SprintParticle.Template)
		gpp.SprintParticle.SetTemplate(PlayerClass.default.SprintParticle.Template);
}

static function bool ShowSubtitleForPlayer(PlayerController pc, optional string msg, optional byte r = 255, optional byte g = 255, optional byte b = 255, optional float closeAfter = 5.0, optional Array<KeywordLocalizationInfo> Keywords)
{
	local Hat_HUD H;
	local Hat_HUDElementSubtitles_Advanced_RPS SubtitlesHUD;
	if (pc == None)
		return false;
	H = Hat_HUD(pc.myHUD);
	if (H == None)
		return false;
	SubtitlesHUD = Hat_HUDElementSubtitles_Advanced_RPS(H.OpenHUD(class'Hat_HUDElementSubtitles_Advanced_RPS', ""$r$"|"$g$"|"$b$"|"$msg));
	if (SubtitlesHUD == None)
		return false;
	SubtitlesHUD.SetKeywordReplacements(Keywords);
	SubtitlesHUD.SetTimeUntilClose(closeAfter);
	return true;
}

defaultproperties
{
	bAlwaysTick = true
}