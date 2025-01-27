class Hat_StatusEffect_RideablePokemon extends Hat_StatusEffect_BadgeScooter
	abstract;

enum AnimationType
{
	Type_None, //No Animation has been assigned yet.
	Type_Sandmobile, //Standard Scooter/Sandmobile Animation tied to Player's script.
	Type_AnimNodes, //Animation using AnimNodeBlendBase AnimNodes.
	Type_TauntNodes, //Animation using Player's SetTauntAnim function.
	Type_CustomAnimation //Animation using PlayCustomAnimation on Player.
};

struct BattleActionAnims
{
	var Array<Name> IdleAnims, CryingAnims, PhysicalAttackAnims, SpecialAttackAnims, TakingDamageAnims;
};

struct ActorProperties
{
	var Actor PropertiesOwner;
	var bool bCanBeBaseForPawns; //Pawn only.
	var float AccelRate, MeshScale; //Pawn only.
	var Vector MeshScale3D; //Pawn only.
	var AnimationType PlayerAnimationType; //Hat_Player only.
	structdefaultproperties
	{
		MeshScale = 1.0
		MeshScale3D = (X = 1.0, Y = 1.0, Z = 1.0)
	}
};

var const AnimSet ScooterAnimSet;
var const Name ScooterAnimNodesName, ScooterIntroAnimation, ScooterLoopAnimation;
var const Array<MaterialInterface> WireframeMaterials;
var privatewrite transient float TimeUntilLoopAnimation;
var privatewrite transient int Health;
var private transient RideablePokemon_Script ModInstance;
var private transient Array<ActorProperties> ActorsProperties;
var privatewrite transient bool IsWireframe, IsMuddy;

final static function bool IsCollisionEnabled()
{
	return class'RideablePokemon_Script'.static.IsCollisionEnabled();
}

final static function bool IsPokemonScaringAllowed()
{
	return class'RideablePokemon_Script'.static.IsPokemonScaringAllowed();
}

final static function bool AreTimedEventSkinsAllowed()
{
	return class'RideablePokemon_Script'.static.AreTimedEventSkinsAllowed();
}

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.Length = 0;
	baa.CryingAnims.Length = 0;
	baa.PhysicalAttackAnims.Length = 0;
	baa.SpecialAttackAnims.Length = 0;
	baa.TakingDamageAnims.Length = 0;
	return baa;
}

static function class<Hat_StatusEffect_RideablePokemon> GetRandomAppearance(bool RandomGender, bool RandomForme)
{
	return default.Class;
}

static function SkeletalMeshComponent CreateScooterMesh(Actor InActor, SkeletalMeshComponent InComponent)
{
	local SkeletalMeshComponent comp;
	comp = new class'SkeletalMeshComponent';
	if (!MaintainScooterMesh(InActor, InComponent, comp))
		return None;
	return comp;
}

static function bool MaintainScooterMesh(Actor InActor, SkeletalMeshComponent InComponent, SkeletalMeshComponent MeshComponent)
{
	local float f;
	local Vector v;
	if (InActor == None || InComponent == None || MeshComponent == None)
		return false;
	AnimateScooter(MeshComponent);
	MeshComponent.SetSectionGroup('');
	MeshComponent.SetPhysicsAsset(GetPokemonPhysicsAsset(MeshComponent.SkeletalMesh));
	MeshComponent.SetTranslation(default.ScooterTranslation);
	MeshComponent.SetLightEnvironment(InComponent.LightEnvironment);
	MeshComponent.SetShadowParent(InComponent);
	MeshComponent.SetHasPhysicsAssetInstance(MeshComponent.PhysicsAsset != None && default.ScooterPhysicsAssetInstance);
	f = InComponent.Scale;
	v = InComponent.Scale3D;
	InComponent.SetScale(1.0);
	InComponent.SetScale3D(vect(1.0, 1.0, 1.0));
	InActor.AttachComponent(MeshComponent);
	MeshComponent.AttachComponentToSocket(InComponent, 'Driver');
	MeshComponent.SetScale(f);
	MeshComponent.SetScale3D(v);
	InitScooterMeshProperties(InActor, MeshComponent);
	return true;
}

final static function InitScooterMeshProperties(Actor a, SkeletalMeshComponent comp, optional bool NoCollision)
{
	local WorldInfo wi;
	class'Shara_SkinColors_Tools_Short_RPS'.static.ResetMaterials(comp, true);
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstancesMesh(comp);
	wi = class'WorldInfo'.static.GetWorldInfo();
	SetPokemonTimeAfterSpawn(comp, wi != None ? wi.TimeSeconds : 0.0);
	SetScooterMeshCollisionProperties(comp, NoCollision);
}

final static function SetScooterMeshCollisionProperties(SkeletalMeshComponent comp, optional bool NoCollision)
{
	if (comp == None)
		return;
	comp.CanBlockCamera = false;
	comp.SetActorCollision(NoCollision ? false : IsCollisionEnabled(), NoCollision ? false : IsCollisionEnabled(), comp.AlwaysCheckCollision);
	comp.SetTraceBlocking(true, true);
	comp.SetBlockRigidBody(true);
	comp.CanBeStoodOn = true;
	comp.CanBeEdgeGrabbed = true;
	comp.SetRBChannel(RBCC_GameplayPhysics);
	comp.SetRBCollidesWithChannel(RBCC_Default, true);
	comp.SetRBCollidesWithChannel(RBCC_Nothing, false);
	comp.SetRBCollidesWithChannel(RBCC_Pawn, true);
	comp.SetRBCollidesWithChannel(RBCC_Vehicle, true);
	comp.SetRBCollidesWithChannel(RBCC_Water, false);
	comp.SetRBCollidesWithChannel(RBCC_GameplayPhysics, true);
	comp.SetRBCollidesWithChannel(RBCC_EffectPhysics, true);
	comp.SetRBCollidesWithChannel(RBCC_Untitled1, false);
	comp.SetRBCollidesWithChannel(RBCC_Untitled2, false);
	comp.SetRBCollidesWithChannel(RBCC_Untitled3, true);
	comp.SetRBCollidesWithChannel(RBCC_Untitled4, false);
	comp.SetRBCollidesWithChannel(RBCC_Cloth, false);
	comp.SetRBCollidesWithChannel(RBCC_FluidDrain, false);
	comp.SetRBCollidesWithChannel(RBCC_SoftBody, false);
	comp.SetRBCollidesWithChannel(RBCC_FracturedMeshPart, false);
	comp.SetRBCollidesWithChannel(RBCC_BlockingVolume, true);
	comp.SetRBCollidesWithChannel(RBCC_DeadPawn, false);
	comp.SetRBCollidesWithChannel(RBCC_Clothing, false);
	comp.SetRBCollidesWithChannel(RBCC_ClothingCollision, false);
	comp.SetTickGroup(TG_PostAsyncWork);
	comp.InitRBPhys();
	comp.WakeRigidBody();
}

