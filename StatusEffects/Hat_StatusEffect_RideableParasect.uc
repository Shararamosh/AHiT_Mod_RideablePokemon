class Hat_StatusEffect_RideableParasect extends Hat_StatusEffect_RideablePokemon;

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.AddItem('Battle_Idle');
	baa.PhysicalAttackAnims.AddItem('Battle_PhysicalAttack');
	baa.SpecialAttackAnims.AddItem('Battle_SpecialAttack');
	baa.TakingDamageAnims.AddItem('Battle_Damage');
	return baa;
}

defaultproperties
{
	ScooterMesh = SkeletalMesh'RideableParasect_Package.models.Parasect'
	ScooterAnimTree = AnimTree'RideableParasect_Package.AnimTrees.RideableParasect_AnimTree'
	ScooterAnimSet = AnimSet'RideableParasect_Package.AnimSets.Parasect_Anims'
	ScooterPhysics = PhysicsAsset'RideableParasect_Package.Physics.Parasect_Physics'
	HonkSound = SoundCue'RideableParasect_Package.Sounds.Parasect_Cry_Cue'
	ScooterAnimNodesName = "Bench_Sit"
	ScooterLoopAnimation = "sit_bench"
	WireframeMaterials.Add(MaterialInstanceTimeVarying'RideableParasect_Package.Materials.pm0047_00_00_BodyB_Wireframe')
	WireframeMaterials.Add(Material'RideableParasect_Package.Materials.pm0047_00_00_BodyA_Wireframe')
}