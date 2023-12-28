class RideablePokemon_OnlinePartyHandler extends Object
	abstract;
/*
	This is the only time I don't remove Online Party Handler script from the mod before uploading it to Workshop. Feel free to do whatever you want with this info. Just don't mess up with online experience.
*/

var private const Name MainChannel;

final static function SendOnlinePartyCommand(string InCommand, optional Pawn SendingPlayer, optional Hat_GhostPartyPlayerStateBase Receiver, optional out RideablePokemon_Script ModInstance)
{
	if (ModInstance == None)
		ModInstance = class'RideablePokemon_Script'.static.GetModInstance();
	if (ModInstance != None)
		SendOnlinePartyCommandWithModInstance(InCommand, ModInstance, SendingPlayer, Receiver);
}

final static function SendOnlinePartyCommandWithModInstance(string Command, RideablePokemon_Script ModInstance, optional Pawn SendingPlayer, optional Hat_GhostPartyPlayerStateBase Receiver)
{
	if (Command == "" || ModInstance == None)
		return;
	ModInstance.SendOnlinePartyCommand(Command, default.MainChannel, SendingPlayer, Receiver);
	class'RideablePokemon_Script'.static.SendWarningMessage("["$default.Class.Name$"/SendOnlinePartyCommandWithModInstance] Sent Online Party Command:"@Command$". Sender:"@class'RideablePokemon_Script'.static.GetPlayerString(SendingPlayer)$". Receiver:"@class'RideablePokemon_Script'.static.GetPlayerString(Receiver)$"."$(ModInstance.WorldInfo != None ? " TimeSeconds:"@ModInstance.WorldInfo.TimeSeconds$"." : ""));
}

final static function HandleOnlinePartyCommand(string Command, Name CommandChannel, Hat_GhostPartyPlayerStateBase Sender, RideablePokemon_Script ModInstance)
{
	local class<Hat_StatusEffect_RideablePokemon> ReceivedStatus;
	local string s;
	if (Sender == None || Command == "" || CommandChannel != default.MainChannel || ModInstance == None)
		return;
	class'RideablePokemon_Script'.static.SendWarningMessage("["$default.Class.Name$"/HandleOnlinePartyCommand] Received Online Party Command:"@Command$". Sender:"@class'RideablePokemon_Script'.static.GetPlayerString(Sender)$"."$(ModInstance.WorldInfo != None ? " TimeSeconds:"@ModInstance.WorldInfo.TimeSeconds$"." : ""));
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

final static function Array<class<Hat_StatusEffect_RideablePokemon>> GetStandardPokemonStatusEffects() //Pokemon avaialble to be used for any mod Sprint Hat Flair. Using National Pokedex order.
{
	local Array<class<Hat_StatusEffect_RideablePokemon>> PokemonEffects;
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableNidoqueen');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableParasect');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableKangaskhan');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableSnorlax');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableFurret');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableQuagsire_M');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableOctillery_M');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableFlygon');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableArmaldo');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableGastrodon_WS');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableGastrodon_ES');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableGarchomp_M');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableTogekiss');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableGogoat');
	return PokemonEffects;
}

final static function Array<class<Hat_StatusEffect_RideablePokemon>> GetSpecialPokemonStatusEffects() //Pokemon avaialble only to specific mod Sprint Hat Flairs. Using National Pokedex order.
{
	local Array<class<Hat_StatusEffect_RideablePokemon>> PokemonEffects;
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableLeafeon');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableGlaceon');
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableGiratina');
	return PokemonEffects;
}

final static function class<Hat_StatusEffect_RideablePokemon> GetPokemonStatusEffectByCommand(string Command, optional out string PokemonName)
{
	local int i;
	local string s;
	local Array<class<Hat_StatusEffect_RideablePokemon>> PokemonEffects;
	PokemonEffects = GetStandardPokemonStatusEffects(); //Pokemon available to be used for any mod Sprint Hat Flair.
	for (i = 0; i < PokemonEffects.Length; i++)
	{
		s = locs(PokemonEffects[i].static.GetLocalName());
		if (Left(locs(Command), Len(s)) == s) //Check if command has Pokemon name at the very beginning.
		{
			PokemonName = s;
			return PokemonEffects[i];
		}
	}
	PokemonEffects = GetSpecialPokemonStatusEffects(); //Pokemon available only to specific mod Sprint Hat Flairs.
	for (i = 0; i < PokemonEffects.Length; i++)
	{
		s = locs(PokemonEffects[i].static.GetLocalName());
		if (Left(locs(Command), Len(s)) == s) //Check if command has Pokemon name at the very beginning.
		{
			PokemonName = s;
			return PokemonEffects[i];
		}
	}
	return None;
}

final static function UpdateOnlinePokemonMesh(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_RideablePokemon> PokemonEffect)
{
	if (gpp == None || PokemonEffect == None)
		return;
	if (gpp.ScooterMesh == None)
		gpp.ScooterMesh = PokemonEffect.static.CreateScooterMesh(gpp, gpp.SkeletalMeshComponent);
    else
		PokemonEffect.static.MaintainScooterMesh(gpp, gpp.SkeletalMeshComponent, gpp.ScooterMesh);
	class'Hat_RideablePokemon_Collision'.static.SpawnOrGetCollisionActor(gpp);
}

