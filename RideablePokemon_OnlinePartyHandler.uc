class RideablePokemon_OnlinePartyHandler extends Object
	abstract;
/*
	This is the only time I don't remove Online Party Handler script from the mod before uploading it to Workshop. Feel free to do whatever you want with this info. Just don't mess up with online experience.
*/

var private const Name MainChannel;
var const Array<class<Hat_StatusEffect_RideablePokemon>> PokemonEffects; //Available through config menu.
var const Array<class<Hat_StatusEffect_RideablePokemon>> SpecialPokemonEffects; //Available only using special Sprint Hat flairs.

static function SendOnlinePartyCommand(string InCommand, optional Pawn SendingPlayer, optional Hat_GhostPartyPlayerStateBase Receiver, optional out RideablePokemon_Script ModInstance)
{
	if (ModInstance == None)
		ModInstance = class'RideablePokemon_Script'.static.GetModInstance();
	if (ModInstance != None)
		SendOnlinePartyCommandWithModInstance(InCommand, ModInstance, SendingPlayer, Receiver);
}

static function SendOnlinePartyCommandWithModInstance(string Command, RideablePokemon_Script ModInstance, optional Pawn SendingPlayer, optional Hat_GhostPartyPlayerStateBase Receiver)
{
	if (Command == "" || ModInstance == None)
		return;
	ModInstance.SendOnlinePartyCommand(Command, default.MainChannel, SendingPlayer, Receiver);
	class'RideablePokemon_Script'.static.SendWarningMessage("["$default.Class.Name$"/SendOnlinePartyCommandWithModInstance] Sent Online Party Command:"@Command$". Sender:"@class'RideablePokemon_Script'.static.GetPlayerString(SendingPlayer)$". Receiver:"@class'RideablePokemon_Script'.static.GetPlayerString(Receiver)$". TimeSeconds:"@ModInstance.WorldInfo.TimeSeconds$".");
}

static function HandleOnlinePartyCommand(string Command, Name CommandChannel, Hat_GhostPartyPlayerStateBase Sender, RideablePokemon_Script ModInstance)
{
	local class<Hat_StatusEffect_RideablePokemon> ReceivedStatus;
	local string s;
	if (Sender == None || Sender.IsLocalPlayer() || Command == "" || CommandChannel != default.MainChannel || ModInstance == None)
		return;
	class'RideablePokemon_Script'.static.SendWarningMessage("["$default.Class.Name$"/HandleOnlinePartyCommand] Received Online Party Command:"@Command$". Sender:"@class'RideablePokemon_Script'.static.GetPlayerString(Sender)$". TimeSeconds:"@ModInstance.WorldInfo.TimeSeconds$".");
	switch(locs(Command))
	{
		case "pokemonridestartquery":
			CondSendRideablePokemon(ModInstance, Sender);
			break;
		default:
			ReceivedStatus = GetPokemonStatusEffectByCommand(Command, s);
			if (ReceivedStatus != None)
				DoStuffBasedOnString(Mid(Command, Len(s)), Sender, ReceivedStatus, ModInstance);
			break;
	}
}

static function class<Hat_StatusEffect_RideablePokemon> GetPokemonStatusEffectByCommand(string Command, optional out string PokemonName)
{
	local int i;
	local string s;
	for (i = 0; i < default.PokemonEffects.Length; i++)
	{
		s = locs(default.PokemonEffects[i].static.GetLocalName());
		if (Left(locs(Command), Len(s)) == s) //Check if command has Pokemon name at the very beginning.
		{
			PokemonName = s;
			return default.PokemonEffects[i];
		}
	}
	for (i = 0; i < default.SpecialPokemonEffects.Length; i++)
	{
		s = locs(default.SpecialPokemonEffects[i].static.GetLocalName());
		if (Left(locs(Command), Len(s)) == s) //Check if command has Pokemon name at the very beginning.
		{
			PokemonName = s;
			return default.SpecialPokemonEffects[i];
		}
	}
	return None;
}

static function UpdateOnlinePokemonMesh(Hat_GhostPartyPlayerStateBase Sender, class<Hat_StatusEffect_RideablePokemon> PokemonEffect)
{
	local Hat_GhostPartyPlayer gpp;
	if (Sender == None || PokemonEffect == None)
		return;
	gpp = Hat_GhostPartyPlayer(Sender.GhostActor);
	if (gpp == None)
		return;
	if (gpp.ScooterMesh == None)
		gpp.ScooterMesh = PokemonEffect.static.CreateScooterMesh(gpp, gpp.SkeletalMeshComponent);
    else
		PokemonEffect.static.MaintainScooterMesh(gpp, gpp.SkeletalMeshComponent, gpp.ScooterMesh);
	class'Hat_RideablePokemon_Collision'.static.ModifyOnlinePlayer(gpp);
}

