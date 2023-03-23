class Hat_CosmeticItemQualityInfo_Sprint_GlaceonCap extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	ItemQuality = class'Hat_ItemQuality_Epic'
	SupportsRoulette = true
	MeshOverride = SkeletalMesh'RideableGlaceon_Package.models.Glaceon_Cap'
	PhysicsAssetOverride = PhysicsAsset'RideableGlaceon_Package.Physics.Glaceon_Cap_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableGlaceon_Package.Icons.Glaceon_Cap_Icon'
	SocketName = "KidHat"
	HidePonytail = CIQ_Off
	HideFrontHair = CIQ_Off
	CosmeticItemName = "GlaceonCapName"
	Description(0) = "GlaceonCapDesc0"
	HatSectionGroup = "KidHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableGlaceon'
}