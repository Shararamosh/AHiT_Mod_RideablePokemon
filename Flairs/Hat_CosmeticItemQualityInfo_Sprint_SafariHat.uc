class Hat_CosmeticItemQualityInfo_Sprint_SafariHat extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	ItemQuality = class'Hat_ItemQuality_Rare'
	SupportsRoulette = true
	MeshOverride = SkeletalMesh'RideableGogoat_Package.models.SafariHat'
	PhysicsAssetOverride = PhysicsAsset'RideableGogoat_Package.Physics.SafariHat_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableGogoat_Package.Icons.SafariHatIcon'
	SocketName = "KidHat"
	HidePonytail = CIQ_Off
	HideFrontHair = CIQ_Off
	CosmeticItemName = "SafariHatName"
	Description(0) = "SafariHatDesc0"
	HatSectionGroup = "KidHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableGogoat'
}