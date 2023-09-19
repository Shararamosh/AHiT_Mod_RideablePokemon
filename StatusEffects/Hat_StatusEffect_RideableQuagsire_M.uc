class Hat_StatusEffect_RideableQuagsire_M extends Hat_StatusEffect_RideablePokemon;

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
			return class'Hat_StatusEffect_RideableQuagsire_F';
		return class'Hat_StatusEffect_RideableQuagsire_M';
	}
	return default.Class;
}

static function bool ModifyPokemonEyes(SkeletalMeshComponent comp, int h)
{
	local MaterialInstance inst;
	local Texture OldTex, t1, t2;
	if (comp == None || comp.SkeletalMesh != default.ScooterMesh)
		return false;
	switch(Clamp(h, 0, 4))
	{
		case 0:
			t1 = Texture2D'RideableQuagsire_Package.Textures.pm0195_00_Eye03_col';
			t2 = Texture2D'RideableQuagsire_Package.emission.pm0195_00_Eye03_emi';
			break;
		case 1:
			t1 = Texture2D'RideableQuagsire_Package.Textures.pm0195_00_Eye04_col';
			t2 = Texture2D'RideableQuagsire_Package.emission.pm0195_00_Eye04_emi';
			break;
		case 2:
			t1 = Texture2D'RideableQuagsire_Package.Textures.pm0195_00_Eye07_col';
			t2 = Texture2D'RideableQuagsire_Package.emission.pm0195_00_Eye07_emi';
			break;
		case 3:
			t1 = Texture2D'RideableQuagsire_Package.Textures.pm0195_00_Eye05_col';
			t2 = Texture2D'RideableQuagsire_Package.emission.pm0195_00_Eye05_emi';
			break;
		default:
			t1 = Texture2D'RideableQuagsire_Package.Textures.pm0195_00_Eye01_col';
			t2 = Texture2D'RideableQuagsire_Package.emission.pm0195_00_Eye01_emi';
			break;
	}
	class'Shara_SkinColors_Tools_Short_RPS'.static.ConditionalInitMaterialInstance(comp, 1, inst);
	if (inst != None && inst.IsInMapOrTransientPackage())
	{
		if (inst.GetTextureParameterValue('DefaultEyes', OldTex))
		{
			if (OldTex != t1)
				inst.SetTextureParameterValue('DefaultEyes', t1);
		}
		if (inst.GetTextureParameterValue('DefaultEyesEmission', OldTex))
		{
			if (OldTex != t2)
				inst.SetTextureParameterValue('DefaultEyesEmission', t2);
		}
	}
	return true;
}

defaultproperties
{
	ScooterMesh = SkeletalMesh'RideableQuagsire_Package.models.Quagsire_Male'
	ScooterAnimTree = AnimTree'RideableQuagsire_Package.AnimTrees.RideableQuagsire_AnimTree'
	ScooterAnimSet = AnimSet'RideableQuagsire_Package.AnimSets.Quagsire_Anims'
	ScooterPhysics = PhysicsAsset'RideableQuagsire_Package.Physics.Quagsire_Physics'
	HonkSound = SoundCue'RideableQuagsire_Package.Sounds.Quagsire_Cry_Cue'
	ScooterAnimNodesName = "Race_Intro"
	ScooterIntroAnimation = "race_intro"
	ScooterLoopAnimation = "race_idle"
	WireframeMaterials.Add(Material'RideableQuagsire_Package.Materials.pm0195_00_Body_Wireframe')
	WireframeMaterials.Add(Material'RideableQuagsire_Package.Materials.pm0195_00_Eye_Wireframe')
}