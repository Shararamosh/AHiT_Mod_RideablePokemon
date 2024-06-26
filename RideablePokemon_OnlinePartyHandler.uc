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
	PokemonEffects.AddItem(class'Hat_StatusEffect_RideableSylveon');
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

final static function bool UpdateOnlinePokemonMesh(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_RideablePokemon> PokemonEffect)
{
	if (gpp == None || PokemonEffect == None)
		return false;
	if (gpp.ScooterMesh == None)
		gpp.ScooterMesh = PokemonEffect.static.CreateScooterMesh(gpp, gpp.SkeletalMeshComponent);
    else
		PokemonEffect.static.MaintainScooterMesh(gpp, gpp.SkeletalMeshComponent, gpp.ScooterMesh);
	if (gpp.ScooterMesh == None)
		return false;
	class'RideablePokemon_Script'.static.ApplyOnlinePlayerScooterParticles(gpp, PokemonEffect);
	class'RideablePokemon_Script'.static.ApplyOnlinePlayerScooterSounds(gpp, PokemonEffect);
	class'Hat_RideablePokemon_Collision'.static.SpawnOrGetCollisionActor(gpp);
	return true;
}

final static function DetachOnlinePokemonMesh(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, bool IsOnScooter, bool ScooterIsSubcon)
{
	local float f;
	local Vector v;
	if (gpp == None)
		return;
	if (PokemonEffect != None && PokemonEffect.static.IsPokemonMesh(gpp.ScooterMesh))
	{
		if (!IsOnScooter)
		{
			if (PokemonEffect.default.ExplodeParticle != None && gpp.WorldInfo != None && gpp.WorldInfo.MyEmitterPool != None)
				gpp.Worldinfo.MyEmitterPool.SpawnEmitter(PokemonEffect.default.ExplodeParticle, gpp.Location);
			if (PokemonEffect.default.ExplodeSound != None)
				gpp.PlaySound(PokemonEffect.default.ExplodeSound);
			if (gpp.SkeletalMeshComponent != None && gpp.ScooterMesh.IsComponentAttached(gpp.SkeletalMeshComponent))
				gpp.AttachComponent(gpp.SkeletalMeshComponent);
			f = gpp.ScooterMesh.Scale;
			v = gpp.ScooterMesh.Scale3D;
			gpp.ScooterMesh.DetachFromAny();
			gpp.ScooterMesh = None;
			RestoreOnlinePlayerMeshValuesFromScooter(gpp, f, v);
		}
	}
	else
		RestoreOnlinePlayerMeshValues(gpp);
	if (!IsPokemonMesh(gpp.ScooterMesh))
		class'Hat_RideablePokemon_Collision'.static.DestroyCollisionActor(gpp);
	class'RideablePokemon_Script'.static.RestoreOnlinePlayerScooterParticles(gpp, PokemonEffect, IsOnScooter, ScooterIsSubcon);
	class'RideablePokemon_Script'.static.RestoreOnlinePlayerScooterSounds(gpp, PokemonEffect, IsOnScooter, ScooterIsSubcon);
}

final static function RestoreOnlinePlayerMeshValues(Hat_GhostPartyPlayer gpp)
{
	local class<Hat_Player> PlayerClass;
	if (gpp == None || gpp.SkeletalMeshComponent == None)
		return;
	PlayerClass = gpp.PlayerVisualClass;
	if (PlayerClass == None)
		PlayerClass = class'Hat_Player_HatKid';
	gpp.SkeletalMeshComponent.SetScale((PlayerClass == None || PlayerClass.default.Mesh == None) ? 1.0 : PlayerClass.default.Mesh.Scale);
	gpp.SkeletalMeshComponent.SetScale3D((PlayerClass == None || PlayerClass.default.Mesh == None) ? vect(1.0, 1.0, 1.0) : PlayerClass.default.Mesh.Scale3D);
}