static function SetPokemonTimeAfterSpawn(SkeletalMeshComponent comp, float f)
{
	SetTimeAfterSpawnMesh(comp, f);
}

final static function SetTimeAfterSpawnMesh(MeshComponent comp, float f)
{
	class'Shara_SkinColors_Tools_Short_RPS'.static.SetMaterialScalarValueMesh(comp, 'TimeAfterSpawn', f);
}

final static function AnimateScooter(SkeletalMeshComponent comp)
{
	local SkeletalMesh sm;
	local bool UpdateAnims;
	if (comp == None)
		return;
	sm = GetPokemonSkeletalMesh();
	if (comp.SkeletalMesh != sm)
		comp.SetSkeletalMesh(sm);
	if (default.ScooterAnimSet == None)
	{
		if (comp.AnimSets.Length != 0)
		{
			comp.AnimSets.Length = 0;
			UpdateAnims = true;
		}
	}
	else
	{
		if (comp.AnimSets.Length != 1)
		{
			comp.AnimSets.Length = 1;
			UpdateAnims = true;
		}
		if (comp.AnimSets[0] != default.ScooterAnimSet)
		{
			comp.AnimSets[0] = default.ScooterAnimSet;
			UpdateAnims = true;
		}
	}
	if (comp.AnimTreeTemplate != default.ScooterAnimTree)
		comp.SetAnimTreeTemplate(default.ScooterAnimTree);
	if (UpdateAnims)
		comp.UpdateAnimations();
}

final static function string GetLocalName()
{
	return Mid(string(default.Class.Name), 25);
}

final static function bool CanRidePokemon(Actor a, bool CheckAnimations, bool DoSendMessage, optional bool UseLocalName)
{
	local bool b;
	local int i, j;
	local string s;
	local Hat_Player ply;
	local Hat_PawnCombat p;
	local AnimNodeBlendBase anbb;
	local Array<AnimNode> AnimNodes;
	local Hat_StatusEffect_BadgeScooter ScooterStatus;
	local Hat_StatusEffect_RideablePokemon PokemonStatus;
	if (UseLocalName)
		s = GetLocalName();
	else
		s = "Pokemon";
	p = Hat_PawnCombat(a);
	if (p == None)
		return false;
	ply = Hat_Player(p);
	if (ply == None)
	{
		if (DoSendMessage)
			p.ClientMessage("You can't ride"@s@"because you're not a Player.");
		return false;
	}
	if (IsDebugOnly() && !class'RideablePokemon_Script'.static.IsDev())
	{
		if (DoSendMessage)
			ply.ClientMessage("You can't ride"@s@"because it's not fully implemented yet. Wait for the next version of the mod.");
		return false;
	}
	if (!DoesPlayerFlairSupportThisPokemon(ply))
	{
		if (DoSendMessage)
			ply.ClientMessage("You can't ride"@s@"because you're not wearing Hat Flair that is tied to it.");
		return false;
	}
	if (ply.Mesh == None)
	{
		if (DoSendMessage)
			ply.ClientMessage("You can't ride"@s@"because you don't have a Mesh.");
		return false;
	}
	if (ply.VehicleProperties.VehicleModeActive)
	{
		if (DoSendMessage)
			ply.ClientMessage("You can't ride"@s@"because you already have Vehicle mode active.");
		return false;
	}
	if (CheckAnimations)
	{
		if (default.ScooterAnimNodesName != '')
		{
			for (i = 0; i < ply.TauntBlendAnimNodes.Length; i++)
			{
				if (ply.TauntBlendAnimNodes[i] == None)
					continue;
				for (j = 0; j < ply.TauntBlendAnimNodes[i].Taunts.Length; j++)
				{
					if (ply.TauntBlendAnimNodes[i].Taunts[j] ~= string(default.ScooterAnimNodesName))
					{
						b = true;
						break;
					}
				}
				if (b)
					break;
			}
			if (!b)
			{
				AnimNodes = ply.Mesh.FindAnimNodesByName(default.ScooterAnimNodesName);
				for (i = 0; i < AnimNodes.Length; i++)
				{
					anbb = AnimNodeBlendBase(AnimNodes[i]);
					if (anbb == None || anbb.Children.Length < 2)
						continue;
					if (AnimNodeBlend(anbb) == None && AnimNodeBlendList(anbb) == None)
						continue;
					b = true;
					break;
				}
			}
		}
		if (!b)
		{
			if (default.ScooterLoopAnimation != '')
			{
				if (ply.Mesh.FindAnimSequence(default.ScooterLoopAnimation) == None)
				{
					if (DoSendMessage)
					{
						if (default.ScooterAnimNodesName != '')
							ply.ClientMessage("You can't ride"@s@"because you don't have neither"@default.ScooterAnimNodesName@"Animation Nodes nor loop Animation Sequence named"@default.ScooterLoopAnimation$".");
						else
							ply.ClientMessage("You can't ride"@s@"because you don't have loop Animation Sequence named"@default.ScooterLoopAnimation$".");
					}
					return false;
				}
				if (default.ScooterIntroAnimation != '' && ply.Mesh.FindAnimSequence(default.ScooterIntroAnimation) == None)
				{
					if (DoSendMessage)
					{
						if (default.ScooterAnimNodesName != '')
							ply.ClientMessage("You can't ride"@s@"because you don't have neither"@default.ScooterAnimNodesName@"Animation Nodes nor intro Animation Sequence named"@default.ScooterIntroAnimation$".");
						else
							ply.ClientMessage("You can't ride"@s@"because you don't have intro Animation Sequence named"@default.ScooterIntroAnimation$".");
					}
					return false;
				}
			}
		}
	}
	ScooterStatus = Hat_StatusEffect_BadgeScooter(ply.GetStatusEffect(class'Hat_StatusEffect_BadgeScooter', true));
	if (ScooterStatus == None || ScooterStatus.Class == default.Class)
		return true;
	if (!DoSendMessage)
		return false;
	PokemonStatus = Hat_StatusEffect_RideablePokemon(ScooterStatus);
	if (PokemonStatus != None)
		ply.ClientMessage("You can't ride"@s@"because you are already riding"@PokemonStatus.GetLocalName()$".");
	else
		ply.ClientMessage("You can't ride"@s@"because you are already riding Scooter.");
	return false;
}

