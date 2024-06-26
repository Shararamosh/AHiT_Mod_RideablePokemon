class Hat_StatusEffect_RideableGlaceon extends Hat_StatusEffect_RideablePokemon;

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.AddItem('Battle_Idle1');
	baa.IdleAnims.AddItem('Battle_Idle2');
	baa.CryingAnims.AddItem('Battle_Cry');
	baa.PhysicalAttackAnims.AddItem('Battle_PhysicalAttack');
	baa.SpecialAttackAnims.AddItem('Battle_SpecialAttack1');
	baa.SpecialAttackAnims.AddItem('Battle_SpecialAttack2');
	baa.TakingDamageAnims.AddItem('Battle_Damage');
	return baa;
}

static function bool ModifyPokemonEyes(SkeletalMeshComponent comp, int h)
{
	local MaterialInstance inst;
	local Texture OldTex, NewTex;
	if (!IsPokemonMesh(comp))
		return false;
	switch(Clamp(h, 0, 4))
	{
		case 0:
			NewTex = Texture2D'RideableGlaceon_Package.Textures.pm0471_00_eye03_col';
			break;
		case 1:
			NewTex = Texture2D'RideableGlaceon_Package.Textures.pm0471_00_eye04_col';
			break;
		case 2:
			NewTex = Texture2D'RideableGlaceon_Package.Textures.pm0471_00_eye07_col';
			break;
		case 3:
			NewTex = Texture2D'RideableGlaceon_Package.Textures.pm0471_00_eye05_col';
			break;
		default:
			NewTex = Texture2D'RideableGlaceon_Package.Textures.pm0471_00_eye01_col';
			break;
	}
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstance(comp, 2, inst);
	if (inst != None && inst.IsInMapOrTransientPackage() && inst.GetTextureParameterValue('DefaultEyes', OldTex))
	{
		if (OldTex != NewTex)
			inst.SetTextureParameterValue('DefaultEyes', NewTex);
	}
	return true;
}

static function bool ModifyPokemonFace(SkeletalMeshComponent comp, bool DoesScream)
{
	local MaterialInstance inst;
	local Texture OldTex, NewTex;
	if (!IsPokemonMesh(comp))
		return false;
	if (DoesScream)
		NewTex = Texture2D'RideableGlaceon_Package.Textures.pm0471_00_mouth03_col';
	else
		NewTex = Texture2D'RideableGlaceon_Package.Textures.pm0471_00_mouth01_col';
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstance(comp, 1, inst);
	if (inst != None && inst.IsInMapOrTransientPackage() && inst.GetTextureParameterValue('Color', OldTex))
	{
		if (OldTex != NewTex)
			inst.SetTextureParameterValue('Color', NewTex);
	}
	return true;
}

static function bool IsTiedToFlair()
{
	return true;
}

static function SkeletalMesh GetPokemonSkeletalMesh()
{
	if (AreTimedEventSkinsAllowed() && class'Hat_SeqCond_IsTimedEvent'.static.IsTimedEvent(ETimedEvent_Winter))
		return SkeletalMesh'RideableGlaceon_Package.models.Glaceon_pgo_winter2021';
	return Super.GetPokemonSkeletalMesh();
}

static function PhysicsAsset GetPokemonPhysicsAsset(SkeletalMesh sm)
{
	switch(sm)
	{
		case SkeletalMesh'RideableGlaceon_Package.models.Glaceon_pgo_winter2021':
			return PhysicsAsset'RideableGlaceon_Package.Physics.Glaceon_pgo_winter2021_Physics';
		default:
			return Super.GetPokemonPhysicsAsset(sm);
	}
}

static function Array<MaterialInterface> GetPokemonWireframeMaterials(SkeletalMesh sm)
{
	local Array<MaterialInterface> mats;
	mats = Super.GetPokemonWireframeMaterials(sm);
	switch(sm)
	{
		case SkeletalMesh'RideableGlaceon_Package.models.Glaceon_pgo_winter2021':
			mats.AddItem(Material'RideableGlaceon_Package.Materials.pm0471_00_glacia_pgo_winter2021_Wireframe');
			break;
		default:
			break;
	}
	return mats;
}

static function bool IsPokemonMesh(SkeletalMeshComponent comp)
{
	if (comp == None)
		return false;
	switch(comp.SkeletalMesh)
	{
		case None:
			return false;
		case SkeletalMesh'RideableGlaceon_Package.models.Glaceon_pgo_winter2021':
			return true;
		default:
			return Super.IsPokemonMesh(comp);
	}
}

defaultproperties
{
	ScooterMesh = SkeletalMesh'RideableGlaceon_Package.models.Glaceon'
	ScooterAnimTree = AnimTree'RideableGlaceon_Package.AnimTrees.RideableGlaceon_AnimTree'
	ScooterAnimSet = AnimSet'RideableGlaceon_Package.AnimSets.Glaceon_Anims'
	ScooterPhysics = PhysicsAsset'RideableGlaceon_Package.Physics.Glaceon_Physics'
	HonkSound = SoundCue'RideableGlaceon_Package.Sounds.Glaceon_Cry_Cue'
	ScooterAnimNodesName = "Bench_Sit"
	ScooterLoopAnimation = "sit_bench"
	WireframeMaterials.Add(Material'RideableGlaceon_Package.Materials.pm0471_00_body_Wireframe')
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableGlaceon_Package.Materials.pm0471_00_mouth_Wireframe')
	WireframeMaterials.Add(Material'RideableGlaceon_Package.Materials.pm0471_00_eye_Wireframe')
}