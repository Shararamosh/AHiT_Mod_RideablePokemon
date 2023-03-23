class Hat_StatusEffect_RideableGarchomp_M extends Hat_StatusEffect_RideablePokemon;

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.AddItem('Battle_Idle1');
	baa.IdleAnims.AddItem('Battle_Idle2');
	baa.PhysicalAttackAnims.AddItem('Battle_PhysicalAttack1');
	baa.PhysicalAttackAnims.AddItem('Battle_PhysicalAttack2');
	baa.TakingDamageAnims.AddItem('Battle_SpecialAttack1');
	baa.TakingDamageAnims.AddItem('Battle_SpecialAttack2');
	baa.TakingDamageAnims.AddItem('Battle_Damage');
	return baa;
}

static function class<Hat_StatusEffect_RideablePokemon> GetRandomAppearance(bool RandomGender, bool RandomForme)
{
	if (RandomGender)
	{
		if (Rand(2) == 1)
			return class'Hat_StatusEffect_RideableGarchomp_F';
		return class'Hat_StatusEffect_RideableGarchomp_M';
	}
	return default.Class;
}

static function bool ModifyPokemonEyes(SkeletalMeshComponent comp, int h)
{
	local MaterialInstance inst;
	local Texture OldTex, NewTex;
	if (comp == None || comp.SkeletalMesh != default.ScooterMesh)
		return false;
	switch(Clamp(h, 0, 4))
	{
		case 0:
			NewTex = Texture2D'RideableGarchomp_Package.Textures.pm0445_00_Eye03_col';
			break;
		case 1:
			NewTex = Texture2D'RideableGarchomp_Package.Textures.pm0445_00_Eye04_col';
			break;
		case 2:
			NewTex = Texture2D'RideableGarchomp_Package.Textures.pm0445_00_Eye07_col';
			break;
		case 3:
			NewTex = Texture2D'RideableGarchomp_Package.Textures.pm0445_00_Eye05_col';
			break;
		default:
			NewTex = Texture2D'RideableGarchomp_Package.Textures.pm0445_00_Eye01_col';
			break;
	}
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstance(comp, 1, inst);
	if (inst != None && inst.IsInMapOrTransientPackage() && inst.GetTextureParameterValue('DefaultEyes', OldTex))
	{
		if (OldTex != NewTex)
			inst.SetTextureParameterValue('DefaultEyes', NewTex);
	}
	return true;
}

defaultproperties
{
	ScooterMesh = SkeletalMesh'RideableGarchomp_Package.models.Garchomp_Male'
	ScooterAnimTree = AnimTree'RideableGarchomp_Package.AnimTrees.RideableGarchomp_AnimTree'
	ScooterAnimSet = AnimSet'RideableGarchomp_Package.AnimSets.Garchomp_Anims'
	ScooterPhysics = PhysicsAsset'RideableGarchomp_Package.Physics.Garchomp_Physics'
	HonkSound = SoundCue'RideableGarchomp_Package.Sounds.Garchomp_Cry_Cue'
	ScooterLoopAnimation = "rocketride"
	WireframeMaterials.Add(Material'RideableGarchomp_Package.Materials.pm0445_00_BodyA_Wireframe')
	WireframeMaterials.Add(Material'RideableGarchomp_Package.Materials.pm0445_00_Eye_Wireframe')
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableGarchomp_Package.Materials.pm0445_00_BodyB_Wireframe')
}