final static function bool DoesPlayerFlairSupportThisPokemon(Actor a)
{
	local Hat_Ability_Trigger PlayerHat;
	local class<Hat_Ability_Trigger> FlairBaseHat;
	PlayerHat = GetPlayerHat(a);
	if (PlayerHat == None)
		return false;
	if (class<Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon>(PlayerHat.MyItemQualityInfo) == None)
		return false;
	FlairBaseHat = class<Hat_Ability_Trigger>(PlayerHat.MyItemQualityInfo.static.GetBaseCosmeticItemWeApplyTo());
	if (FlairBaseHat == None)
		return false;
	if (PlayerHat.Class != FlairBaseHat)
		return false;
	if (IsTiedToFlair())
		return (PlayerHat.MyItemQualityInfo.default.StatusEffectOverride == default.Class);
	return true;
}

final static function Hat_Ability_Trigger GetPlayerHat(Actor a)
{
	local int i;
	local Hat_Player ply;
	local Hat_NPC_Player npc;
	local Hat_InventoryManager invm;
	local Hat_Ability_Trigger HatActor;
	ply = Hat_Player(a);
	if (ply != None)
	{
		invm = Hat_InventoryManager(ply.InvManager);
		if (invm != None)
			return Hat_Ability_Trigger(invm.Hat);
		return None;
	}
	npc = Hat_NPC_Player(a);
	if (npc == None)
		return None;
	for (i = 0; i < npc.MyInventory.Length; i++)
	{
		HatActor = Hat_Ability_Trigger(npc.MyInventory[i]);
		if (HatActor != None)
			return HatActor;
	}
	return None;
}

final private simulated function int SaveActorProperties(Actor a)
{
	local int i;
	local Pawn p;
	local ActorProperties ap;
	if (a == None)
		return -1;
	ap.PropertiesOwner = a;
	p = Pawn(a);
	if (p != None)
	{
		ap.bCanBeBaseForPawns = p.bCanBeBaseForPawns;
		ap.AccelRate = p.AccelRate;
		if (p.Mesh != None)
		{
			ap.MeshScale = p.Mesh.Scale;
			ap.MeshScale3D = p.Mesh.Scale3D;
		}
	}
	i = ActorsProperties.Find('PropertiesOwner', a);
	if (i > -1)
		ActorsProperties[i] = ap;
	else
	{
		ActorsProperties.AddItem(ap);
		i = ActorsProperties.Length-1;
	}
	return i;
}

final private simulated function RestoreActorProperties(Actor a)
{
	local int i;
	local bool b;
	if (a == None)
		return;
	for (i = ActorsProperties.Length-1; i > -1; i--)
	{
		if (ActorsProperties[i].PropertiesOwner == a)
		{
			if (!b)
			{
				RestoreSavedActorProperties(ActorsProperties[i]);
				b = true;
			}
			ActorsProperties.Remove(i, 1);
		}
	}
}

final private simulated function RestoreActorsProperties()
{
	local int i;
	local Array<Actor> RestoredActors;
	for (i = ActorsProperties.Length-1; i > -1; i--)
	{
		if (ActorsProperties[i].PropertiesOwner != None && RestoredActors.Find(ActorsProperties[i].PropertiesOwner) < 0)
		{
			RestoreSavedActorProperties(ActorsProperties[i]);
			RestoredActors.AddItem(ActorsProperties[i].PropertiesOwner);
		}
	}
	ActorsProperties.Length = 0;
}

final static function bool RestoreSavedActorProperties(ActorProperties ap) //Returns true if any property value was changed.
{
	local bool b;
	local Pawn p;
	local Hat_Player ply;
	p = Pawn(ap.PropertiesOwner);
	if (p == None)
		return false;
	if (p.bCanBeBaseForPawns != ap.bCanBeBaseForPawns)
	{
		p.bCanBeBaseForPawns = ap.bCanBeBaseForPawns;
		b = true;
	}
	if (p.AccelRate != ap.AccelRate)
	{
		p.AccelRate = ap.AccelRate;
		b = true;
	}
	if (p.Mesh != None)
	{
		if (p.Mesh.Scale != ap.MeshScale)
		{
			p.Mesh.SetScale(ap.MeshScale);
			b = true;
		}
		if (p.Mesh.Scale3D != ap.MeshScale3D)
		{
			p.Mesh.SetScale3D(ap.MeshScale3D);
			b = true;
		}
	}
	ply = Hat_Player(p);
	if (ply != None)
	{
		switch(ap.PlayerAnimationType)
		{
			case Type_Sandmobile:
				ply.OnExitVehicleClassAnim();
				ply.SetSandmobileAnim(ESandmobileAnim_None, 0.0);
				b = true;
				break;
			case Type_AnimNodes:
				SetAnimNodesByNameActive(ply.Mesh, default.ScooterAnimNodesName, false);
				b = true;
				break;
			case Type_TauntNodes:
				ply.SetTauntAnim("", string(default.ScooterAnimNodesName));
				b = true;
				break;
			case Type_CustomAnimation:
				ply.PlayCustomAnimation('');
				b = true;
				break;
			default:
				break;
		}
	}
	return b;
}

final private simulated function int IterateActorsProperties() //Returns index of Array position with Owner in PropertiesOwner variable.
{
	local int i, j;
	j = -1;
	for (i = ActorsProperties.Length-1; i > -1; i--)
	{
		if (ActorsProperties[i].PropertiesOwner == None)
		{
			ActorsProperties.Remove(i, 1);
			continue;
		}
		if (ActorsProperties[i].PropertiesOwner == Owner)
		{
			if (j < 0)
				j = i;
			else //A dupe.
				ActorsProperties.Remove(i, 1);
			continue;
		}
		RestoreSavedActorProperties(ActorsProperties[i]);
		ActorsProperties.Remove(i, 1);
	}
	return j;
}

