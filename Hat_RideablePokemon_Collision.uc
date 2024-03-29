class Hat_RideablePokemon_Collision extends Actor
	IterationOptimized;

struct ActorCollisionProperties
{
	var Actor PropertiesOwner;
	var bool bCollideActors, bBlockActors, bBlockPawns;
};

//Variable that contains Array of values of Collision properties of Actors before changing its Collision to blocking one. Saved as Array in order to properly maintain possible ownership changes.
var private transient Array<ActorCollisionProperties> ActorsCollisionProperties;
//REFERENCES TO OTHER CLASSES FUNCTIONS BEGIN!!!

final static function bool IsCollisionEnabled()
{
	return class'RideablePokemon_Script'.static.IsCollisionEnabled();
}

final static function string GetPlayerString(Object o, optional bool FirstCapital)
{
	return class'RideablePokemon_Script'.static.GetPlayerString(o, FirstCapital);
}

final static function SendWarningMessage(string Message, optional Actor Sender)
{
	class'RideablePokemon_Script'.static.SendWarningMessage(Message, Sender);
}

final static function SendMessageArray(Array<string> StringArray, optional Actor Sender)
{
	class'RideablePokemon_Script'.static.SendMessageArray(StringArray, Sender);
}
//REFERENCES TO OTHER CLASSES FUNCTIONS END!!!
final private simulated function bool ConditionalDestroy(string FunctionName)
{
	if (Hat_GhostPartyPlayer(Owner) == None)
	{
		if (FunctionName != "")
			SendWarningMessage("["$self.Name$"/"$FunctionName$"] Warning: Pokemon Helper will be destroyed as it has no valid Owner. Owner:"@GetPlayerString(Owner)$".");
		if (!Destroy())
			ShutDown();
		return true;
	}
	return false;
}

final private simulated function ApplyOwnerCollisionProperties(bool EnableCollision) //Executed in SetOwnerAsBase. Maintaining blocking collision on Owner and restoring collision in case ownership changed.
{
	local int i;
	local ActorCollisionProperties acp;
	if (!EnableCollision)
	{
		RestoreActorsCollisionProperties();
		return;
	}
	i = IterateActorsCollisionProperties();
	if (i < 0) //Owner's Collision Properties are not saved yet.
	{
		acp.PropertiesOwner = Owner;
		acp.bCollideActors = Owner.bCollideActors;
		acp.bBlockActors = Owner.bBlockActors;
		acp.bBlockPawns = Owner.bBlockPawns;
		ActorsCollisionProperties.AddItem(acp); //Saving Owner's Collision Properties while also removing non-Owner's ones.
		SendWarningMessage("["$self.Name$"/ApplyOwnerCollisionProperties] Saved new Collision Properties for"@GetPlayerString(Owner)$": bCollideActors:"@acp.bCollideActors$", bBlockActors:"@acp.bBlockActors$", bBlockPawns:"@acp.bBlockPawns$".");
	}
	if (!Owner.bCollideActors || !Owner.bBlockActors)
		Owner.SetCollision(true, true, Owner.bIgnoreEncroachers);
	if (!Owner.bBlockPawns)
		Owner.bBlockPawns = true;
}

final private simulated function int IterateActorsCollisionProperties() //Returns index of Array position with Owner in PropertiesOwner variable.
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

final private simulated function RestoreActorsCollisionProperties()
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

final static function bool RestoreSavedActorCollisionProperties(ActorCollisionProperties acp) //Returns true if any property value was changed.
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
	if (Location != Owner.Location)
	{
		if (!SetLocation(Owner.Location))
			SendWarningMessage("["$self.Name$"/PreBeginPlay] Failed to move Pokemon Helper to"@Owner.Location$".", Owner);
	}
	if (Rotation != Owner.Rotation)
	{
		if (!SetRotation(Owner.Rotation))
			SendWarningMessage("["$self.Name$"/PreBeginPlay] Failed to rotate Pokemon Helper to"@Owner.Rotation$".", Owner);
	}
	if (Base != Owner)
		SetBase(Owner);
	ModifyOwnerProperties();
	Super.PreBeginPlay();
	SendWarningMessage("["$self.Name$"/PreBeginPlay] Pokemon Helper is spawned for"@GetPlayerString(Owner)$".", Owner);
}

simulated event PostBeginPlay()
{
	if (ConditionalDestroy("PostBeginPlay"))
		return;
	ModifyOwnerProperties();
}

