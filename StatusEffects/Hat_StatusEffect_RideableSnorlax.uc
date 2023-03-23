class Hat_StatusEffect_RideableSnorlax extends Hat_StatusEffect_RideablePokemon;

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.AddItem('Battle_Idle1');
	baa.IdleAnims.AddItem('Battle_Idle2');
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
			NewTex = Texture2D'RideableSnorlax_Package.Textures.pm0143_00_eye_col_03';
			break;
		case 1:
			NewTex = Texture2D'RideableSnorlax_Package.Textures.pm0143_00_eye_col_02';
			break;
		case 2:
			NewTex = Texture2D'RideableSnorlax_Package.Textures.pm0143_00_eye_col_05';
			break;
		case 3:
			NewTex = Texture2D'RideableSnorlax_Package.Textures.pm0143_00_eye_col_01';
			break;
		default:
			NewTex = Texture2D'RideableSnorlax_Package.Textures.pm0143_00_eye_col_04';
			break;
	}
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstance(comp, 1, inst);
	if (inst != None && inst.IsInMapOrTransientPackage() && inst.GetTextureParameterValue('Color', OldTex))
	{
		if (OldTex != NewTex)
			inst.SetTextureParameterValue('Color', NewTex);
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
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstance(comp, 2, inst);
	if (inst != None && inst.IsInMapOrTransientPackage())
	{
		if (inst.GetTextureParameterValue('Color', OldTex))
		{
			if (DoesScream)
				NewTex = Texture2D'RideableSnorlax_Package.Textures.pm0143_00_mouth_col_08';
			else
				NewTex = Texture2D'RideableSnorlax_Package.Textures.pm0143_00_mouth_col_01';
			if (OldTex != NewTex)
				inst.SetTextureParameterValue('Color', NewTex);
		}
		if (inst.GetTextureParameterValue('Ambient', OldTex))
		{
			if (DoesScream)
				NewTex = Texture2D'RideableSnorlax_Package.Ambient.pm0143_00_mouth_amb_08';
			else
				NewTex = Texture2D'RideableSnorlax_Package.Ambient.pm0143_00_mouth_amb_01';
			if (OldTex != NewTex)
				inst.SetTextureParameterValue('Ambient', NewTex);
		}
	}
	return true;
}

defaultproperties
{
	ScooterMesh = SkeletalMesh'RideableSnorlax_Package.models.Snorlax'
	ScooterAnimTree = AnimTree'RideableSnorlax_Package.AnimTrees.RideableSnorlax_AnimTree'
	ScooterAnimSet = AnimSet'RideableSnorlax_Package.AnimSets.Snorlax_Anims'
	ScooterPhysics = PhysicsAsset'RideableSnorlax_Package.Physics.Snorlax_Physics'
	HonkSound = SoundCue'RideableSnorlax_Package.Sounds.Snorlax_Cry_Cue'
	ScooterIntroAnimation = "LedgeHang_Intro"
	ScooterLoopAnimation = "LedgeHang"
	WireframeMaterials.Add(Material'RideableSnorlax_Package.Materials.pm0143_00_body_Wireframe')
	WireframeMaterials.Add(Material'RideableSnorlax_Package.Materials.pm0143_00_eye_Wireframe')
	WireframeMaterials.Add(Material'RideableSnorlax_Package.Materials.pm0143_00_mouth_Wireframe')
}