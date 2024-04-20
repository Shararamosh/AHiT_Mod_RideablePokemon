class Hat_StatusEffect_RideableKangaskhan extends Hat_StatusEffect_RideablePokemon;

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
	local Texture OldTex, ChildTex, ParentTex;
	if (!IsPokemonMesh(comp))
		return false;
	switch(Clamp(h, 0, 4))
	{
		case 0:
			ParentTex = Texture2D'RideableKangaskhan_Package.Textures.pm0115_51_EyeA03_col';
			ChildTex = Texture2D'RideableKangaskhan_Package.Textures.pm0115_00_EyeB03_col';
			break;
		case 1:
			ParentTex = Texture2D'RideableKangaskhan_Package.Textures.pm0115_51_EyeA04_col';
			ChildTex = Texture2D'RideableKangaskhan_Package.Textures.pm0115_00_EyeB04_col';
			break;
		case 2:
			ParentTex = Texture2D'RideableKangaskhan_Package.Textures.pm0115_51_EyeA07_col';
			ChildTex = Texture2D'RideableKangaskhan_Package.Textures.pm0115_00_EyeB07_col';
			break;
		case 3:
			ParentTex = Texture2D'RideableKangaskhan_Package.Textures.pm0115_51_EyeA05_col';
			ChildTex = Texture2D'RideableKangaskhan_Package.Textures.pm0115_00_EyeB05_col';
			break;
		default:
			ParentTex = Texture2D'RideableKangaskhan_Package.Textures.pm0115_51_EyeA01_col';
			ChildTex = Texture2D'RideableKangaskhan_Package.Textures.pm0115_00_EyeB01_col';
			break;
	}
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstance(comp, 1, inst);
	if (inst != None && inst.IsInMapOrTransientPackage() && inst.GetTextureParameterValue('DefaultEyes', OldTex))
	{
		if (OldTex != ParentTex)
			inst.SetTextureParameterValue('DefaultEyes', ParentTex);
	}
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstance(comp, 2, inst);
	if (inst != None && inst.IsInMapOrTransientPackage() && inst.GetTextureParameterValue('DefaultEyes', OldTex))
	{
		if (OldTex != ChildTex)
			inst.SetTextureParameterValue('DefaultEyes', ChildTex);
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
		NewTex = Texture2D'RideableKangaskhan_Package.Textures.pm0115_00_Mouth03_col';
	else
		NewTex = Texture2D'RideableKangaskhan_Package.Textures.pm0115_00_Mouth01_col';
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstance(comp, 4, inst);
	if (inst != None && inst.IsInMapOrTransientPackage() && inst.GetTextureParameterValue('Color', OldTex))
	{
		if (OldTex != NewTex)
			inst.SetTextureParameterValue('Color', NewTex);
	}
	return true;
}

defaultproperties
{
	ScooterMesh = SkeletalMesh'RideableKangaskhan_Package.models.Kangaskhan'
	ScooterAnimTree = AnimTree'RideableKangaskhan_Package.AnimTrees.RideableKangaskhan_AnimTree'
	ScooterAnimSet = AnimSet'RideableKangaskhan_Package.AnimSets.Kangaskhan_Anims'
	ScooterPhysics = PhysicsAsset'RideableKangaskhan_Package.Physics.Kangaskhan_Physics'
	HonkSound = SoundCue'RideableKangaskhan_Package.Sounds.Kangaskhan_Cry_Cue'
	ScooterAnimNodesName = "HideCloset"
	ScooterLoopAnimation = "CrammedClosetIdle"
	WireframeMaterials.Add(Material'RideableKangaskhan_Package.Materials.pm0115_51_BodyA_Wireframe')
	WireframeMaterials.Add(Material'RideableKangaskhan_Package.Materials.pm0115_51_EyeA_Wireframe')
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableKangaskhan_Package.Materials.pm0115_00_EyeB_Wireframe')
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableKangaskhan_Package.Materials.pm0115_00_BodyB_Wireframe')
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableKangaskhan_Package.Materials.pm0115_00_Mouth_Wireframe')
}