simulated event Destroyed()
{
	RestoreActorsCollisionProperties();
	if (Owner != None)
		SendWarningMessage("["$self.Name$"/Destroyed] Pokemon Helper is destroyed for"@GetPlayerString(Owner)$".", Owner);
	else
		SendWarningMessage("["$self.Name$"/Destroyed] Pokemon Helper is destroyed.");
}

simulated event ShutDown()
{
	RestoreActorsCollisionProperties();
	Super.ShutDown();
	if (Owner != None)
		SendWarningMessage("["$self.Name$"/ShutDown] Pokemon Helper is shut down for"@GetPlayerString(Owner)$".", Owner);
	else
		SendWarningMessage("["$self.Name$"/ShutDown] Pokemon Helper is shut down.");
}

simulated event Tick(float DeltaTime)
{
	if (ConditionalDestroy("Tick"))
		return;
	ModifyOwnerProperties();
}

final private simulated function ModifyOwnerProperties()
{
	local Hat_GhostPartyPlayer gpp;
	local bool b;
	gpp = Hat_GhostPartyPlayer(Owner);
	if (gpp == None || !IsPokemonMesh(gpp.ScooterMesh))
	{
		ApplyOwnerCollisionProperties(false);
		return;
	}
	b = IsCollisionEnabled();
	ApplyOwnerCollisionProperties(b);
	if (gpp.ScooterMesh.CollideActors != b || gpp.ScooterMesh.BlockActors != b)
		gpp.ScooterMesh.SetActorCollision(b, b, gpp.ScooterMesh.AlwaysCheckCollision);
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

final static function bool IsPokemonMesh(SkeletalMeshComponent comp)
{
	local int i;
	local Array<class<Hat_StatusEffect_RideablePokemon>> PokemonEffects;
	if (comp == None)
		return false;
	PokemonEffects = class'RideablePokemon_OnlinePartyHandler'.static.GetStandardPokemonStatusEffects();
	for (i = 0; i < PokemonEffects.Length; i++)
	{
		if (PokemonEffects[i].static.IsPokemonSkeletalMesh(comp.SkeletalMesh))
			return true;
	}
	PokemonEffects = class'RideablePokemon_OnlinePartyHandler'.static.GetSpecialPokemonStatusEffects();
	for (i = 0; i < PokemonEffects.Length; i++)
	{
		if (PokemonEffects[i].static.IsPokemonSkeletalMesh(comp.SkeletalMesh))
			return true;
	}
	return false;
}

final static function Hat_RideablePokemon_Collision SpawnOrGetCollisionActor(Actor a)
{
	local Hat_RideablePokemon_Collision CollisionActor;
	if (Hat_GhostPartyPlayer(a) == None)
		return None;
	CollisionActor = GetCollisionActor(a);
	if (CollisionActor == None)
	{
		CollisionActor = a.Spawn(class'Hat_RideablePokemon_Collision', a, , a.Location, a.Rotation, , true);
		if (CollisionActor != None)
			SendWarningMessage("[Hat_RideablePokemon_Collision/SpawnOrGetCollisionActor] Spawned Pokemon Helper for"@GetPlayerString(a)$".", a);
		else
			SendWarningMessage("[Hat_RideablePokemon_Collision/SpawnOrGetCollisionActor] Failed to spawn Pokemon Helper for"@GetPlayerString(a)$".", a);
	}
	else
		SendWarningMessage("[Hat_RideablePokemon_Collision/SpawnOrGetCollisionActor] Got Pokemon Helper for"@GetPlayerString(a)$".", a);
	return CollisionActor;
}

final static function Hat_RideablePokemon_Collision GetCollisionActor(Actor a)
{
	local Hat_RideablePokemon_Collision ca, CollisionActor;
	local Array<Hat_RideablePokemon_Collision> RemoveList;
	local int i;
	if (Hat_GhostPartyPlayer(a) == None)
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
	return CollisionActor;
}

final static function bool DestroyCollisionActor(Actor a)
{
	local bool b;
	local Array<Hat_RideablePokemon_Collision> RemoveList;
	local Hat_RideablePokemon_Collision ca;
	local int i;
	if (a == None)
		return false;
	foreach a.ChildActors(class'Hat_RideablePokemon_Collision', ca)
	{
		if (ca != None)
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
	bAlwaysTick = true
}