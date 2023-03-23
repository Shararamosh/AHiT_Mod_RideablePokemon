class Hat_CosmeticItemQualityInfo_Sprint_GlaceonCap_Wireframe extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	CosmeticItemWeApplyTo = class'Hat_CosmeticItemQualityInfo_Sprint_GlaceonCap'
	ItemQuality = class'Hat_ItemQuality_Supporter'
	SupportsRoulette = false
	MeshOverride = SkeletalMesh'RideableGlaceon_Package.models.Glaceon_Cap_Wireframe'
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
	SkinWeApplyTo = class'Hat_Collectible_Skin_Wireframe'
}