static function DetachOnlinePokemonMesh(Hat_GhostPartyPlayerStateBase Sender, class<Hat_StatusEffect_RideablePokemon> PokemonEffect)
{
	local Hat_GhostPartyPlayer gpp;
	local float f;
	local Vector v;
	if (Sender == None || PokemonEffect == None)
		return;
	gpp = Hat_GhostPartyPlayer(Sender.GhostActor);
	if (gpp == None)
		return;
	if (!gpp.PlayerState.UnreliableState.IsOnScooter && gpp.ScooterMesh != None && gpp.ScooterMesh.SkeletalMesh == PokemonEffect.default.ScooterMesh)
	{
		f = gpp.ScooterMesh.Scale;
		v = gpp.ScooterMesh.Scale3D;
		gpp.ScooterMesh.DetachFromAny();
		gpp.ScooterMesh = None;
		RestoreOnlinePlayerMeshValuesFromScooter(gpp, f, v);
	}
	else
		RestoreOnlinePlayerMeshValues(gpp);
}

static function RestoreOnlinePlayerMeshValues(Hat_GhostPartyPlayer gpp)
{
	local class<Hat_Player> PlayerClass;
	if (gpp.SkeletalMeshComponent == None)
		return;
	PlayerClass = gpp.PlayerVisualClass;
	gpp.SkeletalMeshComponent.SetScale((PlayerClass == None || PlayerClass.default.Mesh == None) ? class'Hat_Player_HatKid'.default.Mesh.Scale : PlayerClass.default.Mesh.Scale);
	gpp.SkeletalMeshComponent.SetScale3D((PlayerClass == None || PlayerClass.default.Mesh == None) ? class'Hat_Player_HatKid'.default.Mesh.Scale3D : PlayerClass.default.Mesh.Scale3D);
}

static function RestoreOnlinePlayerMeshValuesFromScooter(Hat_GhostPartyPlayer gpp, float f, Vector v)
{
	if (gpp.SkeletalMeshComponent == None)
		return;
	gpp.SkeletalMeshComponent.SetScale(f);
	gpp.SkeletalMeshComponent.SetScale3D(v);
}

static function SetOnlinePokemonBattleAction(Hat_GhostPartyPlayerStateBase Sender, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, Name AnimName)
{
	local Hat_GhostPartyPlayer gpp;
	local float f;
	if (Sender == None || PokemonEffect == None)
		return;
	gpp = Hat_GhostPartyPlayer(Sender.GhostActor);
	if (gpp == None)
		return;
	if (gpp.ScooterMesh.SkeletalMesh != PokemonEffect.default.ScooterMesh)
		return;
	f = PokemonEffect.static.SetPokemonCustomBattleActionAnimation(gpp.ScooterMesh, AnimName);
	if (f > 0.0)
	{
		PokemonEffect.static.ModifyPokemonFace(gpp.ScooterMesh, true);
		PokemonEffect.static.SetPokemonAttackEmissionEffect(gpp.ScooterMesh, f);
		PokemonEffect.static.PerformOnlinePlayerScooterHonk(gpp);
		if (class'GameMod'.static.GetConfigValue(class'RideablePokemon_Script', 'AllowPokemonScaring') == 0)
			PokemonEffect.static.GhostPartyScareNearbyPlayers(gpp);
	}
	else
		PokemonEffect.static.ModifyPokemonFace(gpp.ScooterMesh, false);
}

static function SetOnlinePokemonHealthNumber(Hat_GhostPartyPlayerStateBase Sender, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, int h)
{
	local Hat_GhostPartyPlayer gpp;
	if (Sender == None || PokemonEffect == None)
		return;
	gpp = Hat_GhostPartyPlayer(Sender.GhostActor);
	if (gpp == None)
		return;
	if (gpp.ScooterMesh.SkeletalMesh == PokemonEffect.default.ScooterMesh)
		PokemonEffect.static.SetPokemonHealthNumber(gpp.ScooterMesh, h);
}

static function SetOnlinePokemonWireframe(Hat_GhostPartyPlayerStateBase Sender, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, bool IsWireframe)
{
	local Hat_GhostPartyPlayer gpp;
	if (Sender == None || PokemonEffect == None)
		return;
	gpp = Hat_GhostPartyPlayer(Sender.GhostActor);
	if (gpp == None)
		return;
	if (gpp.ScooterMesh.SkeletalMesh == PokemonEffect.default.ScooterMesh)
		IsWireframe ? PokemonEffect.static.SetPokemonWireframeMaterials(gpp.ScooterMesh) : PokemonEffect.static.SetPokemonStandardMaterials(gpp.ScooterMesh);
}

