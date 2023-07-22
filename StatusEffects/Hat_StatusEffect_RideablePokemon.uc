class Hat_StatusEffect_RideablePokemon extends Hat_StatusEffect_BadgeScooter
	abstract;

const HealthMax = 4;

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
	var float AccelRate; //Pawn only.
};

var const AnimSet ScooterAnimSet;
var const Name ScooterAnimNodesName, ScooterIntroAnimation, ScooterLoopAnimation;
var const Array<MaterialInterface> WireframeMaterials;
var const bool PokemonScaresPlayers, DebugOnly, TiedToFlair;
var protectedwrite transient float ScooterScale, TimeUntilLoopAnimation;
var protectedwrite transient Vector ScooterScale3D;
var protectedwrite transient int Health;
var protectedwrite transient AnimationType PlayerAnimationType; 
var protected transient RideablePokemon_Script ModInstance;
var protected transient Array<ActorProperties> ActorsProperties;
var protectedwrite transient bool IsWireframe, IsMuddy;
var protectedwrite transient class<Hat_StatusEffect_Muddy> CurrentMuddyStatus;
var const RBCollisionChannelContainer ScooterCollisionContainer;

static function bool IsCollisionEnabled()
{
	return class'RideablePokemon_Script'.static.IsCollisionEnabled();
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
	MeshComponent.SetPhysicsAsset(default.ScooterPhysics);
	MeshComponent.SetTranslation(default.ScooterTranslation);
	MeshComponent.SetLightEnvironment(InComponent.LightEnvironment);
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
	class'Shara_SkinColors_Tools_Short_RPS'.static.ResetMaterials(comp);
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
	comp.SetRBCollisionChannels(default.ScooterCollisionContainer);
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
	local bool UpdateAnims;
	if (comp == None)
		return;
	if (comp.SkeletalMesh != default.ScooterMesh)
		comp.SetSkeletalMesh(default.ScooterMesh);
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
	if (default.ScooterAnimTree != None)
	{
		if (comp.AnimTreeTemplate != default.ScooterAnimTree)
		{
			comp.SetAnimTreeTemplate(default.ScooterAnimTree);
			UpdateAnims = true;
		}
	}
	else
	{
		if (comp.AnimTreeTemplate != None)
		{
			comp.SetAnimTreeTemplate(None);
			UpdateAnims = true;
		}
	}
	if (UpdateAnims)
		comp.UpdateAnimations();
}

final static function string GetLocalName()
{
	return Mid(string(default.Class.Name), 25);
}