simulated function OnAdded(Actor a)
{
	local int i;
	local Hat_Player ply;
	RestoreActorProperties(a);
	if (!CanRidePokemon(a, false, true, true))
		return;
	ply = Hat_Player(a);
	ply.RemoveStatusEffect(class'Hat_StatusEffect_Squished', true);
	ply.RemoveStatusEffect(class'Hat_StatusEffect_Shrink', true);
	ply.BounceAnimation(0.0);
	i = SaveActorProperties(ply);
	Super(Hat_StatusEffect).OnAdded(ply);
	ScooterMeshComp = CreateScooterMesh(ply, ply.Mesh);
	if (ScooterMeshComp == None)
	{
		ply.ClientMessage("Failed to create ScooterMeshComp - "@GetLocalName()@"will be removed.");
		return;
	}
	if (ScooterAnimNodesName != '')
	{
		if (SetAnimNodesByNameActive(ply.Mesh, ScooterAnimNodesName, true))
			ActorsProperties[i].PlayerAnimationType = Type_AnimNodes;
		else if (ply.SetTauntAnim(string(ScooterAnimNodesName)))
			ActorsProperties[i].PlayerAnimationType = Type_TauntNodes;
		else
		{
			if (ScooterLoopAnimation != '')
			{
				if (ply.Mesh.FindAnimSequence(ScooterLoopAnimation) == None)
				{
					ply.ClientMessage("Failed to both activate at least one"@ScooterAnimNodesName@"Animation Node and find"@ScooterLoopAnimation@"loop Animation Sequence - "@GetLocalName()@"will be removed.");
					return;
				}
				if (ScooterIntroAnimation != '')
				{
					TimeUntilLoopAnimation = ply.Mesh.GetAnimLength(ScooterIntroAnimation);
					if (TimeUntilLoopAnimation <= 0.0)
					{
						ply.ClientMessage("Failed to both activate at least one"@ScooterAnimNodesName@"Animation Node and get length for"@ScooterIntroAnimation@"intro Animation Sequence - "@GetLocalName()@"will be removed.");
						return;
					}
					ply.PlayCustomAnimation(ScooterIntroAnimation);
				}
				else
				{
					TimeUntilLoopAnimation = 0.0;
					ply.PlayCustomAnimation(ScooterLoopAnimation, true);
				}
				ActorsProperties[i].PlayerAnimationType = Type_CustomAnimation;
			}
			else
			{
				ply.ClientMessage("Failed to activate at least one"@ScooterAnimNodesName@"Animation Node - "@GetLocalName()@"will be removed.");
				return;
			}
		}
	}
	else if (ScooterLoopAnimation != '')
	{
		if (ply.Mesh.FindAnimSequence(ScooterLoopAnimation) == None)
		{
			ply.ClientMessage("Failed to get length for"@ScooterLoopAnimation@"loop Animation Sequence - "@GetLocalName()@"will be removed.");
			return;
		}
		if (ScooterIntroAnimation != '')
		{
			TimeUntilLoopAnimation = ply.Mesh.GetAnimLength(ScooterIntroAnimation);
			if (TimeUntilLoopAnimation <= 0.0)
			{
				ply.ClientMessage("Failed to get length for"@ScooterIntroAnimation@"intro Animation Sequence - "@GetLocalName()@"will be removed.");
				return;
			}
			ply.PlayCustomAnimation(ScooterIntroAnimation);
		}
		else
		{
			TimeUntilLoopAnimation = 0.0;
			ply.PlayCustomAnimation(ScooterLoopAnimation, true);
		}
		ActorsProperties[i].PlayerAnimationType = Type_CustomAnimation;
	}
	else
	{
		ply.OnEnterVehicleClassAnim(class'Hat_VehicleScooter_Base');
		ply.SetSandmobileAnim(ESandmobileAnim_JumpIn);
		ActorsProperties[i].PlayerAnimationType = Type_Sandmobile;
	}
	if (!ply.bCanBeBaseForPawns && IsCollisionEnabled())
		ply.bCanBeBaseForPawns = true;
	if (ply.IdleTime <= 15.0)
		ply.IdleTime = 25.0;
	ply.AccelRate = 1500.0;
	ply.VehicleProperties.VehicleModeActive = true;
	ply.VehicleProperties.GroundTranslation = 0.0;
	if (ply.VehicleProperties.VehicleMeshComponent != None)
		ply.VehicleProperties.VehicleMeshComponent.DetachFromAny();
	ply.VehicleProperties.VehicleMeshComponent = ScooterMeshComp;
	ply.SetStepUpOffsetMesh(ScooterMeshComp);
	ply.ResetMoveSpeed();
	ply.bCanBeBaseForPawns = true;
	if (AppearParticle != None && ply.WorldInfo != None && ply.WorldInfo.MyEmitterPool != None)
		ply.WorldInfo.MyEmitterPool.SpawnEmitter(AppearParticle, ply.Location);
	if (SpeedDustParticle != None)
	{
		SpeedDustParticleComponent = new class'ParticleSystemComponent';
		if (SpeedDustParticleComponent != None)
		{
			SpeedDustParticleComponent.SetTemplate(SpeedDustParticle);
			SpeedDustParticleComponent.SetTranslation(vect(-25.0, 0.0, -30.0));
			SpeedDustParticleComponent.CastShadow = true;
			SpeedDustParticleComponent.bNoSelfShadow = true;
			SpeedDustParticleComponent.SetActive(false);
			ply.AttachComponent(SpeedDustParticleComponent);
		}
	}
	if (HonkParticle != None && ScooterMeshComp.GetSocketByName('Horn') != None)
	{
		HonkParticleComponent = new class'ParticleSystemComponent';
		if (HonkParticleComponent != None)
		{
			HonkParticleComponent.SetTemplate(HonkParticle);
			HonkParticleComponent.SetTranslation(vect(0.0, 0.0, 0.0));
			HonkParticleComponent.CastShadow = true;
			HonkParticleComponent.bNoSelfShadow = true;
			HonkParticleComponent.SetActive(false);
			ScooterMeshComp.AttachComponentToSocket(HonkParticleComponent, 'Horn');
		}
	}
	if (EngineSound != None)
		ply.AttachComponent(EngineSound);
	if (EngineDrivingSound != None)
		ply.AttachComponent(EngineDrivingSound);
	if (WindSound != None)
		ply.AttachComponent(WindSound);
	class'RideablePokemon_OnlinePartyHandler'.static.SendOnlinePartyCommand(GetLocalName()$"RideStart", ply, , ModInstance);
}

