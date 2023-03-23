class Hat_StatusEffect_RideableGastrodon_WS extends Hat_StatusEffect_RideablePokemon;

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.AddItem('Idle');
	baa.IdleAnims.AddItem('HappyIdle');
	baa.IdleAnims.AddItem('Attack3');
	baa.CryingAnims.AddItem('Crying');
	baa.PhysicalAttackAnims.AddItem('Attack2');
	baa.SpecialAttackAnims.AddItem('Attack1');
	baa.TakingDamageAnims.AddItem('TakingHit');
	return baa;
}

static function class<Hat_StatusEffect_RideablePokemon> GetRandomAppearance(bool RandomGender, bool RandomForme)
{
	if (RandomForme)
	{
		if (Rand(2) == 1)
			return class'Hat_StatusEffect_RideableGastrodon_ES';
		return class'Hat_StatusEffect_RideableGastrodon_WS';
	}
	return default.Class;
}

defaultproperties
{
	ScooterMesh = SkeletalMesh'RideableGastrodon_Package.models.Gastrodon_West'
	ScooterAnimTree = AnimTree'RideableGastrodon_Package.AnimTrees.RideableGastrodon_AnimTree'
	ScooterAnimSet = AnimSet'RideableGastrodon_Package.AnimSets.Gastrodon_Anims'
	ScooterPhysics = PhysicsAsset'RideableGastrodon_Package.Physics.Gastrodon_West_Physics'
	HonkSound = SoundCue'RideableGastrodon_Package.Sounds.Gastrodon_Cry_Cue'
	ScooterAnimNodesName = "Bench_Sit"
	ScooterLoopAnimation = "sit_bench"
	WireframeMaterials.Add(Material'RideableGastrodon_Package.Materials.pm0423_11_bodya_Wireframe')
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableGastrodon_Package.Materials.pm0423_11_bodyb_Wireframe')
}