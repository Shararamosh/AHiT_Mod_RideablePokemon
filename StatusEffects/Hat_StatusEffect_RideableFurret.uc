class Hat_StatusEffect_RideableFurret extends Hat_StatusEffect_RideablePokemon;

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.AddItem('Battle_Idle1');
	baa.IdleAnims.AddItem('Battle_Idle2');
	baa.IdleAnims.AddItem('Camp_Move');
	baa.PhysicalAttackAnims.AddItem('Battle_PhysicalAtack');
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
			NewTex = Texture2D'RideableFurret_Package.Textures.pm0162_00_00_Eye05_col';
			break;
		case 1:
			NewTex = Texture2D'RideableFurret_Package.Textures.pm0162_00_00_Eye07_col';
			break;
		case 2:
			NewTex = Texture2D'RideableFurret_Package.Textures.pm0162_00_00_Eye04_col';
			break;
		case 3:
			NewTex = Texture2D'RideableFurret_Package.Textures.pm0162_00_00_Eye02_col';
			break;
		default:
			NewTex = Texture2D'RideableFurret_Package.Textures.pm0162_00_00_Eye01_col';
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
	if (comp == None || comp.SkeletalMesh != default.ScooterMesh)
		return false;
	if (DoesScream)
		NewTex = Texture2D'RideableFurret_Package.Textures.pm0162_00_00_Mouth03_col';
	else
		NewTex = Texture2D'RideableFurret_Package.Textures.pm0162_00_00_Mouth01_col';
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstance(comp, 0, inst);
	if (inst != None && inst.IsInMapOrTransientPackage() && inst.GetTextureParameterValue('Color', OldTex))
	{
		if (OldTex != NewTex)
			inst.SetTextureParameterValue('Color', NewTex);
	}
	return true;
}

defaultproperties
{
	ScooterMesh = SkeletalMesh'RideableFurret_Package.models.Furret'
	ScooterAnimTree = AnimTree'RideableFurret_Package.AnimTrees.RideableFurret_AnimTree'
	ScooterAnimSet = AnimSet'RideableFurret_Package.AnimSets.Furret_Anims'
	ScooterPhysics = PhysicsAsset'RideableFurret_Package.Physics.Furret_Physics'
	HonkSound = SoundCue'RideableFurret_Package.Sounds.Furret_Cry_Cue'
	ScooterAnimNodesName = "Bench_Sit"
	ScooterLoopAnimation = "sit_bench"
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableFurret_Package.Materials.pm0162_00_00_Mouth')
	WireframeMaterials.Add(Material'RideableFurret_Package.Materials.pm0162_00_00_Body')
	WireframeMaterials.Add(Material'RideableFurret_Package.Materials.pm0162_00_00_Eye')
}