simulated function bool Update(float delta)
{
	local int i;
	local Hat_Player ply;
	local float PrevDuration;
	local Hat_PlayerController hpc;
	local bool ShouldPlayLoopAnimation;
	i = IterateActorsProperties();
	ply = Hat_Player(Owner);
	if (ply == None || ply.Mesh == None || ScooterMeshComp == None || ActorsProperties[i].PlayerAnimationType == Type_None)
	{
		RemoveStatusEffect(Owner, class'Hat_StatusEffect_BadgeScooter', true);
		return false;
	}
	if (i < 0)
		i = SaveActorProperties(ply);
	if (IsCollisionEnabled())
	{
		if (!ply.bCanBeBaseForPawns)
			ply.bCanBeBaseForPawns = true;
		if (!ScooterMeshComp.CollideActors || !ScooterMeshComp.BlockActors)
			ScooterMeshComp.SetActorCollision(true, true, ScooterMeshComp.AlwaysCheckCollision);
	}
	else
	{
		if (ply.bCanBeBaseForPawns && !ActorsProperties[i].bCanBeBaseForPawns)
			ply.bCanBeBaseForPawns = false;
		if (ScooterMeshComp.CollideActors || ScooterMeshComp.BlockActors)
			ScooterMeshComp.SetActorCollision(false, false, ScooterMeshComp.AlwaysCheckCollision);
	}
	if (ply.IdleTime <= 15.0)
		ply.IdleTime = 25.0;
	//New Scale stuff below.
	if (ScooterMeshComp.IsComponentAttached(ply.Mesh))
	{
		if (ply.Mesh.Scale != 1.0)
			ply.Mesh.SetScale(1.0);
		if (ply.Mesh.Scale3D != vect(1.0, 1.0, 1.0))
			ply.Mesh.SetScale3D(vect(1.0, 1.0, 1.0));
	}
	else
	{
		if (ply.Mesh.Scale != ActorsProperties[i].MeshScale)
			ply.Mesh.SetScale(ActorsProperties[i].MeshScale);
		if (ply.Mesh.Scale3D != ActorsProperties[i].MeshScale3D)
			ply.Mesh.SetScale3D(ActorsProperties[i].MeshScale3D);
	}
	if (ScooterMeshComp.Scale != ActorsProperties[i].MeshScale)
		ScooterMeshComp.SetScale(ActorsProperties[i].MeshScale);
	if (ScooterMeshComp.Scale3D != ActorsProperties[i].MeshScale3D)
		ScooterMeshComp.SetScale3D(ActorsProperties[i].MeshScale3D);
	//New Scale stuff above.
	if (TimeUntilLoopAnimation > 0.0)
	{
		TimeUntilLoopAnimation = FMax(0.0, TimeUntilLoopAnimation-FMax(0.0, delta));
		if (TimeUntilLoopAnimation == 0.0)
			ShouldPlayLoopAnimation = true;
	}
	PrevDuration = CurrentDuration;
	if (!Super(Hat_StatusEffect).Update(delta))
		return false;
	if (HonkCooldown > 0.0)
	{
		if (HonkCooldown > 0.3)
		{
			HonkCooldown = FMax(0.0, HonkCooldown-FMax(0.0, delta));
			if (HonkCooldown <= 0.3 && HonkParticleComponent != None)
				HonkParticleComponent.SetActive(false);
		}
		else
			HonkCooldown = FMax(0.0, HonkCooldown-FMax(0.0, delta));
		if (HonkCooldown == 0.0)
			SetPokemonIdle();
	}
	else
		HonkCooldown = 0.0;
	switch(ActorsProperties[i].PlayerAnimationType)
	{
		case Type_Sandmobile: //Standard Scooter Animation behavior - playing loop animation using Player's script when requested.
			if (CurrentDuration >= JumpInTime && PrevDuration < JumpInTime)
			{
				ply.SetSandmobileAnim(ESandmobileAnim_Landed);
				if (OnSitInVehicleSound != None)
					ply.PlaySound(OnSitInVehicleSound);
			}
			break;
		case Type_CustomAnimation: //Playing custom loop animation when requested.
			if (ShouldPlayLoopAnimation)
				ply.PlayCustomAnimation(ScooterLoopAnimation, true);
			break;
		default:
			break;
	}
	if (!StartAirYaw && ply.Physics == PHYS_Falling)
	{
		StartAirYaw = true;
		LastAirYaw = ply.Rotation.Yaw;
		TotalAirYaw = 0;
	}
	if (StartAirYaw && ply.Physics == PHYS_Falling)
	{
		i = TotalAirYaw;
		TotalAirYaw += ply.Rotation.Yaw-LastAirYaw;
		LastAirYaw = ply.Rotation.Yaw;
		if (Abs(TotalAirYaw) > 65536 && Abs(i) <= 65536)
		{
			hpc = Hat_PlayerController(class'Shara_SteamID_Tools_RPS'.static.GetPawnPlayerController(ply));
			if (hpc != None)
				hpc.UnlockAchievement(10);
		}
	}
	if (ply.Physics == PHYS_Walking)
		StartAirYaw = false;
	if (SpeedDustParticleComponent != None)
		SpeedDustParticleComponent.SetActive(ply.Physics == PHYS_Walking && AllowSpeedDustParticle(ply.Velocity, ply.GroundSpeed, true, ply.VehicleProperties.Throttle));
	UpdateSounds(delta);
	UpdateVisuals(class<Hat_Collectible_Skin_Wireframe>(class'Shara_SkinColors_Tools_Short_RPS'.static.GetCurrentSkin(ply)) != None, Hat_StatusEffect_Muddy(ply.GetStatusEffect(class'Hat_StatusEffect_Muddy', true)) != None);
	UpdateHealth(ply.Health);
	return true;
}

final static function bool AllowSpeedDustParticle(Vector Velocity, float GroundSpeed, optional bool UseThrottle, optional float Throttle) //Also used to determine whether to play Furret music or not.
{
	if (VSizeSq2D(Velocity) <= Square(0.5*GroundSpeed))
		return false;
	if (UseThrottle)
		return (Abs(Throttle) > 0.1);
	return true;
}

function bool OnDuck()
{
	return PerformScooterHonk();
}

function SetVehicleHonkAni(bool b, float blend_time)
{
	//Lol, nope.
}

function OnDoHonk()
{
	//Lol, nope.
}

final private simulated function bool PerformScooterHonk() //Returns false if Owner is None or its Physics is not PHYS_Walking.
{
	local Name AnimName;
	local Hat_Player ply;
	if (Owner == None || Owner.Physics != PHYS_Walking)
		return false;
	if (HonkCooldown > 0.0)
		return true;
	AnimName = GetRandomBattleActionAnimation();
	HonkCooldown = SetPokemonCustomBattleActionAnimation(ScooterMeshComp, AnimName);
	if (HonkCooldown <= 0.0)
		return true;
	if (HonkSound != None)
	{
		HonkCooldown = FMax(HonkCooldown, FMax(0.0, HonkSound.GetCueDuration()));
		ModifyPokemonFace(ScooterMeshComp, true);
		if (HonkParticleComponent != None)
			HonkParticleComponent.SetActive(true);
		Owner.PlaySound(HonkSound);
		ScareNearbyPawns(Owner, ShouldScarePlayers() && IsPokemonScaringAllowed());
	}
	SetPokemonAttackEmissionEffect(ScooterMeshComp, HonkCooldown);
	ply = Hat_Player(Owner);
	if (ply != None)
		class'RideablePokemon_OnlinePartyHandler'.static.SendOnlinePartyCommand(GetLocalName()$"Action"$AnimName, ply, , ModInstance);
	return true;
}

