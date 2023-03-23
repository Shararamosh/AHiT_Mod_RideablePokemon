class Hat_CosmeticItemQualityInfo_Sprint_TrapperHat_Wireframe extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	CosmeticItemWeApplyTo = class'Hat_CosmeticItemQualityInfo_Sprint_TrapperHat'
	ItemQuality = class'Hat_ItemQuality_Supporter'
	SupportsRoulette = true
	MeshOverride = SkeletalMesh'RideableFurret_Package.models.TrapperHat_Wireframe'
	PhysicsAssetOverride = PhysicsAsset'RideableFurret_Package.Physics.TrapperHat_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableFurret_Package.Icons.TrapperHatIcon'
	SocketName = "KidHat"
	HidePonytail = CIQ_Off
	HideFrontHair = CIQ_Off
	CosmeticItemName = "TrapperHatName"
	Description(0) = "TrapperHatDesc0"
	HatSectionGroup = "KidHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableFurret'
	SkinWeApplyTo = class'Hat_Collectible_Skin_Wireframe'
}