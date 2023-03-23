class Hat_StatusEffect_RideableGogoat extends Hat_StatusEffect_RideablePokemon;

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.AddItem('Idle');
	baa.IdleAnims.AddItem('IdleCold');
	baa.CryingAnims.AddItem('Crying');
	baa.PhysicalAttackAnims.AddItem('Attacking');
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
			NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Eye3';
			break;
		case 1:
			NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Eye7';
			break;
		case 2:
			NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Eye2';
			break;
		case 3:
			NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Eye5';
			break;
		default:
			NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Eye1';
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
		NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Mouth2';
	else
		NewTex = Texture2D'RideableGogoat_Package.Textures.pm0729_00_Mouth1';
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstance(comp, 1, inst);
	if (inst != None && inst.IsInMapOrTransientPackage() && inst.GetTextureParameterValue('Diffuse', OldTex))
	{
		if (OldTex != NewTex)
			inst.SetTextureParameterValue('Diffuse', NewTex);
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
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableGogoat_Package.Materials.pm0729_00_Mouth_Wireframe')
	WireframeMaterials.Add(Material'RideableGogoat_Package.Materials.pm0729_00_Eye_Wireframe')
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableGogoat_Package.Materials.pm0729_00_BodyB_Wireframe')
}