final static function PerformOnlineScooterHonk(Hat_GhostPartyPlayer gpp, Name AnimName)
{
	local float f;
	if (gpp == None || !IsPokemonMesh(gpp.ScooterMesh))
		return;
	if (AnimName == '')
	{
		ModifyPokemonFace(gpp.ScooterMesh, false);
		return;
	}
	f = SetPokemonCustomBattleActionAnimation(gpp.ScooterMesh, AnimName);
	if (f <= 0.0)
		return;
	if (default.HonkSound != None)
	{
		f = FMax(f, FMax(0.0, default.HonkSound.GetCueDuration()));
		ModifyPokemonFace(gpp.ScooterMesh, true);
		if (default.HonkParticle != None)
		{
			if (gpp.ScooterHornParticle == None)
			{
				if (gpp.ScooterMesh.GetSocketByName('Horn') != None)
				{
					gpp.ScooterHornParticle = new(gpp) class'ParticleSystemComponent';
					if (gpp.ScooterHornParticle != None)
					{
						gpp.ScooterHornParticle.SetTemplate(default.HonkParticle);
						gpp.ScooterHornParticle.CastShadow = true;
						gpp.ScooterHornParticle.bNoSelfShadow = true;
						gpp.ScooterMesh.AttachComponentToSocket(gpp.ScooterHornParticle, 'Horn');
					}
				}
			}
			else
			{
				if (gpp.ScooterHornParticle.Template != default.HonkParticle)
					gpp.ScooterHornParticle.SetTemplate(default.HonkParticle);
				if (!gpp.ScooterHornParticle.CastShadow)
					gpp.ScooterHornParticle.CastShadow = true;
				if (!gpp.ScooterHornParticle.bNoSelfShadow)
					gpp.ScooterHornParticle.bNoSelfShadow = true;
			}
			if (gpp.ScooterHornParticle != None)
				gpp.ScooterHornParticle.SetActive(true);
		}
		gpp.PlaySound(default.HonkSound);
		if (ShouldScarePlayers() && IsPokemonScaringAllowed())
			GhostPartyScareNearbyPlayers(gpp);
	}
	SetPokemonAttackEmissionEffect(gpp.ScooterMesh, f);
}

final private simulated function UpdateVisuals(bool IsPlayerWireframe, bool IsPlayerMuddy, optional bool ForceUpdate)
{
	if (ForceUpdate || IsPlayerWireframe != IsWireframe)
	{
		if (IsPlayerWireframe)
		{
			SetPokemonWireframeMaterials(ScooterMeshComp);
			class'RideablePokemon_OnlinePartyHandler'.static.SendOnlinePartyCommand(GetLocalName()$"Wireframe", Hat_Player(Owner), , ModInstance);
			IsWireframe = true;
		}
		else
		{
			SetPokemonStandardMaterials(ScooterMeshComp);
			class'RideablePokemon_OnlinePartyHandler'.static.SendOnlinePartyCommand(GetLocalName()$"Standard", Hat_Player(Owner), , ModInstance);
			IsWireframe = false;
		}
	}
	if (ForceUpdate || IsPlayerMuddy != IsMuddy)
	{
		if (IsPlayerMuddy)
		{
			SetPokemonMuddyEffect(ScooterMeshComp, true);
			class'RideablePokemon_OnlinePartyHandler'.static.SendOnlinePartyCommand(GetLocalName()$"Muddy", Hat_Player(Owner), , ModInstance);
			IsMuddy = true;
		}
		else
		{
			SetPokemonMuddyEffect(ScooterMeshComp, false);
			class'RideablePokemon_OnlinePartyHandler'.static.SendOnlinePartyCommand(GetLocalName()$"Clean", Hat_Player(Owner), , ModInstance);
			IsMuddy = false;
		}
	}
}

final static function GetMuddyColors(out LinearColor ColorLight, out LinearColor ColorDark)
{
	if (class'Hat_GameManager_Base'.static.GetCurrentMapFilename() ~= "mafia_town_night")
	{
		ColorLight = MakeLinearColor(0.27, 0.075, 0.0, 1.0);
		ColorDark = MakeLinearColor(0.216, 0.06, 0.0, 1.0);
	}
	else
	{
		ColorLight = MakeLinearColor(0.144, 0.04, 0.0, 1.0);
		ColorDark = MakeLinearColor(0.072, 0.02, 0.0, 1.0);
	}
}

static function SetPokemonMuddyEffect(SkeletalMeshComponent comp, bool b)
{
	SetMuddyEffectMesh(comp, b);
}

final static function SetMuddyEffectMesh(MeshComponent comp, bool b)
{
	local int i;
	local MaterialInstance inst;
	local InterpCurveFloat Curve;
	local MaterialInstanceTimeVarying MITV;
	local LinearColor ColorLight, ColorDark;
	if (comp == None)
		return;
	GetMuddyColors(ColorLight, ColorDark);
	Curve = class'Hat_Math'.static.GenerateCurveFloat((b ? 0.0 : 1.0), (b ? 1.0 : 0.0), (b ? 0.2 : 0.5));
	for (i = 0; i < comp.GetNumElements(); i++)
	{
		inst = MaterialInstance(comp.GetMaterial(i));
		if (inst == None || !inst.IsInMapOrTransientPackage())
			continue;
		inst.SetVectorParameterValue('GoopColorLight', ColorLight);
		inst.SetVectorParameterValue('GoopColorDark', ColorDark);
		inst.SetScalarCurveParameterValue('MudVertexShader', Curve);
		inst.SetScalarCurveParameterValue('Goop', Curve);
		MITV = MaterialInstanceTimeVarying(inst);
		if (MITV != None)
		{
			MITV.SetScalarStartTime('MudVertexShader', 0.0);
			MITV.SetScalarStartTime('Goop', 0.0);
		}
	}
}

