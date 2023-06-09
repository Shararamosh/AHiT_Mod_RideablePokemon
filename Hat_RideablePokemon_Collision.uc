class Hat_RideablePokemon_Collision extends Actor
	IterationOptimized;

struct ActorCollisionProperties
{
	var Actor PropertiesOwner;
	var bool bCollideActors, bBlockActors, bBlockPawns;
};

//Variable that contains list of Actors that decided to get based on us, but we don't need it and we should ignore collision with them.
var private transient Array<Actor> IgnoreCollision;
//Variable that contains Array of values of Collision properties of Actors before changing its Collision to blocking one. Saved as Array in order to properly maintain possible ownership changes.
var private Array<ActorCollisionProperties> ActorsCollisionProperties;
//REFERENCES TO OTHER CLASSES FUNCTIONS BEGIN!!!
static function string GetPlayerString(Object o, optional bool FirstCapital)
{
	return class'RideablePokemon_Script'.static.GetPlayerString(o, FirstCapital);
}

static function SendWarningMessage(string Message, optional Actor Sender)
{
	class'RideablePokemon_Script'.static.SendWarningMessage(Message, Sender);
}

static function SendMessageArray(Array<string> StringArray, optional Actor Sender)
{
	class'RideablePokemon_Script'.static.SendMessageArray(StringArray, Sender);
}
//REFERENCES TO OTHER CLASSES FUNCTIONS END!!!
simulated function bool ConditionalDestroy(string FunctionName)
{
	if (class'GameMod'.static.GetConfigValue(class'RideablePokemon_Script', 'mod_disabled') != 0)
	{
		if (FunctionName != "")
			SendWarningMessage("["$self.Name$"/"$FunctionName$"] Warning: Pokemon Collision will be destroyed as mod is disabled.", Owner);
		if (!Destroy())
			ShutDown();
		return true;
	}
	if (Owner == None)
	{
		if (FunctionName != "")
			SendWarningMessage("["$self.Name$"/"$FunctionName$"] Warning: Pokemon Collision will be destroyed as it has no Owner.");
		if (!Destroy())
			ShutDown();
		return true;
	}
	if (Hat_GhostPartyPlayer(Owner) == None && Hat_Player(Owner) == None)
	{
		if (FunctionName != "")
			SendWarningMessage("["$self.Name$"/"$FunctionName$"] Warning: Pokemon Collision will be destroyed as it has no valid Owner. Owner:"@GetPlayerString(Owner)$".");
		if (!Destroy())
			ShutDown();
		return true;
	}
	return false;
}

simulated function ApplyOwnerCollisionProperties() //Executed in SetOwnerAsBase. Maintaining blocking collision on Owner and restoring collision in case ownership changed.
{
	local int i;
	local ActorCollisionProperties acp;
	i = IterateActorsCollisionProperties();
	if (Owner == None)
		return;
	if (i < 0) //Owner's Collision Properties are not saved yet.
	{
		acp.PropertiesOwner = Owner;
		acp.bCollideActors = Owner.bCollideActors;
		acp.bBlockActors = Owner.bBlockActors;
		acp.bBlockPawns = Owner.bBlockPawns;
		ActorsCollisionProperties.AddItem(acp); //Saving Owner's Collision Properties while also removing non-Owner's ones.
		SendWarningMessage("["$self.Name$"/ApplyOwnerCollisionProperties] Saved new Collision Properties for"@GetPlayerString(Owner)$": bCollideActors:"@bCollideActors$", bBlockActors:"@bBlockActors$", bBlockPawns:"@bBlockPawns$".");
	}
	if (Owner.bCollideActors != true || Owner.bBlockActors != true)
		Owner.SetCollision(true, true, Owner.bIgnoreEncroachers);
	if (!Owner.bBlockPawns)
		Owner.bBlockPawns = true;
}

simulated function int IterateActorsCollisionProperties() //Returns index of Array position with Owner in PropertiesOwner variable.
{
	local int i, j;
	j = -1;
	for (i = ActorsCollisionProperties.Length-1; i > -1; i--)
	{
		if (ActorsCollisionProperties[i].PropertiesOwner == None)
		{
			ActorsCollisionProperties.Remove(i, 1);
			continue;
		}
		if (ActorsCollisionProperties[i].PropertiesOwner == Owner)
		{
			if (j < 0)
				j = i;
			else //A dupe.
				ActorsCollisionProperties.Remove(i, 1);
			continue;
		}
		RestoreSavedActorCollisionProperties(ActorsCollisionProperties[i]);
		ActorsCollisionProperties.Remove(i, 1);
	}
	return j;
}

