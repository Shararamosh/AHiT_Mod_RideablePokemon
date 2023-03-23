class Hat_StatusEffect_RideableParasect extends Hat_StatusEffect_RideablePokemon;

static function BattleActionAnims GetBattleActionAnims()
{
	local BattleActionAnims baa;
	baa.IdleAnims.AddItem('Idle');
	baa.IdleAnims.AddItem('Refresh_Emotion1');
	baa.IdleAnims.AddItem('Refresh_Emotion2');
	baa.CryingAnims.AddItem('Attack2');
	baa.PhysicalAttackAnims.AddItem('Attack1');
	baa.TakingDamageAnims.AddItem('TakingHit');
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