static function SetPokemonAttackEmissionEffect(SkeletalMeshComponent comp, float EffectDuration)
{
	SetAttackEmissionEffectMesh(comp, EffectDuration);
}

final static function SetAttackEmissionEffectMesh(MeshComponent comp, float EffectDuration)
{
	if (EffectDuration > 0.0)
		class'Shara_SkinColors_Tools_Short_RPS'.static.SetTransitionEffectMesh(comp, 'AttackEmission', 0.0, 0.0, EffectDuration, 1.0, 0.5*EffectDuration);
}

static function bool SetPokemonWireframeMaterials(SkeletalMeshComponent comp)
{
	local int i;
	local MaterialInstance inst;
	local Array<MaterialInterface> mats;
	if (!IsPokemonMesh(comp))
		return false;
	mats = GetPokemonWireframeMaterials(comp.SkeletalMesh);
	if (mats.Length < 1)
		return false;
	for (i = 0; i < Min(comp.GetNumElements(), mats.Length); i++)
	{
		inst = MaterialInstance(comp.GetMaterial(i));
		if (inst != None && inst.IsInMapOrTransientPackage())
			inst.SetParent(mats[i]);
		else
			comp.SetMaterial(i, mats[i]);
	}
	return true;
}

static function bool SetPokemonStandardMaterials(SkeletalMeshComponent comp)
{
	if (!IsPokemonMesh(comp))
		return false;
	class'Shara_SkinColors_Tools_Short_RPS'.static.ResetMaterials(comp, true, true);
	return true;
}

final static function CloneMeshComponentMaterials(MeshComponent compOriginal, MeshComponent compClone)
{
	local int i;
	local MaterialInterface mat;
	local MaterialInstance inst;
	if (compOriginal == None || compClone == None)
		return;
	for (i = 0; i < compOriginal.Materials.Length; i++)
	{
		mat = compOriginal.GetMaterial(i);
		inst = MaterialInstance(mat);
		if (inst == None || !inst.IsInMapOrTransientPackage())
		{
			compClone.SetMaterial(i, mat);
			continue;
		}
		inst = new(compClone) inst.Class(inst);
		if (inst == None)
		{
			compClone.SetMaterial(i, class'Shara_SkinColors_Tools_Short_RPS'.static.GetActualMaterial(mat));
			continue;
		}
		inst.SetParent(class'Shara_SkinColors_Tools_Short_RPS'.static.GetActualMaterial(mat));
		compClone.SetMaterial(i, inst);
	}
}

simulated function OnRemoved(Actor a)
{
	local Hat_Player ply;
	RestoreActorProperties(a);
	ply = Hat_Player(a);
	if (ply != None)
	{
		ply.VehicleProperties.VehicleModeActive = false;
		ply.VehicleProperties.VehicleMeshComponent = None;
		ply.SetStepUpOffsetMesh(None);
		ply.ResetMoveSpeed();
		if (ply.Mesh != None)
			ply.AttachComponent(ply.Mesh);
		if (ExplodeParticle != None && ply.WorldInfo != None && ply.WorldInfo.MyEmitterPool != None)
			ply.WorldInfo.MyEmitterPool.SpawnEmitter(ExplodeParticle, ply.Location);
		if (ExplodeSound != None)
			ply.PlaySound(ExplodeSound);
	}
	if (ScooterMeshComp != None)
	{
		ScooterMeshComp.DetachFromAny();
		ScooterMeshComp = None;
	}
	if (SpeedDustParticleComponent != None)
	{
		SpeedDustParticleComponent.DetachFromAny();
		SpeedDustParticleComponent = None;
	}
	if (HonkParticleComponent != None)
	{
		HonkParticleComponent.DetachFromAny();
		HonkParticleComponent = None;
	}
	if (EngineSound != None)
	{
		EngineSound.DetachFromAny();
		EngineSound = None;
	}
	if (EngineDrivingSound != None)
	{
		EngineDrivingSound.DetachFromAny();
		EngineDrivingSound = None;
	}
	if (WindSound != None)
	{
		WindSound.DetachFromAny();
		WindSound = None;
	}
	if (ply != None)
		class'RideablePokemon_OnlinePartyHandler'.static.SendOnlinePartyCommand(GetLocalName()$"RideStop", ply, , ModInstance);
	Super(Hat_StatusEffect).OnRemoved(a);
}

simulated function CleanUp()
{
	RestoreActorsProperties();
	Super.CleanUp();
}

final private simulated function UpdateHealth(int h)
{
	local Name AnimName;
	h = Clamp(h, 0, 4);
	if (h == Health)
		return;
	if (h < Health)
		AnimName = GetRandomBattleDamageAnimation();
	SetPokemonHealth(ScooterMeshComp, h, AnimName);
	Health = h;
	class'RideablePokemon_OnlinePartyHandler'.static.SendOnlinePartyCommand(GetLocalName()$"Health"$(AnimName != '' ? "_"$AnimName : ""), Hat_Player(Owner), , ModInstance);
}

final static function SetPokemonHealth(SkeletalMeshComponent comp, int h, Name AnimName)
{
	ModifyPokemonEyes(comp, h);
	SetPokemonCustomBattleActionAnimation(comp, AnimName);
	SetAnimNodesByNameActive(comp, 'LowHealth', h < 2);
}

final static function Name GetRandomBattleActionAnimation()
{
	local int i;
	local Array<Name> AnimsList;
	local BattleActionAnims baa;
	baa = GetBattleActionAnims();
	for (i = 0; i < baa.CryingAnims.Length; i++)
		AnimsList.AddItem(baa.CryingAnims[i]);
	for (i = 0; i < baa.PhysicalAttackAnims.Length; i++)
		AnimsList.AddItem(baa.PhysicalAttackAnims[i]);
	for (i = 0; i < baa.SpecialAttackAnims.Length; i++)
		AnimsList.AddItem(baa.SpecialAttackAnims[i]);
	if (AnimsList.Length < 0)
		return '';
	return AnimsList[Rand(AnimsList.Length)];
}

final static function Name GetRandomBattleDamageAnimation()
{
	local BattleActionAnims baa;
	baa = GetBattleActionAnims();
	return baa.TakingDamageAnims[Rand(baa.TakingDamageAnims.Length)];
}

