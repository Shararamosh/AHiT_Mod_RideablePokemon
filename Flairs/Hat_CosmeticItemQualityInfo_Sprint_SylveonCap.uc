class Hat_CosmeticItemQualityInfo_Sprint_SylveonCap extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	ItemQuality = class'Hat_ItemQuality_Epic'
	SupportsRoulette = true
	MeshOverride = SkeletalMesh'RideableSylveon_Package.models.Sylveon_Cap'
	PhysicsAssetOverride = PhysicsAsset'RideableSylveon_Package.Physics.Sylveon_Cap_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableSylveon_Package.Icons.Sylveon_Cap_Icon'
	SocketName = "KidHat"
	HidePonytail = CIQ_Off
	HideFrontHair = CIQ_Off
	CosmeticItemName = "SylveonCapName"
	Description(0) = "SylveonCapDesc0"
	HatSectionGroup = "KidHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableSylveon'
}