simulated function RestoreActorsCollisionProperties()
{
	local int i;
	local Array<Actor> RestoredActors;
	for (i = ActorsCollisionProperties.Length-1; i > -1; i--)
	{
		if (ActorsCollisionProperties[i].PropertiesOwner != None && RestoredActors.Find(ActorsCollisionProperties[i].PropertiesOwner) < 0)
		{
			RestoredActors.AddItem(ActorsCollisionProperties[i].PropertiesOwner);
			RestoreSavedActorCollisionProperties(ActorsCollisionProperties[i]);
		}
	}
	ActorsCollisionProperties.Length = 0;
}

static function bool RestoreSavedActorCollisionProperties(ActorCollisionProperties acp) //Returns true if any property value was changed.
{
	local bool b;
	if (acp.PropertiesOwner == None)
		return false;
	if (acp.PropertiesOwner.bCollideActors != acp.bCollideActors || acp.PropertiesOwner.bBlockActors != acp.bBlockActors)
	{
		acp.PropertiesOwner.SetCollision(acp.bCollideActors, acp.bBlockActors, acp.PropertiesOwner.bIgnoreEncroachers);
		b = true;
	}
	if (acp.PropertiesOwner.bBlockPawns != acp.bBlockPawns)
	{
		acp.PropertiesOwner.bBlockPawns = acp.bBlockPawns;
		b = true;
	}
	return b;
}

simulated event PreBeginPlay()
{
	if (ConditionalDestroy("PreBeginPlay"))
		return;
	if (SetOwnerAsBase())
	{
		ModifyLocalPlayer(Hat_Player(Owner));
		ModifyOnlinePlayer(Hat_GhostPartyPlayer(Owner));
	}
	Super.PreBeginPlay();
	SendWarningMessage("["$self.Name$"/PreBeginPlay] Pokemon Collision is spawned for"@GetPlayerString(Owner)$".", Owner);
}

simulated event PostBeginPlay()
{
	if (ConditionalDestroy("PostBeginPlay"))
		return;
	if (SetOwnerAsBase())
	{
		ModifyLocalPlayer(Hat_Player(Owner));
		ModifyOnlinePlayer(Hat_GhostPartyPlayer(Owner));
	}
}

simulated event Destroyed()
{
	if (Owner != None)
		SendWarningMessage("["$self.Name$"/Destroyed] Pokemon Collision is destroyed for"@GetPlayerString(Owner)$".", Owner);
	else
		SendWarningMessage("["$self.Name$"/Destroyed] Pokemon Collision is destroyed.");
	RestoreActorsCollisionProperties();
}

static function bool IsPokemonMesh(SkeletalMeshComponent comp)
{
	if (comp == None)
		return false;
	switch(comp.SkeletalMesh)
	{
		case class'Hat_StatusEffect_RideableNidoqueen'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableParasect'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableKangaskhan'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableSnorlax'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableFurret'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableOctillery_M'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableOctillery_F'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableFlygon'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableArmaldo'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableGastrodon_WS'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableGastrodon_ES'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableGarchomp_M'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableGarchomp_F'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableLeafeon'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableGlaceon'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableGiratina'.default.ScooterMesh:
		case class'Hat_StatusEffect_RideableGogoat'.default.ScooterMesh:
			return true;
		default:
			return false;
	}
}

