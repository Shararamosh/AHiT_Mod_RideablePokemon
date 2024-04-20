class Hat_StatusEffect_RideableOctillery_M extends Hat_StatusEffect_RideablePokemon;

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.AddItem('Battle_Idle');
	baa.CryingAnims.AddItem('Battle_Cry');
	baa.PhysicalAttackAnims.AddItem('Battle_PhysicalAttack');
	baa.SpecialAttackAnims.AddItem('Battle_SpecialAttack');
	baa.TakingDamageAnims.AddItem('Battle_Damage');
	return baa;
}

static function class<Hat_StatusEffect_RideablePokemon> GetRandomAppearance(bool RandomGender, bool RandomForme)
{
	if (RandomGender)
	{
		if (Rand(2) == 1)
			return class'Hat_StatusEffect_RideableOctillery_F';
		return class'Hat_StatusEffect_RideableOctillery_M';
	}
	return default.Class;
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
			NewTex = Texture2D'RideableOctillery_Package.Textures.pm0224_00_eye3_col';
			break;
		case 1:
			NewTex = Texture2D'RideableOctillery_Package.Textures.pm0224_00_eye4_col';
			break;
		case 2:
			NewTex = Texture2D'RideableOctillery_Package.Textures.pm0224_00_eye7_col';
			break;
		case 3:
			NewTex = Texture2D'RideableOctillery_Package.Textures.pm0224_00_eye5_col';
			break;
		default:
			NewTex = Texture2D'RideableOctillery_Package.Textures.pm0224_00_eye1_col';
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
	ScooterMesh = SkeletalMesh'RideableOctillery_Package.models.Octillery_Male'
	ScooterAnimTree = AnimTree'RideableOctillery_Package.AnimTrees.RideableOctillery_AnimTree'
	ScooterAnimSet = AnimSet'RideableOctillery_Package.AnimSets.Octillery_Anims'
	ScooterPhysics = PhysicsAsset'RideableOctillery_Package.Physics.Octillery_Physics'
	HonkSound = SoundCue'RideableOctillery_Package.Sounds.Octillery_Cry_Cue'
	ScooterAnimNodesName = "Race_Intro"
	ScooterIntroAnimation = "race_intro"
	ScooterLoopAnimation = "race_idle"
	WireframeMaterials.Add(Material'RideableOctillery_Package.Materials.pm0224_00_body_Wireframe')
	WireframeMaterials.Add(Material'RideableOctillery_Package.Materials.pm0224_00_eye_Wireframe')
}