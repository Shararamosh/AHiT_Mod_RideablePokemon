class Hat_StatusEffect_RideableTogekiss extends Hat_StatusEffect_RideablePokemon;

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
	if (comp == None || comp.SkeletalMesh != default.ScooterMesh)
		return false;
	switch(Clamp(h, 0, 4))
	{
		case 0:
			NewTex = Texture2D'RideableTogekiss_Package.Textures.pm0468_00_Eye03_col';
			break;
		case 1:
			NewTex = Texture2D'RideableTogekiss_Package.Textures.pm0468_00_Eye04_col';
			break;
		case 2:
			NewTex = Texture2D'RideableTogekiss_Package.Textures.pm0468_00_Eye07_col';
			break;
		case 3:
			NewTex = Texture2D'RideableTogekiss_Package.Textures.pm0468_00_Eye05_col';
			break;
		default:
			NewTex = Texture2D'RideableTogekiss_Package.Textures.pm0468_00_Eye01_col';
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
		NewTex = Texture2D'RideableTogekiss_Package.Textures.pm0468_00_Mouth03_col';
	else
		NewTex = Texture2D'RideableTogekiss_Package.Textures.pm0468_00_Mouth01_col';
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstance(comp, 1, inst);
	if (inst != None && inst.IsInMapOrTransientPackage() && inst.GetTextureParameterValue('Color', OldTex))
	{
		if (OldTex != NewTex)
			inst.SetTextureParameterValue('Color', NewTex);
	}
	return true;
}

defaultproperties
{
	ScooterMesh = SkeletalMesh'RideableTogekiss_Package.models.Togekiss'
	ScooterAnimTree = AnimTree'RideableTogekiss_Package.AnimTrees.RideableTogekiss_AnimTree'
	ScooterAnimSet = AnimSet'RideableTogekiss_Package.AnimSets.Togekiss_Anims'
	ScooterPhysics = PhysicsAsset'RideableTogekiss_Package.Physics.Togekiss_Physics'
	HonkSound = SoundCue'RideableTogekiss_Package.Sounds.Togekiss_Cry_Cue'
	ScooterAnimNodesName = "Race_Intro"
	ScooterIntroAnimation = "race_intro"
	ScooterLoopAnimation = "race_idle"
	WireframeMaterials.Add(Material'RideableTogekiss_Package.Materials.pm0468_00_Body_Wireframe')
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableTogekiss_Package.Materials.pm0468_00_Mouth_Wireframe')
	WireframeMaterials.Add(Material'RideableTogekiss_Package.Materials.pm0468_00_Eye_Wireframe')
}