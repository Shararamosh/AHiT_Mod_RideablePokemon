class Hat_CosmeticItemQualityInfo_Sprint_TrapperHat extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	ItemQuality = class'Hat_ItemQuality_Epic'
	SupportsRoulette = true
	MeshOverride = SkeletalMesh'RideableFurret_Package.models.TrapperHat'
	PhysicsAssetOverride = PhysicsAsset'RideableFurret_Package.Physics.TrapperHat_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableFurret_Package.Icons.TrapperHatIcon'
	SocketName = "KidHat"
	HidePonytail = CIQ_Off
	HideFrontHair = CIQ_Off
	CosmeticItemName = "TrapperHatName"
	Description(0) = "TrapperHatDesc0"
	HatSectionGroup = "WitchHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableFurret'
}