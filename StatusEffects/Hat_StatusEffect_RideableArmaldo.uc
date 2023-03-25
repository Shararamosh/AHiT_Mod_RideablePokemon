class Hat_StatusEffect_RideableArmaldo extends Hat_StatusEffect_RideablePokemon;

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

static function bool ModifyPokemonEyes(SkeletalMeshComponent comp, int h)
{
	local MaterialInstance inst;
	local Texture OldTex, NewTex;
	if (comp == None || comp.SkeletalMesh != default.ScooterMesh)
		return false;
	switch(Clamp(h, 0, 4))
	{
		case 0:
			NewTex = Texture2D'RideableArmaldo_Package.Textures.pm0348_00_Eye03_col';
			break;
		case 1:
			NewTex = Texture2D'RideableArmaldo_Package.Textures.pm0348_00_Eye04_col';
			break;
		case 2:
			NewTex = Texture2D'RideableArmaldo_Package.Textures.pm0348_00_Eye07_col';
			break;
		case 3:
			NewTex = Texture2D'RideableArmaldo_Package.Textures.pm0348_00_Eye05_col';
			break;
		default:
			NewTex = Texture2D'RideableArmaldo_Package.Textures.pm0348_00_Eye01_col';
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

defaultproperties
{
	ScooterMesh = SkeletalMesh'RideableArmaldo_Package.models.Armaldo'
	ScooterAnimTree = AnimTree'RideableArmaldo_Package.AnimTrees.RideableArmaldo_AnimTree'
	ScooterAnimSet = AnimSet'RideableArmaldo_Package.AnimSets.Armaldo_Anims'
	ScooterPhysics = PhysicsAsset'RideableArmaldo_Package.Physics.Armaldo_Physics'
	HonkSound = SoundCue'RideableArmaldo_Package.Sounds.Armaldo_Cry_Cue'
	ScooterAnimNodesName = "Bench_Sit"
	ScooterLoopAnimation = "sit_bench"
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableArmaldo_Package.Materials.pm0348_00_BodyB_Wireframe')
	WireframeMaterials.Add(Material'RideableArmaldo_Package.Materials.pm0348_00_BodyA_Wireframe')
	WireframeMaterials.Add(Material'RideableArmaldo_Package.Materials.pm0348_00_Eye_Wireframe')
}