final static function DetachOnlinePokemonMesh(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_RideablePokemon> PokemonEffect)
{
	local float f;
	local Vector v;
	if (gpp == None)
		return;
	class'Hat_RideablePokemon_Collision'.static.DestroyCollisionActor(gpp);
	if (PokemonEffect == None)
		return;
	if (!gpp.PlayerState.UnreliableState.IsOnScooter && gpp.ScooterMesh != None && PokemonEffect.static.IsPokemonSkeletalMesh(gpp.ScooterMesh.SkeletalMesh))
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

final static function RestoreOnlinePlayerMeshValues(Hat_GhostPartyPlayer gpp)
{
	local class<Hat_Player> PlayerClass;
	if (gpp == None || gpp.SkeletalMeshComponent == None)
		return;
	PlayerClass = gpp.PlayerVisualClass;
	gpp.SkeletalMeshComponent.SetScale((PlayerClass == None || PlayerClass.default.Mesh == None) ? class'Hat_Player_HatKid'.default.Mesh.Scale : PlayerClass.default.Mesh.Scale);
	gpp.SkeletalMeshComponent.SetScale3D((PlayerClass == None || PlayerClass.default.Mesh == None) ? class'Hat_Player_HatKid'.default.Mesh.Scale3D : PlayerClass.default.Mesh.Scale3D);
}

final static function RestoreOnlinePlayerMeshValuesFromScooter(Hat_GhostPartyPlayer gpp, float f, Vector v)
{
	if (gpp == None || gpp.SkeletalMeshComponent == None)
		return;
	gpp.SkeletalMeshComponent.SetScale(f);
	gpp.SkeletalMeshComponent.SetScale3D(v);
}

final static function SetOnlinePokemonBattleAction(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, Name AnimName)
{
	if (gpp == None || PokemonEffect == None)
		return;
	PokemonEffect.static.PerformOnlineScooterHonk(gpp, AnimName);
}

final static function SetOnlinePokemonHealth(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, int h)
{
	if (gpp == None || PokemonEffect == None)
		return;
	if (PokemonEffect.static.IsPokemonSkeletalMesh(gpp.ScooterMesh.SkeletalMesh))
		PokemonEffect.static.SetPokemonHealth(gpp.ScooterMesh, h);
}

final static function SetOnlinePokemonWireframe(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, bool IsWireframe)
{
	if (gpp == None || PokemonEffect == None)
		return;
	if (!PokemonEffect.static.IsPokemonSkeletalMesh(gpp.ScooterMesh.SkeletalMesh))
		return;
	if (IsWireframe)
		PokemonEffect.static.SetPokemonWireframeMaterials(gpp.ScooterMesh);
	else
		PokemonEffect.static.SetPokemonStandardMaterials(gpp.ScooterMesh);
}

final static function SetOnlinePokemonMuddy(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, bool IsMuddy)
{
	if (gpp == None || PokemonEffect == None)
		return;
	if (PokemonEffect.static.IsPokemonSkeletalMesh(gpp.ScooterMesh.SkeletalMesh))
		PokemonEffect.static.SetPokemonMuddyEffect(gpp.ScooterMesh, IsMuddy);
}

final static function DoStuffBasedOnString(string MinusedCommand, Hat_GhostPartyPlayerStateBase Sender, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, RideablePokemon_Script ModInstance)
{
	if (ModInstance == None || Sender == None)
		return;
	if (Left(MinusedCommand, 6) ~= "action")
	{
		SetOnlinePokemonBattleAction(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect, Name(Right(MinusedCommand, Len(MinusedCommand)-6)));
		return;
	}
	switch(locs(MinusedCommand))
	{
		case "ridestart":
			ModInstance.AddGppState(Sender);
			UpdateOnlinePokemonMesh(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect);
			break;
		case "ridestop":
			DetachOnlinePokemonMesh(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect);
			ModInstance.RemoveGppState(Sender);
			break;
		case "wireframe":
			SetOnlinePokemonWireframe(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect, true);
			break;
		case "standard":
			SetOnlinePokemonWireframe(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect, false);
			break;
		case "muddy":
			SetOnlinePokemonMuddy(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect, true);
			break;
		case "clean":
			SetOnlinePokemonMuddy(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect, false);
			break;
		case "idle":
			SetOnlinePokemonBattleAction(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect, '');
			break;
		default:
			if (Right(MinusedCommand, 6) ~= "health")
				SetOnlinePokemonHealth(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect, int(Left(MinusedCommand, Len(MinusedCommand)-6)));
			break;
	}
}

final static function HandleHookedOnlinePlayerState(Hat_GhostPartyPlayerStateBase PlayerState, RideablePokemon_Script ModInstance)
{
	if (ModInstance == None || PlayerState == None || PlayerState.IsLocalPlayer())
        return;
	SendOnlinePartyCommandWithModInstance("PokemonRideStartQuery", ModInstance, , PlayerState);
}

final static function CondSendRideablePokemon(RideablePokemon_Script ModInstance, optional Hat_GhostPartyPlayerStateBase Receiver)
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
			SendOnlinePartyCommandWithModInstance(s.GetLocalName()$"RideStart", ModInstance, ply, Receiver);
	}
}

defaultproperties
{
	MainChannel = "RideablePokemon"
}