final static function float SetPokemonCustomBattleActionAnimation(SkeletalMeshComponent comp, Name AnimName)
{
	local float f;
	local AnimNodePlayCustomAnim CustomAnimNode;
	if (comp == None || AnimName == '' || comp.Animations == None || comp.FindAnimSequence(AnimName) == None)
		return 0.0;
	f = 0.0;
	foreach comp.AllAnimNodes(class'AnimNodePlayCustomAnim', CustomAnimNode)
	{
		if (CustomAnimNode == None || CustomAnimNode.NodeName != 'BattleActionAnim')
			continue;
		f = FMax(f, CustomAnimNode.PlayCustomAnim(AnimName, 1.0, 0.5, 0.5, false, true));
	}
	return f;
}

final private simulated function SetPokemonIdle()
{
	local Hat_Player ply;
	ModifyPokemonFace(ScooterMeshComp, false);
	ply = Hat_Player(Owner);
	if (ply != None)
		class'RideablePokemon_OnlinePartyHandler'.static.SendOnlinePartyCommand(GetLocalName()$"Idle", ply, , ModInstance);
}

static function bool ModifyPokemonEyes(SkeletalMeshComponent comp, int h)
{
	return false;
}

static function bool ModifyPokemonFace(SkeletalMeshComponent comp, bool DoesScream)
{
	return false;
}

final static function bool SetAnimNodesByNameActive(SkeletalMeshComponent comp, Name n, bool b)
{
	local int i;
	local bool bb;
	local Array<AnimNode> AnimNodes;
	if (n == '')
		return false;
	if (comp == None || comp.Animations == None)
		return false;
	AnimNodes = comp.FindAnimNodesByName(n);
	for (i = 0; i < AnimNodes.Length; i++)
	{
		if (SetAnimNodeActive(AnimNodeBlendBase(AnimNodes[i]), b, 0.1))
			bb = true;
	}
	return bb;
}

final static function bool SetAnimNodeActive(AnimNodeBlendBase anbb, bool b, float DefaultTime)
{
	local AnimNodeBlend anb;
	local AnimNodeBlendList anbl;
	local Hat_AnimBlendBase habb;
	if (anbb == None || anbb.Children.Length < 2)
		return false;
	anbl = AnimNodeBlendList(anbb);
	if (anbl != None)
	{
		if (anbl.ActiveChildIndex == int(b))
			return true;
		habb = Hat_AnimBlendBase(anbl);
		if (habb != None)
			habb.SetActiveChild(int(b), habb.GetBlendTime(int(b)));
		else
			anbl.SetActiveChild(int(b), FMax(0.0, DefaultTime));
		return true;
	}
	anb = AnimNodeBlend(anbb);
	if (anb == None)
		return false;
	if (anb.Child2Weight != float(b))
		anb.SetBlendTarget(float(b), FMax(0.0, DefaultTime));
	return true;
}

final static function ScareNearbyPawns(Actor a, bool CanScarePlayers)
{
	local WorldInfo wi;
	local Hat_Player ply;
	local Hat_PawnCombat p;
	if (a == None)
		return;
	wi = (a.WorldInfo != None ? a.WorldInfo : class'WorldInfo'.static.GetWorldInfo());
	if (wi == None)
		return;
	foreach wi.AllPawns(class'Hat_PawnCombat', p, a.Location, 600.0/0.7)
	{
		if (p == None)
			continue;
		if (p == a)
			continue;
		if (p.bHidden)
			continue;
		if (VSizeSq((p.Location-a.Location)*vect(1.0, 1.0, 0.7)) > 360000.0)
			continue;
		ply = Hat_Player(p);
		if (ply != None)
		{
			if (CanScarePlayers)
				ScarePlayer(ply);
		}
		else
			ScareMafia(Hat_Enemy_Mobster_Base(p));
	}
}

final static function GhostPartyScareNearbyPlayers(Hat_GhostPartyPlayer gpp) //Only used with Hat_GhostPartyPlayer.
{
	local WorldInfo wi;
	local Hat_Player ply;
	if (gpp == None)
		return;
	wi = (gpp.WorldInfo != None ? gpp.WorldInfo : class'WorldInfo'.static.GetWorldInfo());
	if (wi == None)
		return;
	foreach wi.AllPawns(class'Hat_Player', ply, gpp.Location, 600.0/0.7)
	{
		if (ply == None)
			continue;
		if (VSizeSq((ply.Location-gpp.Location)*vect(1.0, 1.0, 0.7)) > 360000.0)
			continue;
		ScarePlayer(ply);
	}
}

final static function ScarePlayer(Hat_Player ply)
{
	local PlayerController pc;
	local Hat_PlayerController hpc;
	if (ply == None)
		return;
	if (ply.Health < 1)
		return;
	if (ply.IsDead)
		return;
	if (ply.IsBlinking())
		return;
	if (ply.IsTaunting())
		return;
	if (ply.HasStatusEffect(class'Hat_StatusEffect_Stoning', true))
		return;
	if (ply.HasStatusEffect(class'Hat_StatusEffect_StatueFall', true))
		return;
	if (ply.HasStatusEffect(class'Hat_StatusEffect_BadgeScooter', true))
		return;
	pc = class'Shara_SteamID_Tools_RPS'.static.GetPawnPlayerController(ply);
	if (pc != None)
	{
		if (pc.bCinematicMode)
			return;
		if (pc.IsPaused())
			return;
		hpc = Hat_PlayerController(pc);
		if (hpc != None && hpc.IsTalking())
			return;
	}
	ply.GiveStatusEffect(class'Hat_StatusEffect_Scared');
}

final static function ScareMafia(Hat_Enemy_Mobster_Base m)
{
	if (m != None)
		m.GiveStatusEffect(class'Hat_StatusEffect_VehicleHonkScared');
}

static function bool IsTiedToFlair()
{
	return false;
}

static function bool IsDebugOnly()
{
	return false;
}

static function bool ShouldScarePlayers()
{
	return false;
}

static function SkeletalMesh GetPokemonSkeletalMesh()
{
	return default.ScooterMesh;
}

static function PhysicsAsset GetPokemonPhysicsAsset(SkeletalMesh sm)
{
	return default.ScooterPhysics;
}

static function Array<MaterialInterface> GetPokemonWireframeMaterials(SkeletalMesh sm)
{
	return default.WireframeMaterials;
}

static function bool IsPokemonMesh(SkeletalMeshComponent comp)
{
	if (comp == None)
		return false;
	switch(comp.SkeletalMesh)
	{
		case None:
			return false;
		case default.ScooterMesh:
			return true;
		default:
			return false;
	}
}

defaultproperties
{
	ScooterPhysicsAssetInstance = true
	Health = 4
	WheelStopLeftSound = None
	WheelStopRightSound = None
	SpeedDustParticle = None
	WindSound = None
	EngineSound = None
	EngineDrivingSound = None
}