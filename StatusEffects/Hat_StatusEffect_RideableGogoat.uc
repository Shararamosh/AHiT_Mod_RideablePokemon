class Hat_StatusEffect_RideableGogoat extends Hat_StatusEffect_RideablePokemon;

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.AddItem('Battle_Idle1');
	baa.IdleAnims.AddItem('Battle_Idle2');
	baa.PhysicalAttackAnims.AddItem('Battle_PhysicalAttack');
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
			NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Eye3_col';
			break;
		case 1:
			NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Eye7_col';
			break;
		case 2:
			NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Eye2_col';
			break;
		case 3:
			NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Eye5_col';
			break;
		default:
			NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Eye1_col';
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
		NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Mouth3_col';
	else
		NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Mouth1_col';
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
	ScooterMesh = SkeletalMesh'RideableGogoat_Package.models.Gogoat'
	ScooterAnimTree = AnimTree'RideableGogoat_Package.AnimTrees.RideableGogoat_AnimTree'
	ScooterAnimSet = AnimSet'RideableGogoat_Package.AnimSets.Gogoat_Anims'
	ScooterPhysics = PhysicsAsset'RideableGogoat_Package.Physics.Gogoat_Physics'
	HonkSound = SoundCue'RideableGogoat_Package.Sounds.Gogoat_Cry_Cue'
	WireframeMaterials.Add(Material'RideableGogoat_Package.Materials.pm0729_00_BodyA_Wireframe')
	WireframeMaterials.Add(Material'RideableGogoat_Package.Materials.pm0729_00_Mouth_Wireframe')
	WireframeMaterials.Add(Material'RideableGogoat_Package.Materials.pm0729_00_Eye_Wireframe')
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableGogoat_Package.Materials.pm0729_00_BodyB_Wireframe')
}