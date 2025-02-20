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

//REFERENCES TO OTHER CLASSES FUNCTIONS END!!!
final private simulated function bool ConditionalDestroy()
{
	if (Hat_GhostPartyPlayer(Owner) != None)
		return false;
	if (!Destroy())
		ShutDown();
	return true;
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
	if (ConditionalDestroy())
		return;
	if (Location != Owner.Location)
		SetLocation(Owner.Location);
	if (Rotation != Owner.Rotation)
		SetRotation(Owner.Rotation);
	if (Base != Owner)
		SetBase(Owner);
	ModifyOwnerProperties();
	Super.PreBeginPlay();
}

simulated event PostBeginPlay()
{
	if (ConditionalDestroy())
		return;
	ModifyOwnerProperties();
}

simulated event Destroyed()
{
	RestoreActorsCollisionProperties();
}

simulated event ShutDown()
{
	RestoreActorsCollisionProperties();
	Super.ShutDown();
}

simulated event Tick(float DeltaTime)
{
	if (ConditionalDestroy())
		return;
	ModifyOwnerProperties();
}

final private simulated function ModifyOwnerProperties()
{
	local bool b;
	local Hat_GhostPartyPlayer gpp;
	gpp = Hat_GhostPartyPlayer(Owner);
	if (gpp == None || !class'RideablePokemon_OnlinePartyHandler'.static.IsPokemonMesh(gpp.ScooterMesh))
	{
		ApplyOwnerCollisionProperties(false);
		return;
	}
	b = IsCollisionEnabled();
	ApplyOwnerCollisionProperties(b);
	if (gpp.ScooterMesh.CollideActors != b || gpp.ScooterMesh.BlockActors != b)
		gpp.ScooterMesh.SetActorCollision(b, b, gpp.ScooterMesh.AlwaysCheckCollision);
}

final static function Hat_RideablePokemon_Collision SpawnOrGetCollisionActor(Actor a)
{
	local Hat_RideablePokemon_Collision CollisionActor;
	if (Hat_GhostPartyPlayer(a) == None)
		return None;
	CollisionActor = GetCollisionActor(a);
	if (CollisionActor != None)
		return CollisionActor;
	return a.Spawn(class'Hat_RideablePokemon_Collision', a, , a.Location, a.Rotation, , true);
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
	local int i;
	local bool b;
	local Hat_RideablePokemon_Collision ca;
	local Array<Hat_RideablePokemon_Collision> RemoveList;
	if (a == None)
		return false;
	foreach a.ChildActors(class'Hat_RideablePokemon_Collision', ca)
	{
		if (ca != None)
			RemoveList.AddItem(ca);
	}
	for (i = 0; i < RemoveList.Length; i++)
	{
		if (RemoveList[i].Destroy())
			b = true;
		else
			RemoveList[i].ShutDown();
	}
	RemoveList.Length = 0;
	return b;
}

defaultproperties
{
	bAlwaysTick = true
}