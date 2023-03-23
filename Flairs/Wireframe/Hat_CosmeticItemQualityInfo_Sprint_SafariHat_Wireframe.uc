class Hat_CosmeticItemQualityInfo_Sprint_SafariHat_Wireframe extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	CosmeticItemWeApplyTo = class'Hat_CosmeticItemQualityInfo_Sprint_SafariHat'
	ItemQuality = class'Hat_ItemQuality_Supporter'
	SupportsRoulette = false
	MeshOverride = SkeletalMesh'RideableGogoat_Package.models.SafariHat_Wireframe'
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
	SkinWeApplyTo = class'Hat_Collectible_Skin_Wireframe'
}