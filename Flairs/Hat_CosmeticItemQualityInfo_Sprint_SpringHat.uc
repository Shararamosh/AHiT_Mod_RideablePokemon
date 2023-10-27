class Hat_CosmeticItemQualityInfo_Sprint_SpringHat extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	ItemQuality = class'Hat_ItemQuality_Epic'
	SupportsRoulette = true
	MeshOverride = SkeletalMesh'RideableTogekiss_Package.models.Spring_Hat'
	PhysicsAssetOverride = PhysicsAsset'RideableTogekiss_Package.Physics.Spring_Hat_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableTogekiss_Package.Icons.SpringHat_Icon'
	SocketName = "KidHat"
	HidePonytail = CIQ_Off
	HideFrontHair = CIQ_Off
	CosmeticItemName = "SpringHatName"
	Description(0) = "SpringHatDesc0"
	HatSectionGroup = "KidHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableTogekiss'
}