static function SetOnlinePokemonMuddy(Hat_GhostPartyPlayerStateBase Sender, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, bool IsMuddy)
{
	local Hat_GhostPartyPlayer gpp;
	if (Sender == None || PokemonEffect == None)
		return;
	gpp = Hat_GhostPartyPlayer(Sender.GhostActor);
	if (gpp == None)
		return;
	if (gpp.ScooterMesh.SkeletalMesh == PokemonEffect.default.ScooterMesh)
		PokemonEffect.static.SetPokemonMuddyEffect(gpp.ScooterMesh, IsMuddy);
}

static function DoStuffBasedOnString(string MinusedCommand, Hat_GhostPartyPlayerStateBase Sender, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, RideablePokemon_Script ModInstance)
{
	local string s;
	if (ModInstance == None || Sender == None)
		return;
	if (Left(MinusedCommand, 6) ~= "action")
	{
		s = Right(MinusedCommand, Len(MinusedCommand)-6);
		SetOnlinePokemonBattleAction(Sender, PokemonEffect, Name(s));
		return;
	}
	switch(locs(MinusedCommand))
	{
		case "ridestart":
			ModInstance.AddGppState(Sender);
			UpdateOnlinePokemonMesh(Sender, PokemonEffect);
			class'Hat_RideablePokemon_Collision'.static.SpawnOrGetCollisionActor(Sender.GhostActor);
			break;
		case "ridestop":
			class'Hat_RideablePokemon_Collision'.static.DestroyCollisionActor(Sender.GhostActor);
			DetachOnlinePokemonMesh(Sender, PokemonEffect);
			ModInstance.RemoveGppState(Sender);
			break;
		case "wireframe":
			SetOnlinePokemonWireframe(Sender, PokemonEffect, true);
			break;
		case "standard":
			SetOnlinePokemonWireframe(Sender, PokemonEffect, false);
			break;
		case "muddy":
			SetOnlinePokemonMuddy(Sender, PokemonEffect, true);
			break;
		case "clean":
			SetOnlinePokemonMuddy(Sender, PokemonEffect, false);
			break;
		case "idle":
			SetOnlinePokemonBattleAction(Sender, PokemonEffect, '');
			break;
		default:
			if (Right(MinusedCommand, 6) ~= "health")
				SetOnlinePokemonHealthNumber(Sender, PokemonEffect, int(Left(MinusedCommand, Len(MinusedCommand)-6)));
			break;
	}
}

static function HandleHookedOnlinePlayerState(Hat_GhostPartyPlayerStateBase PlayerState, RideablePokemon_Script ModInstance)
{
	if (ModInstance == None || PlayerState == None || PlayerState.IsLocalPlayer())
        return;
	SendOnlinePartyCommandWithModInstance("PokemonRideStartQuery", ModInstance, , PlayerState);
}

static function CondSendRideablePokemon(RideablePokemon_Script ModInstance, optional Hat_GhostPartyPlayerStateBase receiver)
{
	local WorldInfo wi;
	local Hat_Player ply;
	local Hat_StatusEffect_RideablePokemon s;
	if (ModInstance == None)
		return;
	wi = (ModInstance.WorldInfo != None ? ModInstance.WorldInfo : class'WorldInfo'.static.GetWorldInfo());
	if (wi == None)
		return;
	foreach wi.AllPawns(class'Hat_Player', ply)
	{
		if (ply == None)
			continue;
		s = Hat_StatusEffect_RideablePokemon(ply.GetStatusEffect(class'Hat_StatusEffect_RideablePokemon', true));
		if (s != None)
			SendOnlinePartyCommandWithModInstance(s.GetLocalName()$"RideStart", ModInstance, ply, receiver);
	}
}

defaultproperties
{
	MainChannel = "RideablePokemon"
	PokemonEffects.Add(class'Hat_StatusEffect_RideableNidoqueen')
	PokemonEffects.Add(class'Hat_StatusEffect_RideableParasect')
	PokemonEffects.Add(class'Hat_StatusEffect_RideableKangaskhan')
	PokemonEffects.Add(class'Hat_StatusEffect_RideableSnorlax')
	PokemonEffects.Add(class'Hat_StatusEffect_RideableFurret')
	PokemonEffects.Add(class'Hat_StatusEffect_RideableOctillery_M')
	PokemonEffects.Add(class'Hat_StatusEffect_RideableFlygon')
	PokemonEffects.Add(class'Hat_StatusEffect_RideableArmaldo')
	PokemonEffects.Add(class'Hat_StatusEffect_RideableGastrodon_WS')
	PokemonEffects.Add(class'Hat_StatusEffect_RideableGastrodon_ES')
	PokemonEffects.Add(class'Hat_StatusEffect_RideableGarchomp_M')
	PokemonEffects.Add(class'Hat_StatusEffect_RideableGogoat')
	SpecialPokemonEffects.Add(class'Hat_StatusEffect_RideableGlaceon')
	SpecialPokemonEffects.Add(class'Hat_StatusEffect_RideableGiratina')
}