final static function bool CanRidePokemon(Actor a, bool CheckAnimations, bool DoSendMessage, optional bool UseLocalName)
{
	local Array<AnimNode> AnimNodes;
	local Hat_PawnCombat p;
	local Hat_Player ply;
	local Hat_StatusEffect_RideablePokemon PokemonStatus;
	local string s;
	local int i, j;
	local AnimNodeBlendBase anbb;
	local bool b;
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
	if (default.DebugOnly && !class'RideablePokemon_Script'.static.IsDev())
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
			}
			if (!b)
			{
				AnimNodes = ply.Mesh.FindAnimNodesByName(default.ScooterAnimNodesName);
				for (i = 0; i < AnimNodes.Length; i++)
				{
					anbb = AnimNodeBlendBase(AnimNodes[i]);
					if (anbb == None || anbb.Children.Length < 2)
						continue;
					if (AnimNodeBlend(anbb) != None || AnimNodeBlendList(anbb) != None)
					{
						b = true;
						break;
					}
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
	for (i = 0; i < ply.StatusEffects.Length; i++)
	{
		if (ply.StatusEffects[i] == None || ply.StatusEffects[i].Removed || ply.StatusEffects[i].IsExpired() || Hat_StatusEffect_BadgeScooter(ply.StatusEffects[i]) == None || ply.StatusEffects[i].Class == default.Class)
			continue;
		PokemonStatus = Hat_StatusEffect_RideablePokemon(ply.StatusEffects[i]);
		if (PokemonStatus != None)
		{
			if (DoSendMessage)
				ply.ClientMessage("You can't ride"@s@"because you are already riding"@PokemonStatus.GetLocalName()$".");
		}
		else if (DoSendMessage)
			ply.ClientMessage("You can't ride"@s@"because you are already riding Scooter.");
		return false;
	}
	return true;
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
	if (default.TiedToFlair)
		return (PlayerHat.MyItemQualityInfo.default.StatusEffectOverride == default.Class);
	return true;
}

final static function Hat_Ability_Trigger GetPlayerHat(Actor a)
{
	local int i;
	local Hat_Ability_Trigger HatActor;
	local Hat_Player ply;
	local Hat_InventoryManager invm;
	local Hat_NPC_Player npc;
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

final simulated function int SaveActorProperties(Actor a)
{
	local int i;
	local ActorProperties ap;
	local Pawn p;
	if (a == None)
		return -1;
	ap.PropertiesOwner = a;
	p = Pawn(a);
	if (p != None)
	{
		ap.bCanBeBaseForPawns = p.bCanBeBaseForPawns;
		ap.AccelRate = p.AccelRate;
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

final simulated function RestoreActorProperties(Actor a)
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

final simulated function RestoreActorsProperties()
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
	local Pawn p;
	local bool b;
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
	return b;
}

final simulated function int IterateActorsProperties() //Returns index of Array position with Owner in PropertiesOwner variable.
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
	local Hat_Player ply;
	RestoreActorProperties(a);
	if (!CanRidePokemon(a, false, true, true))
	{
		RemoveStatusEffect(a, class'Hat_StatusEffect_BadgeScooter', true);
		return;
	}
	ply = Hat_Player(a);
	ply.RemoveStatusEffect(class'Hat_StatusEffect_Squished', true);
	ply.RemoveStatusEffect(class'Hat_StatusEffect_Shrink', true);
	ply.BounceAnimation(0.0);
	Super(Hat_StatusEffect).OnAdded(ply);
	ScooterMeshComp = CreateScooterMesh(ply, ply.Mesh);
	if (ScooterMeshComp == None)
	{
		ply.ClientMessage("Failed to create ScooterMeshComp - "@GetLocalName()@"will be removed.");
		RemoveStatusEffect(ply, class'Hat_StatusEffect_BadgeScooter', true);
		return;
	}
	ScooterScale = ScooterMeshComp.Scale;
	ScooterScale3D = ScooterMeshComp.Scale3D;
	if (ScooterAnimNodesName != '')
	{
		if (SetAnimNodesByNameActive(ply.Mesh, ScooterAnimNodesName, true))
			PlayerAnimationType = Type_AnimNodes;
		else if (ply.SetTauntAnim(string(ScooterAnimNodesName)))
			PlayerAnimationType = Type_TauntNodes;
		else
		{
			if (ScooterLoopAnimation != '')
			{
				if (ply.Mesh.FindAnimSequence(ScooterLoopAnimation) == None)
				{
					ply.ClientMessage("Failed to both activate at least one"@ScooterAnimNodesName@"Animation Node and find"@ScooterLoopAnimation@"loop Animation Sequence - "@GetLocalName()@"will be removed.");
					RemoveStatusEffect(ply, class'Hat_StatusEffect_BadgeScooter', true);
					return;
				}
				if (ScooterIntroAnimation != '')
				{
					TimeUntilLoopAnimation = ply.Mesh.GetAnimLength(ScooterIntroAnimation);
					if (TimeUntilLoopAnimation <= 0.0)
					{
						ply.ClientMessage("Failed to both activate at least one"@ScooterAnimNodesName@"Animation Node and get length for"@ScooterIntroAnimation@"intro Animation Sequence - "@GetLocalName()@"will be removed.");
						RemoveStatusEffect(ply, class'Hat_StatusEffect_BadgeScooter', true);
						return;
					}
					ply.PlayCustomAnimation(ScooterIntroAnimation);
				}
				else
				{
					TimeUntilLoopAnimation = 0.0;
					ply.PlayCustomAnimation(ScooterLoopAnimation, true);
				}
				PlayerAnimationType = Type_CustomAnimation;
			}
			else
			{
				ply.ClientMessage("Failed to activate at least one"@ScooterAnimNodesName@"Animation Node - "@GetLocalName()@"will be removed.");
				RemoveStatusEffect(ply, class'Hat_StatusEffect_BadgeScooter', true);
				return;
			}
		}
	}
	else if (ScooterLoopAnimation != '')
	{
		if (ply.Mesh.FindAnimSequence(ScooterLoopAnimation) == None)
		{
			ply.ClientMessage("Failed to get length for"@ScooterLoopAnimation@"loop Animation Sequence - "@GetLocalName()@"will be removed.");
			RemoveStatusEffect(ply, class'Hat_StatusEffect_BadgeScooter', true);
			return;
		}
		if (ScooterIntroAnimation != '')
		{
			TimeUntilLoopAnimation = ply.Mesh.GetAnimLength(ScooterIntroAnimation);
			if (TimeUntilLoopAnimation <= 0.0)
			{
				ply.ClientMessage("Failed to get length for"@ScooterIntroAnimation@"intro Animation Sequence - "@GetLocalName()@"will be removed.");
				RemoveStatusEffect(ply, class'Hat_StatusEffect_BadgeScooter', true);
				return;
			}
			ply.PlayCustomAnimation(ScooterIntroAnimation);
		}
		else
		{
			TimeUntilLoopAnimation = 0.0;
			ply.PlayCustomAnimation(ScooterLoopAnimation, true);
		}
		PlayerAnimationType = Type_CustomAnimation;
	}
	else
	{
		ply.OnEnterVehicleClassAnim(class'Hat_VehicleScooter_Base');
		ply.SetSandmobileAnim(ESandmobileAnim_JumpIn);
		PlayerAnimationType = Type_Sandmobile;
	}
	SaveActorProperties(ply);
	if (!ply.bCanBeBaseForPawns && IsCollisionEnabled())
		ply.bCanBeBaseForPawns = true;
	if (ply.IdleTime <= 15.0)
		ply.IdleTime = 25.0;
	ply.AccelRate = 1500.0;
	ply.VehicleProperties.VehicleModeActive = true;
	ply.VehicleProperties.GroundTranslation = 0.0;
	ply.VehicleProperties.VehicleMeshComponent = ScooterMeshComp;
	ply.SetStepUpOffsetMesh(ScooterMeshComp);
	ply.ResetMoveSpeed();
	ply.bCanBeBaseForPawns = true;
	if (AppearParticle != None && ply.WorldInfo != None && ply.WorldInfo.MyEmitterPool != None)
		ply.Worldinfo.MyEmitterPool.SpawnEmitter(AppearParticle, ply.Location);
	if (SpeedDustParticle != None)
	{
		SpeedDustParticleComponent = new class'ParticleSystemComponent';
		SpeedDustParticleComponent.SetTemplate(SpeedDustParticle);
		SpeedDustParticleComponent.SetTranslation(vect(-25.0, 0.0, -30.0));
		SpeedDustParticleComponent.CastShadow = true;
		SpeedDustParticleComponent.bNoSelfShadow = true;
		SpeedDustParticleComponent.SetActive(false);
		ply.AttachComponent(SpeedDustParticleComponent);
	}
	if (HonkParticle != None && ScooterMeshComp.GetSocketByName('Horn') != None)
	{
		HonkParticleComponent = new class'ParticleSystemComponent';
		HonkParticleComponent.SetTemplate(HonkParticle);
		HonkParticleComponent.SetTranslation(vect(0.0, 0.0, 0.0));
		HonkParticleComponent.CastShadow = true;
		HonkParticleComponent.bNoSelfShadow = true;
		HonkParticleComponent.SetActive(false);
		ScooterMeshComp.AttachComponentToSocket(HonkParticleComponent, 'Horn');
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
	local float PrevDuration;
	local int i;
	local Hat_Player ply;
	local Hat_PlayerController hpc;
	local bool ShouldPlayLoopAnimation;
	i = IterateActorsProperties();
	ply = Hat_Player(Owner);
	if (ply == None || ply.Mesh == None)
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
		if (ScooterMeshComp != None && (!ScooterMeshComp.CollideActors || !ScooterMeshComp.BlockActors))
			ScooterMeshComp.SetActorCollision(true, true, ScooterMeshComp.AlwaysCheckCollision);
	}
	else
	{
		if (ply.bCanBeBaseForPawns && !ActorsProperties[i].bCanBeBaseForPawns)
			ply.bCanBeBaseForPawns = false;
		if (ScooterMeshComp != None && (ScooterMeshComp.CollideActors || ScooterMeshComp.BlockActors))
			ScooterMeshComp.SetActorCollision(false, false, ScooterMeshComp.AlwaysCheckCollision);
	}
	if (ply.IdleTime <= 15.0)
		ply.IdleTime = 25.0;
	//New Scale stuff below.
	if (ply.Mesh.Scale != 1.0)
		ply.Mesh.SetScale(1.0);
	if (ply.Mesh.Scale3D != vect(1.0, 1.0, 1.0))
		ply.Mesh.SetScale3D(vect(1.0, 1.0, 1.0));
	if (ScooterMeshComp != None)
	{
		if (ScooterMeshComp.Scale != ScooterScale)
			ScooterMeshComp.SetScale(ScooterScale);
		if (ScooterMeshComp.Scale3D != ScooterScale3D)
			ScooterMeshComp.SetScale3D(ScooterScale3D);
	}
	//New Scale stuff above.
	if (TimeUntilLoopAnimation > 0.0)
	{
		TimeUntilLoopAnimation = FMax(0.0, TimeUntilLoopAnimation-Abs(delta));
		if (TimeUntilLoopAnimation == 0.0)
			ShouldPlayLoopAnimation = true;
	}
	PrevDuration = CurrentDuration;
	if (!Super(Hat_StatusEffect).Update(delta))
		return false;
	if (HonkCooldown > 0.0)
	{
		HonkCooldown = FMax(0.0, HonkCooldown-Abs(delta));
		if (delta != 0.0)
		{
			if (HonkCooldown <= 0.3)
			{
				if (HonkParticleComponent != None)
					HonkParticleComponent.SetActive(false);
				if (HonkCooldown == 0.0)
					SetPokemonIdle();
			}
		}
	}
	else
		HonkCooldown = 0.0;
	switch(PlayerAnimationType)
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
		SpeedDustParticleComponent.SetActive(ply.Physics == PHYS_Walking && VSizeSq2D(ply.Velocity) > 0.25*ply.GroundSpeed*ply.GroundSpeed && Abs(ply.VehicleProperties.Throttle) > 0.1);
	UpdateSounds(delta);
	UpdateVisuals(class<Hat_Collectible_Skin_Wireframe>(class'Shara_SkinColors_Tools_Short_RPS'.static.GetCurrentSkin(ply)) != None, Hat_StatusEffect_Muddy(ply.GetStatusEffect(class'Hat_StatusEffect_Muddy', true)) != None);
	UpdateHealth(ply.Health);
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

final simulated function bool PerformScooterHonk() //Returns false if Owner is None or its Physics is not PHYS_Walking.
{
	local Hat_Player ply;
	local Name AnimName;
	if (Owner == None)
		return false;
	if (Owner.Physics != PHYS_Walking)
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
		ScareNearbyPawns(Owner, PokemonScaresPlayers && ModInstance != None && ModInstance.AllowPokemonScaring == 0);
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
	if (gpp == None || gpp.ScooterMesh == None)
		return;
	if (gpp.ScooterMesh.SkeletalMesh != default.ScooterMesh)
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
			if (gpp.ScooterHornParticle == None && gpp.ScooterMesh.GetSocketByName('Horn') != None)
			{
				gpp.ScooterHornParticle = new(gpp) class'ParticleSystemComponent';
				if (gpp.ScooterHornParticle != None)
				{
					gpp.ScooterHornParticle.SetTemplate(default.HonkParticle);
					gpp.ScooterHornParticle.SetTranslation(vect(0.0, 0.0, 0.0));
					gpp.ScooterHornParticle.CastShadow = true;
					gpp.ScooterHornParticle.bNoSelfShadow = true;
					gpp.ScooterMesh.AttachComponentToSocket(gpp.ScooterHornParticle, 'Horn');
					gpp.ScooterHornParticle.SetActive(true);
				}
			}
			else if (gpp.ScooterHornParticle != None)
				gpp.ScooterHornParticle.SetActive(true);
		}
		gpp.PlaySound(default.HonkSound);
	}
	SetPokemonAttackEmissionEffect(gpp.ScooterMesh, f);
}

final simulated function UpdateVisuals(bool IsPlayerWireframe, bool IsPlayerMuddy)
{
	if (IsPlayerWireframe != IsWireframe)
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
	if (IsPlayerMuddy != IsMuddy)
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
	local MaterialInstanceTimeVarying VaryingInst;
	local InterpCurveFloat Curve;
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
		VaryingInst = MaterialInstanceTimeVarying(inst);
		if (VaryingInst != None)
		{
			VaryingInst.SetScalarStartTime('MudVertexShader', 0.0);
			VaryingInst.SetScalarStartTime('Goop', 0.0);
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
	if (default.WireframeMaterials.Length < 1)
		return false;
	if (comp != None && comp.SkeletalMesh == default.ScooterMesh)
	{
		for (i = 0; i < Min(comp.GetNumElements(), default.WireframeMaterials.Length); i++)
			class'Shara_SkinColors_Tools_Short_RPS'.static.SetMaterialParentToInstance(comp, i, default.WireframeMaterials[i]);
		return true;
	}
	return false;
}

static function bool SetPokemonStandardMaterials(SkeletalMeshComponent comp)
{
	if (comp != None && comp.SkeletalMesh == default.ScooterMesh)
		return SetSkeletalMeshDefaultMaterialInstanceParents(comp);
}

final static function bool SetSkeletalMeshDefaultMaterialInstanceParents(SkeletalMeshComponent comp)
{
	local int i;
	if (comp == None || comp.SkeletalMesh == None)
		return false;
	for (i = 0; i < Min(comp.GetNumElements(), comp.SkeletalMesh.Materials.Length); i++)
	{
		if (comp.SkeletalMesh.Materials[i] != None)
			class'Shara_SkinColors_Tools_Short_RPS'.static.SetMaterialParentToInstance(comp, i, comp.SkeletalMesh.Materials[i]);
	}
	return true;
}

final static function CopyParentMeshMaterials(MeshComponent ParentMesh, MeshComponent TargetMesh)
{
	local int i;
	local MaterialInterface mat;
	if (ParentMesh == None || TargetMesh == None)
		return;
	for (i = 0; i < Min(ParentMesh.GetNumElements(), TargetMesh.GetNumElements()); i++)
	{
		mat = class'Shara_SkinColors_Tools_Short_RPS'.static.GetActualMaterial(ParentMesh.GetMaterial(i));
		if (mat != None)
			class'Shara_SkinColors_Tools_Short_RPS'.static.SetMaterialParentToInstance(TargetMesh, i, mat);
	}
}

simulated function OnRemoved(Actor a)
{
	local Hat_Player ply;
	ply = Hat_Player(a);
	if (ply != None)
	{
		switch(PlayerAnimationType)
		{
			case Type_Sandmobile:
				ply.OnExitVehicleClassAnim();
				ply.SetSandmobileAnim(ESandmobileAnim_None, 0);
				break;
			case Type_AnimNodes:
				SetAnimNodesByNameActive(ply.Mesh, ScooterAnimNodesName, false);
				break;
			case Type_TauntNodes:
				ply.SetTauntAnim("", string(ScooterAnimNodesName));
				break;
			case Type_CustomAnimation:
				ply.PlayCustomAnimation('');
				break;
			default:
				break;
		}
		RestoreActorProperties(ply);
		ply.VehicleProperties.VehicleModeActive = false;
		ply.SetStepUpOffsetMesh(None);
		ply.ResetMoveSpeed();
		ply.AttachComponent(ply.Mesh);
		if (ScooterMeshComp != None)
		{
			ply.Mesh.SetScale(ScooterScale);
			ply.Mesh.SetScale3D(ScooterScale3D);
		}
		ply.VehicleProperties.VehicleMeshComponent = None;
		if (ExplodeParticle != None && ply.WorldInfo != None && ply.WorldInfo.MyEmitterPool != None)
			ply.WorldInfo.MyEmitterPool.SpawnEmitter(ExplodeParticle, ply.Location);
		if (ExplodeSound != None)
			ply.PlaySound(ExplodeSound);
	}
	else
		RestoreActorProperties(a);
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
	PlayerAnimationType = Type_None;
	ScooterScale = default.ScooterScale;
	ScooterScale3D = default.ScooterScale3D;
	if (ply != None)
		class'RideablePokemon_OnlinePartyHandler'.static.SendOnlinePartyCommand(GetLocalName()$"RideStop", ply, , ModInstance);
	Super(Hat_StatusEffect).OnRemoved(a);
}

simulated function CleanUp()
{
	RestoreActorsProperties();
	Super.CleanUp();
}

final simulated function UpdateHealth(int h)
{
	h = Clamp(h, 0, HealthMax);
	if (h == Health)
		return;
	SetPokemonHealth(ScooterMeshComp, h);
	Health = h;
	class'RideablePokemon_OnlinePartyHandler'.static.SendOnlinePartyCommand(GetLocalName()$"Health"$Health, Hat_Player(Owner), , ModInstance);
}

final static function SetPokemonHealth(SkeletalMeshComponent comp, int h)
{
	ModifyPokemonEyes(comp, h);
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

final static function float SetPokemonCustomBattleActionAnimation(SkeletalMeshComponent comp, Name AnimName)
{
	local float f;
	local AnimNodePlayCustomAnim CustomAnimNode;
	if (comp == None || AnimName == '' || comp.FindAnimSequence(AnimName) == None)
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

final simulated function SetPokemonIdle()
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
	local Array<AnimNode> AnimNodes;
	local int i;
	local bool bb;
	if (n == '')
		return false;
	if (comp == None)
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
	local AnimNodeBlendList anbl;
	local Hat_AnimBlendBase habb;
	local AnimNodeBlend anb;
	if (anbb == None || anbb.Children.Length < int(b)+1)
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
			anbl.SetActiveChild(int(b), Abs(DefaultTime));
		return true;
	}
	anb = AnimNodeBlend(anbb);
	if (anb == None)
		return false;
	if (anb.Child2Weight != float(b))
		anb.SetBlendTarget(float(b), Abs(DefaultTime));
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
	if (!default.PokemonScaresPlayers)
		return;
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

defaultproperties
{
	ScooterPhysicsAssetInstance = true
	ScooterScale = 1.0
	ScooterScale3D = (X = 1.0, Y = 1.0, Z = 1.0)
	Health = HealthMax
	WheelStopLeftSound = None
	WheelStopRightSound = None
	SpeedDustParticle = None
	WindSound = None
	EngineSound = None
	EngineDrivingSound = None
	ScooterCollisionContainer = (Default = true, Pawn = true, Vehicle = true, GameplayPhysics = true, EffectPhysics = true, Untitled3 = true, BlockingVolume = true)
}