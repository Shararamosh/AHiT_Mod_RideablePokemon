class Hat_StatusEffect_RideableNidoqueen extends Hat_StatusEffect_RideablePokemon;

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.AddItem('Battle_Idle');
	baa.IdleAnims.AddItem('Camp_Happy');
	baa.CryingAnims.AddItem('Battle_Cry');
	baa.PhysicalAttackAnims.AddItem('Battle_PhysicalAttack');
	baa.TakingDamageAnims.AddItem('Battle_SpecialAttack');
	baa.TakingDamageAnims.AddItem('Battle_Damage');
	return baa;
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
			NewTex = Texture2D'RideableNidoqueen_Package.Textures.pm0031_00_eye3_col';
			break;
		case 1:
			NewTex = Texture2D'RideableNidoqueen_Package.Textures.pm0031_00_eye4_col';
			break;
		case 2:
			NewTex = Texture2D'RideableNidoqueen_Package.Textures.pm0031_00_eye7_col';
			break;
		case 3:
			NewTex = Texture2D'RideableNidoqueen_Package.Textures.pm0031_00_eye5_col';
			break;
		default:
			NewTex = Texture2D'RideableNidoqueen_Package.Textures.pm0031_00_eye1_col';
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
	ScooterMesh = SkeletalMesh'RideableNidoqueen_Package.models.Nidoqueen'
	ScooterAnimTree = AnimTree'RideableNidoqueen_Package.AnimTrees.RideableNidoqueen_AnimTree'
	ScooterAnimSet = AnimSet'RideableNidoqueen_Package.AnimSets.Nidoqueen_Anims'
	ScooterPhysics = PhysicsAsset'RideableNidoqueen_Package.Physics.Nidoqueen_Physics'
	HonkSound = SoundCue'RideableNidoqueen_Package.Sounds.Nidoqueen_Cry_Cue'
	ScooterIntroAnimation = "TightropeRareIdle01"
	ScooterLoopAnimation = "TightropeIdle"
	WireframeMaterials.Add(Material'RideableNidoqueen_Package.Materials.pm0031_00_body_Wireframe')
	WireframeMaterials.Add(Material'RideableNidoqueen_Package.Materials.pm0031_00_eye_Wireframe')
}