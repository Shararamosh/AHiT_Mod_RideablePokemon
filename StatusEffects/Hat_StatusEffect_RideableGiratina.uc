class Hat_StatusEffect_RideableGiratina extends Hat_StatusEffect_RideablePokemon;

var const SkeletalMeshComponent AttachmentArchetype;

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.AddItem('Battle_Idle1');
	baa.IdleAnims.AddItem('Battle_Idle2');
	baa.PhysicalAttackAnims.AddItem('Battle_PhysicalAttack1');
	baa.PhysicalAttackAnims.AddItem('Battle_PhysicalAttack2');
	baa.SpecialAttackAnims.AddItem('Battle_SpecialAttack1');
	baa.SpecialAttackAnims.AddItem('Battle_SpecialAttack2');
	baa.TakingDamageAnims.AddItem('Battle_Damage');
	return baa;
}

static function bool MaintainScooterMesh(Actor InActor, SkeletalMeshComponent InComponent, SkeletalMeshComponent MeshComponent)
{
	if (!Super.MaintainScooterMesh(InActor, InComponent, MeshComponent))
		return false;
	InitScooterMeshProperties(InActor, AddGiratinaAttachment(MeshComponent), true);
	return true;
}

static function SetPokemonTimeAfterSpawn(SkeletalMeshComponent comp, float f)
{
	Super.SetPokemonTimeAfterSpawn(comp, f);
	SetTimeAfterSpawnMesh(GetGiratinaAttachment(comp), f);
}

static function SetPokemonMuddyEffect(SkeletalMeshComponent comp, bool b)
{
	Super.SetPokemonMuddyEffect(comp, b);
	SetMuddyEffectMesh(GetGiratinaAttachment(comp), b);
}

static function SetPokemonAttackEmissionEffect(SkeletalMeshComponent comp, float EffectDuration)
{
	Super.SetPokemonAttackEmissionEffect(comp, EffectDuration);
	SetAttackEmissionEffectMesh(GetGiratinaAttachment(comp), EffectDuration);
}

static function bool SetPokemonWireframeMaterials(SkeletalMeshComponent comp)
{
	local bool b;
	b = Super.SetPokemonWireframeMaterials(comp);
	CopyParentMeshMaterials(comp, GetGiratinaAttachment(comp));
	return b;
}

static function bool SetPokemonStandardMaterials(SkeletalMeshComponent comp)
{
	local bool b;
	b = Super.SetPokemonStandardMaterials(comp);
	CopyParentMeshMaterials(comp, GetGiratinaAttachment(comp));
	return b;
}
//ATTACHMENT FUNCTIONS BEGIN!!!
static function SkeletalMeshComponent GetGiratinaAttachment(SkeletalMeshComponent ParentMesh)
{
	local SkeletalMeshComponent comp;
	if (!IsPokemonMesh(ParentMesh))
		return None;
	foreach ParentMesh.AttachedComponents(class'SkeletalMeshComponent', comp)
	{
		if (comp == None)
			continue;
		if (comp.ObjectArchetype == default.AttachmentArchetype)
			return comp;
	}
	return None;
}

static function SkeletalMeshComponent AddGiratinaAttachment(SkeletalMeshComponent ParentMesh)
{
	local SkeletalMeshComponent comp;
	local bool b;
	if (!IsPokemonMesh(ParentMesh))
		return None;
	comp = GetGiratinaAttachment(ParentMesh);
	if (comp == None)
	{
		comp = new class'SkeletalMeshComponent'(default.AttachmentArchetype);
		b = (comp != None);
	}
	else
		b = SetGiratinaAttachmentProperties(comp);
	if (b)
	{
		b = SetGiratinaAttachmentParentProperties(ParentMesh, comp);
		if (b)
			return comp;
	}
	if (comp != None)
		comp.DetachFromAny();
	return None;
}

static function bool SetGiratinaAttachmentProperties(SkeletalMeshComponent TargetMesh)
{
	if (TargetMesh == None)
		return false;
	TargetMesh.SetSkeletalMesh(default.AttachmentArchetype.SkeletalMesh);
	TargetMesh.AnimSets.Length = 0;
	TargetMesh.SetAnimTreeTemplate(None);
	TargetMesh.UpdateAnimations();
	TargetMesh.SetPhysicsAsset(default.AttachmentArchetype.PhysicsAsset);
	TargetMesh.SetHasPhysicsAssetInstance(true);
	TargetMesh.SetTranslation(vect(0.0, 0.0, 0.0));
	TargetMesh.SetRotation(MakeRotator(0, 0, 0));
	TargetMesh.SetScale(1.0);
	TargetMesh.SetScale3D(vect(1.0, 1.0, 1.0));
	TargetMesh.SetAbsolute(false, false, false);
	return true;
}

static function bool SetGiratinaAttachmentParentProperties(SkeletalMeshComponent ParentMesh, SkeletalMeshComponent TargetMesh)
{
	if (!IsPokemonMesh(ParentMesh) || TargetMesh == None)
		return false;
	TargetMesh.SetLightEnvironment(ParentMesh.LightEnvironment);
	TargetMesh.SetShadowParent(ParentMesh);
	TargetMesh.SetParentAnimComponent(ParentMesh);
	ParentMesh.AttachComponent(TargetMesh, 'Waist');
	return true;
}
//ATTACHMENT FUNCTIONS END!!!

static function bool IsTiedToFlair()
{
	return true;
}

static function bool ShouldScarePlayers()
{
	return true;
}

defaultproperties
{
	ScooterMesh = SkeletalMesh'RideableGiratina_Package.models.Giratina'
	ScooterAnimTree = AnimTree'RideableGiratina_Package.AnimTrees.RideableGiratina_AnimTree'
	ScooterAnimSet = AnimSet'RideableGiratina_Package.AnimSets.Giratina_Anims'
	ScooterPhysics = PhysicsAsset'RideableGiratina_Package.Physics.Giratina_Physics'
	HonkSound = SoundCue'RideableGiratina_Package.Sounds.Giratina_Cry_Cue'
	ScooterAnimNodesName = "Race_Intro"
	ScooterIntroAnimation = "race_intro"
	ScooterLoopAnimation = "race_idle"
	WireframeMaterials.Add(Material'RideableGiratina_Package.Materials.pm0487_12_bodya_Wireframe')
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableGiratina_Package.Materials.pm0487_12_bodyb_Wireframe')
	WireframeMaterials.Add(Material'RideableGiratina_Package.Materials.pm0487_12_eye_Wireframe')
	Begin Object Class=SkeletalMeshComponent Name=AttachmentArchetype0
		SkeletalMesh = SkeletalMesh'RideableGiratina_Package.models.Giratina_Attachment'
		PhysicsAsset = PhysicsAsset'RideableGiratina_Package.Physics.Giratina_Attachment_Physics'
		bHasPhysicsAssetInstance = true
		CanBlockCamera = false
		BlockZeroExtent = true
		BlockNonZeroExtent = true
		BlockRigidBody = true
		CanBeStoodOn = true
		CanBeEdgeGrabbed = true
		RBChannel = RBCC_GameplayPhysics
		RBCollideWithChannels = (Default = true, Pawn = true, Vehicle = true, GameplayPhysics = true, EffectPhysics = true, Untitled3 = true, BlockingVolume = true)
		TickGroup = TG_PostAsyncWork
	End Object
	AttachmentArchetype = AttachmentArchetype0
}