simulated function bool SetOwnerAsBase()
{
	local SkeletalMeshComponent PokemonMesh;
	local bool b;
	PokemonMesh = GetScooterMesh(Owner);
	if (!IsPokemonMesh(PokemonMesh))
		PokemonMesh = None;
	if (Owner == None)
	{
		if (Base != None)
		{
			SetBase(None);
			SendWarningMessage("["$self.Name$"/SetOwnerAsBase] Set None Base for Pokemon Collision because Owner is None.");
		}
	}
	else
	{
		if (Base != Owner)
		{
			if (Base != None)
				SetBase(None);
			SetLocation(Owner.Location);
			SetRotation(Owner.Rotation);
			if (PokemonMesh != None && PokemonMesh.Owner == Owner && PokemonMesh.bAttached)
				SetBase(Owner, , PokemonMesh, PokemonMesh.GetBoneName(0));
			else
				SetBase(Owner);
			SendWarningMessage("["$self.Name$"/SetOwnerAsBase] Set"@GetPlayerString(Owner)@"as base for Pokemon Collision.", Owner);
		}
	}
	if (CollisionComponent != PokemonMesh)
	{
		CollisionComponent = PokemonMesh;
		if (CollisionComponent != None)
			SendWarningMessage("["$self.Name$"/SetOwnerAsBase] Set Scooter Mesh as new CollisionComponent for Pokemon Collision. Owner:"@GetPlayerString(Owner)$".", Owner);
		else
			SendWarningMessage("["$self.Name$"/SetOwnerAsBase] Set None as new CollisionComponent for Pokemon Collision. Owner:"@GetPlayerString(Owner)$".", Owner);
	}
	if (CollisionComponent == None)
	{
		RestoreActorsCollisionProperties();
		if (!bHidden)
		{
			SetHidden(true);
			SendWarningMessage("["$self.Name$"/SetOwnerAsBase] Pokemon Collision was hidden: Invalid Scooter Mesh. Owner:"@GetPlayerString(Owner)$".", Owner);
		}
	}
	else
	{
		ApplyOwnerCollisionProperties();
		if (bHidden)
		{
			SetHidden(false);
			SendWarningMessage("["$self.Name$"/SetOwnerAsBase] Pokemon Collision was unhidden: Detected valid Scooter Mesh. Owner:"@GetPlayerString(Owner)$".", Owner);
		}
		b = true;
	}
	if (Physics != PHYS_RigidBody)
		SetPhysics(PHYS_RigidBody);
	return b;
}

simulated event bool ShouldIgnoreBlockingBy(const Actor Other)
{
	if (Other == None)
		return true;
	if (Other == Owner)
		return true;
	if (IgnoreCollision.Find(Other) != INDEX_NONE) //An idiotic Actor decided to base on us, so we should kick it off.
		return true;
	if (class'GameMod'.static.GetConfigValue(class'RideablePokemon_Script', 'mod_disabled') != 0)
		return true;
	if (class'GameMod'.static.GetConfigValue(class'RideablePokemon_Script', 'EnableCollision') != 0)
		return true;
	if (Hat_Enemy_Boss(Other) != None) //Blocking bosses can potentially break their attacks.
		return true;
	if (Hat_GhostPartyPlayer(Owner) != None)
	{
		if (class'Shara_SteamID_Tools_RPS'.static.GetPawnPlayerController(Hat_Player(Other)) == None)
			return true;
		return false;
	}
	if (Hat_Player(Owner) == None)
		return true;
	if (Other.Physics == PHYS_RigidBody) //It's Rigid-body Actors' destiny to block each other, right? Well, Unreal Engine should still check for things like RBChannel and RBCollideWithChannels.
		return false;
	if (PathName(Other.Class) ~= "hatintimegamecontent.Hat_Vacuum")
	{
		if (Other.Physics != PHYS_Walking) //Rumbi is not on the ground.
			return true;
		switch(Other.GetStateName()) //Rumbi loves stucking in weird positions, so let's not block him when he's not actually on the ground.
		{
			case 'HitWallSpin':
			case 'DamageFlip':
			case 'JumpForJoy':
				return true;
			default:
				return false;
		}
	}
	if (Pawn(Other) != None)
		return false;
	return true;
}

simulated event Attach(Actor Other)
{
	local Actor OwnerBase;
	if (Other == None)
		return;
	if (Pawn(Other) == None)
	{
		if (Owner != None)
			OwnerBase = Owner.Base;
		Other.SetBase(OwnerBase);
		if (IgnoreCollision.Find(Other) == INDEX_NONE)
			IgnoreCollision.AddItem(Other);
	}
}

simulated event Detach(Actor Other)
{
	if (Other != None)
		IgnoreCollision.RemoveItem(Other);
}

simulated event bool EncroachingOn(Actor Other)
{
	if (WorldInfo != None && WorldInfo.Pauser != None)
		return true;
	return false;
}

simulated event Tick(float DeltaTime)
{
	if (ConditionalDestroy("Tick"))
		return;
	if (SetOwnerAsBase())
	{
		ModifyLocalPlayer(Hat_Player(Owner));
		ModifyOnlinePlayer(Hat_GhostPartyPlayer(Owner));
	}
}

