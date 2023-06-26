class Hat_CosmeticItemQualityInfo_Sprint_LeafeonCap extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	ItemQuality = class'Hat_ItemQuality_Epic'
	SupportsRoulette = true
	MeshOverride = SkeletalMesh'RideableLeafeon_Package.models.Leafeon_Cap'
	PhysicsAssetOverride = PhysicsAsset'RideableLeafeon_Package.Physics.Leafeon_Cap_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableLeafeon_Package.Icons.Leafeon_Cap_Icon'
	SocketName = "KidHat"
	HidePonytail = CIQ_Off
	HideFrontHair = CIQ_Off
	CosmeticItemName = "LeafeonCapName"
	Description(0) = "LeafeonCapDesc0"
	HatSectionGroup = "KidHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableLeafeon'
}