final static function RestoreOnlinePlayerMeshValuesFromScooter(Hat_GhostPartyPlayer gpp, float f, Vector v)
{
	if (gpp == None || gpp.SkeletalMeshComponent == None)
		return;
	if (f != 1.0)
		gpp.SkeletalMeshComponent.SetScale(gpp.SkeletalMeshComponent.Scale*f);
	if (v != vect(1.0, 1.0, 1.0))
		gpp.SkeletalMeshComponent.SetScale3D(gpp.SkeletalMeshComponent.Scale3D*v);
}

final static function SetOnlinePokemonBattleAction(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, Name AnimName)
{
	if (gpp == None || PokemonEffect == None)
		return;
	PokemonEffect.static.PerformOnlineScooterHonk(gpp, AnimName);
}

final static function SetOnlinePokemonHealth(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, int h, Name AnimName)
{
	if (gpp == None || PokemonEffect == None)
		return;
	if (PokemonEffect.static.IsPokemonMesh(gpp.ScooterMesh))
		PokemonEffect.static.SetPokemonHealth(gpp.ScooterMesh, h, AnimName);
}

final static function SetOnlinePokemonWireframe(Hat_GhostPartyPlayer gpp, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, bool IsWireframe)
{
	if (gpp == None || PokemonEffect == None)
		return;
	if (!PokemonEffect.static.IsPokemonMesh(gpp.ScooterMesh))
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
	if (PokemonEffect.static.IsPokemonMesh(gpp.ScooterMesh))
		PokemonEffect.static.SetPokemonMuddyEffect(gpp.ScooterMesh, IsMuddy);
}

final static function DoStuffBasedOnString(string MinusedCommand, Hat_GhostPartyPlayerStateBase Sender, class<Hat_StatusEffect_RideablePokemon> PokemonEffect, RideablePokemon_Script ModInstance)
{
	local int i;
	local string s;
	if (ModInstance == None || Sender == None)
		return;
	switch(locs(MinusedCommand))
	{
		case "ridestart":
			if (UpdateOnlinePokemonMesh(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect))
				ModInstance.AddGppState(Sender);
			else
				ModInstance.RemoveGppState(Sender);
			break;
		case "ridestop":
			DetachOnlinePokemonMesh(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect, Sender.UnreliableState.IsOnScooter, Sender.UnreliableState.ScooterIsSubcon);
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
			if (Left(MinusedCommand, 6) ~= "action")
				SetOnlinePokemonBattleAction(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect, Name(Right(MinusedCommand, Len(MinusedCommand)-6)));
			else if (Left(MinusedCommand, 6) ~= "health")
			{
				s = Mid(6, Len(MinusedCommand)-6);
				i = InStr(s, "_");
				if (i > -1)
					SetOnlinePokemonHealth(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect, int(Left(s, i)), Name(Mid(s, i+1, Len(s)-i-1)));
				else
					SetOnlinePokemonHealth(Hat_GhostPartyPlayer(Sender.GhostActor), PokemonEffect, int(s), '');
			}
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

final static function bool IsPokemonMesh(SkeletalMeshComponent comp)
{
	return (GetPokemonStatusEffectByMesh(comp) != None);
}

final static function class<Hat_StatusEffect_RideablePokemon> GetPokemonStatusEffectByMesh(SkeletalMeshComponent comp)
{
	local int i;
	local Array<class<Hat_StatusEffect_RideablePokemon>> PokemonEffects;
	if (comp == None || comp.SkeletalMesh == None)
		return None;
	PokemonEffects = GetStandardPokemonStatusEffects();
	for (i = 0; i < PokemonEffects.Length; i++)
	{
		if (PokemonEffects[i].static.IsPokemonMesh(comp))
			return PokemonEffects[i];
	}
	PokemonEffects = GetSpecialPokemonStatusEffects();
	for (i = 0; i < PokemonEffects.Length; i++)
	{
		if (PokemonEffects[i].static.IsPokemonMesh(comp))
			return PokemonEffects[i];
	}
	return None;
}

defaultproperties
{
	MainChannel = "RideablePokemon"
}