static function ModifyOnlinePlayer(Hat_GhostPartyPlayer gpp)
{
	if (gpp == None)
		return;
	if (gpp.SprintParticle != None)
	{
		gpp.SprintParticle.SetActive(false);
		gpp.SprintParticle.DetachFromAny();
		gpp.SprintParticle = None;
	}
	if (gpp.ScooterEngineSound != None)
	{
		gpp.ScooterEngineSound.Stop();
		gpp.ScooterEngineSound.DetachFromAny();
		gpp.ScooterEngineSound = None;
	}
	if (gpp.ScooterDrivingSound != None)
	{
		gpp.ScooterDrivingSound.Stop();
		gpp.ScooterDrivingSound.DetachFromAny();
		gpp.ScooterDrivingSound = None;
	}
}

static function ModifyLocalPlayer(Hat_Player ply)
{
	if (ply != None && ply.IdleTime <= 15.0)
		ply.IdleTime = 25.0;
}

static function SkeletalMeshComponent GetScooterMesh(Actor a)
{
	local Hat_StatusEffect_BadgeScooter ScooterStatus;
	local Hat_Player ply;
	local Hat_GhostPartyPlayer gpp;
	ply = Hat_Player(a);
	if (ply != None)
	{
		ScooterStatus = Hat_StatusEffect_BadgeScooter(ply.GetStatusEffect(class'Hat_StatusEffect_BadgeScooter', true));
		if (ScooterStatus != None)
			return ScooterStatus.ScooterMeshComp;
		return None;
	}
	gpp = Hat_GhostPartyPlayer(a);
	if (gpp == None)
		return None;
	return gpp.ScooterMesh;
}

static function Hat_RideablePokemon_Collision SpawnOrGetCollisionActor(Actor a)
{
	local Hat_RideablePokemon_Collision CollisionActor;
	if (Hat_Player(a) == None && Hat_GhostPartyPlayer(a) == None)
		return None;
	CollisionActor = GetCollisionActor(a);
	if (CollisionActor == None)
	{
		CollisionActor = a.Spawn(class'Hat_RideablePokemon_Collision', a, , a.Location, a.Rotation, , true);
		if (CollisionActor != None)
			SendWarningMessage("[Hat_RideablePokemon_Collision/SpawnOrGetCollisionActor] Spawned Pokemon Collision for"@GetPlayerString(a)$".", a);
		else
			SendWarningMessage("[Hat_RideablePokemon_Collision/SpawnOrGetCollisionActor] Failed to spawn Pokemon Collision for"@GetPlayerString(a)$".", a);
	}
	else
		SendWarningMessage("[Hat_RideablePokemon_Collision/SpawnOrGetCollisionActor] Got Pokemon Collision for"@GetPlayerString(a)$".", a);
	return CollisionActor;
}

static function Hat_RideablePokemon_Collision GetCollisionActor(Actor a)
{
	local Hat_RideablePokemon_Collision ca, CollisionActor;
	local Array<Hat_RideablePokemon_Collision> RemoveList;
	local int i;
	if (Hat_Player(a) == None && Hat_GhostPartyPlayer(a) == None)
		return None;
	foreach a.ChildActors(class'Hat_RideablePokemon_Collision', ca)
	{
		if (ca == None)
			continue;
		if (CollisionActor == None)
			CollisionActor = ca;
		else
			RemoveList.AddItem(ca);
	}
	for (i = 0; i < RemoveList.Length; i++)
	{
		if (RemoveList[i] != None)
		{
			if (!RemoveList[i].Destroy())
				RemoveList[i].ShutDown();
		}
	}
	RemoveList.Length = 0;
	if (CollisionActor == None)
		return None;
	return CollisionActor;
}

static function bool DestroyCollisionActor(Actor a)
{
	local bool b;
	local Array<Hat_RideablePokemon_Collision> RemoveList;
	local Hat_RideablePokemon_Collision ca;
	local int i;
	if (a == None)
		return false;
	foreach a.ChildActors(class'Hat_RideablePokemon_Collision', ca)
	{
		if (ca == None)
			continue;
		RemoveList.AddItem(ca);
	}
	for (i = 0; i < RemoveList.Length; i++)
	{
		if (RemoveList[i] != None)
		{
			if (RemoveList[i].Destroy())
				b = true;
			else
				RemoveList[i].ShutDown();
		}
	}
	RemoveList.Length = 0;
	return b;
}

defaultproperties
{
	bCollideActors = true
	bBlockActors = true
	bBlockPawns = true
	bCollideWorld = true
	bCollideComplex = true
	bPushedByEncroachers = false
	IgnoreActorCollisionWhenHidden = true
	ScriptShouldIgnoreBlockingBy = true
	bHidden = true
	bAlwaysTick = true
	Physics = PHYS_RigidBody
	TickGroup = TG_PostAsyncWork
}